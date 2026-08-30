[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$StudentPassword,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$TeacherPassword,

    [string]$StudentEmail = 'aluno.local@lawrence.test',
    [string]$TeacherEmail = 'professora.local@lawrence.test'
)

$ErrorActionPreference = 'Stop'
$repositoryRoot = Split-Path -Parent $PSScriptRoot
$fixturePath = Join-Path $repositoryRoot 'supabase\fixtures\local_e2e.sql'

if (-not (Test-Path -LiteralPath $fixturePath)) {
    throw "Fixture SQL não encontrada: $fixturePath"
}

$previousErrorActionPreference = $ErrorActionPreference
$ErrorActionPreference = 'Continue'
$statusOutput = & npx --yes supabase@2.109.1 status -o env 2>&1
$statusExitCode = $LASTEXITCODE
$ErrorActionPreference = $previousErrorActionPreference
if ($statusExitCode -ne 0) {
    throw "Supabase local não está disponível. Execute: npx --yes supabase@2.109.1 start"
}

$localEnv = @{}
foreach ($line in $statusOutput) {
    if ($line -match '^([A-Z_]+)="(.*)"$') {
        $localEnv[$Matches[1]] = $Matches[2]
    }
}

$apiUrl = $localEnv['API_URL']
$anonKey = $localEnv['ANON_KEY']
$serviceRoleKey = $localEnv['SERVICE_ROLE_KEY']

if ($apiUrl -notin @('http://127.0.0.1:54321', 'http://localhost:54321')) {
    throw "Execução recusada: API Supabase não é a stack local esperada ($apiUrl)."
}

if (-not $anonKey -or -not $serviceRoleKey) {
    throw 'Não foi possível obter as chaves efêmeras da stack Supabase local.'
}

$adminHeaders = @{
    apikey = $serviceRoleKey
    Authorization = "Bearer $serviceRoleKey"
    'Content-Type' = 'application/json'
}

function Test-LocalUserPassword {
    param(
        [Parameter(Mandatory = $true)][string]$Email,
        [Parameter(Mandatory = $true)][string]$Password
    )

    $loginHeaders = @{
        apikey = $anonKey
        'Content-Type' = 'application/json'
    }
    $loginBody = @{
        email = $Email
        password = $Password
    } | ConvertTo-Json

    try {
        Invoke-RestMethod `
            -Method Post `
            -Uri "$apiUrl/auth/v1/token?grant_type=password" `
            -Headers $loginHeaders `
            -Body $loginBody | Out-Null
        return $true
    } catch {
        $statusCode = [int]$_.Exception.Response.StatusCode
        if ($statusCode -in @(400, 401)) {
            return $false
        }

        throw
    }
}

function Get-OrCreateLocalUser {
    param(
        [Parameter(Mandatory = $true)][string]$Email,
        [Parameter(Mandatory = $true)][string]$Password,
        [Parameter(Mandatory = $true)][string]$FullName,
        [Parameter(Mandatory = $true)]
        [ValidateSet('student', 'teacher')]
        [string]$Role
    )

    $usersResponse = Invoke-RestMethod `
        -Method Get `
        -Uri "$apiUrl/auth/v1/admin/users?page=1&per_page=1000" `
        -Headers $adminHeaders

    $existing = $usersResponse.users | Where-Object { $_.email -eq $Email } | Select-Object -First 1
    if ($existing) {
        $passwordIsValid = Test-LocalUserPassword -Email $Email -Password $Password
        $metadataIsCurrent =
            $existing.user_metadata.full_name -eq $FullName -and
            $existing.app_metadata.role -eq $Role

        if ($passwordIsValid -and $metadataIsCurrent) {
            return $existing
        }

        $update = @{
            user_metadata = @{ full_name = $FullName }
            app_metadata = @{ role = $Role }
        }
        if (-not $passwordIsValid) {
            # Alterar a senha invalida refresh tokens existentes. Só faça isso
            # quando a credencial solicitada realmente estiver desatualizada.
            $update.password = $Password
        }
        $updateBody = $update | ConvertTo-Json -Depth 4

        return Invoke-RestMethod `
            -Method Put `
            -Uri "$apiUrl/auth/v1/admin/users/$($existing.id)" `
            -Headers $adminHeaders `
            -Body $updateBody
    }

    $body = @{
        email = $Email
        password = $Password
        email_confirm = $true
        user_metadata = @{ full_name = $FullName }
        app_metadata = @{ role = $Role }
    } | ConvertTo-Json -Depth 4

    return Invoke-RestMethod `
        -Method Post `
        -Uri "$apiUrl/auth/v1/admin/users" `
        -Headers $adminHeaders `
        -Body $body
}

function Initialize-LocalHlsFixtures {
    $workerContainer = @(
        'lawrence-academy-video-worker-1',
        'lawrence_academy-video-worker-1'
    ) | Where-Object {
        docker inspect --format '{{.State.Running}}' $_ 2>$null | Select-String '^true$'
    } | Select-Object -First 1

    if (-not $workerContainer) {
        throw 'Worker de vídeo local indisponível. Inicie a stack Docker antes de carregar as fixtures.'
    }
    $workerRunning = docker inspect `
        --format '{{.State.Running}}' `
        $workerContainer 2>$null

    if ($LASTEXITCODE -ne 0 -or $workerRunning -ne 'true') {
        throw "Worker de vídeo local indisponível ($workerContainer). Inicie a stack Docker antes de carregar as fixtures."
    }

    $fixtureId = "lawrence-local-hls-$PID"
    $containerPath = "/tmp/$fixtureId"
    $temporaryRoot = Join-Path ([System.IO.Path]::GetTempPath()) $fixtureId
    $resolvedTempBase = [System.IO.Path]::GetFullPath([System.IO.Path]::GetTempPath())
    $resolvedTemporaryRoot = [System.IO.Path]::GetFullPath($temporaryRoot)

    if (-not $resolvedTemporaryRoot.StartsWith($resolvedTempBase, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Diretório temporário inválido: $resolvedTemporaryRoot"
    }

    New-Item -ItemType Directory -Path $resolvedTemporaryRoot -Force | Out-Null

    try {
        docker exec $workerContainer mkdir -p $containerPath
        if ($LASTEXITCODE -ne 0) {
            throw 'Falha ao preparar o diretório temporário do worker de vídeo.'
        }

        docker exec $workerContainer ffmpeg `
            -hide_banner `
            -loglevel error `
            -f lavfi `
            -i 'testsrc2=size=640x360:rate=24' `
            -f lavfi `
            -i 'anullsrc=channel_layout=stereo:sample_rate=48000' `
            -t 2 `
            -c:v libx264 `
            -preset ultrafast `
            -pix_fmt yuv420p `
            -c:a aac `
            -f hls `
            -hls_time 1 `
            -hls_playlist_type vod `
            -hls_segment_filename "$containerPath/segment%03d.ts" `
            "$containerPath/master.m3u8"

        if ($LASTEXITCODE -ne 0) {
            throw 'FFmpeg não conseguiu gerar a mídia HLS da fixture local.'
        }

        docker cp "${workerContainer}:${containerPath}/." $resolvedTemporaryRoot
        if ($LASTEXITCODE -ne 0) {
            throw 'Falha ao copiar a mídia HLS da fixture para upload local.'
        }

        $storagePrefixes = @(
            'local-fixtures/costura/01',
            'local-fixtures/costura/02',
            'local-fixtures/modelagem/01'
        )
        $mediaFiles = Get-ChildItem -LiteralPath $resolvedTemporaryRoot -File

        foreach ($prefix in $storagePrefixes) {
            foreach ($mediaFile in $mediaFiles) {
                $contentType = if ($mediaFile.Extension -eq '.m3u8') {
                    'application/vnd.apple.mpegurl'
                } else {
                    'video/mp2t'
                }
                $uploadHeaders = @{
                    apikey = $serviceRoleKey
                    Authorization = "Bearer $serviceRoleKey"
                    'Content-Type' = $contentType
                    'x-upsert' = 'true'
                }

                Invoke-WebRequest `
                    -UseBasicParsing `
                    -Method Post `
                    -Uri "$apiUrl/storage/v1/object/lessons-hls/$prefix/$($mediaFile.Name)" `
                    -Headers $uploadHeaders `
                    -InFile $mediaFile.FullName | Out-Null
            }
        }
    }
    finally {
        if (Test-Path -LiteralPath $resolvedTemporaryRoot) {
            Remove-Item -LiteralPath $resolvedTemporaryRoot -Recurse -Force
        }
    }
}

$student = Get-OrCreateLocalUser `
    -Email $StudentEmail `
    -Password $StudentPassword `
    -FullName 'Aluno Local' `
    -Role 'student'

$teacher = Get-OrCreateLocalUser `
    -Email $TeacherEmail `
    -Password $TeacherPassword `
    -FullName 'Professora Local' `
    -Role 'teacher'

if ($student.id -notmatch '^[0-9a-fA-F-]{36}$' -or $teacher.id -notmatch '^[0-9a-fA-F-]{36}$') {
    throw 'A Auth Admin API retornou identificadores inválidos.'
}

$databaseContainer = 'supabase_db_site_ariane'
$containerFixturePath = "/tmp/lawrence-local-e2e-$PID.sql"

docker cp $fixturePath "${databaseContainer}:${containerFixturePath}"
if ($LASTEXITCODE -ne 0) {
    throw 'Falha ao copiar a fixture SQL para o Postgres local.'
}

try {
    docker exec $databaseContainer psql `
        -U postgres `
        -d postgres `
        -v ON_ERROR_STOP=1 `
        -v "student_id=$($student.id)" `
        -v "teacher_id=$($teacher.id)" `
        -f $containerFixturePath

    if ($LASTEXITCODE -ne 0) {
        throw 'Falha ao carregar a fixture SQL no Postgres local.'
    }
}
finally {
    docker exec $databaseContainer rm -f $containerFixturePath | Out-Null
}

Initialize-LocalHlsFixtures

$authHeaders = @{
    apikey = $anonKey
    'Content-Type' = 'application/json'
}
$loginBody = @{
    email = $StudentEmail
    password = $StudentPassword
} | ConvertTo-Json

$session = Invoke-RestMethod `
    -Method Post `
    -Uri "$apiUrl/auth/v1/token?grant_type=password" `
    -Headers $authHeaders `
    -Body $loginBody

if (-not $session.access_token) {
    throw 'A fixture foi criada, mas o login do aluno local falhou.'
}

$teacherLoginBody = @{
    email = $TeacherEmail
    password = $TeacherPassword
} | ConvertTo-Json

$teacherSession = Invoke-RestMethod `
    -Method Post `
    -Uri "$apiUrl/auth/v1/token?grant_type=password" `
    -Headers $authHeaders `
    -Body $teacherLoginBody

if (-not $teacherSession.access_token) {
    throw 'A fixture foi criada, mas o login da professora local falhou.'
}

$userHeaders = @{
    apikey = $anonKey
    Authorization = "Bearer $($session.access_token)"
}

$subscriptions = Invoke-RestMethod `
    -Method Get `
    -Uri "$apiUrl/rest/v1/subscriptions?select=id,course_id,status" `
    -Headers $userHeaders

$progress = Invoke-RestMethod `
    -Method Get `
    -Uri "$apiUrl/rest/v1/lesson_progress?select=id,course_id,lesson_id,completed" `
    -Headers $userHeaders

$teacherHeaders = @{
    apikey = $anonKey
    Authorization = "Bearer $($teacherSession.access_token)"
}

$teacherProfile = Invoke-RestMethod `
    -Method Get `
    -Uri "$apiUrl/rest/v1/profiles?id=eq.$($teacher.id)&select=id,role" `
    -Headers $teacherHeaders

if (
    @($subscriptions).Count -ne 1 -or
    @($progress).Count -ne 3 -or
    @($teacherProfile).Count -ne 1 -or
    @($teacherProfile)[0].role -ne 'teacher'
) {
    throw 'Validação RLS falhou: assinatura ou progresso não retornou a cardinalidade esperada.'
}

Write-Output 'Fixtures locais carregadas e login/RLS validados.'
Write-Output 'Mídia HLS local protegida gerada e enviada ao bucket privado.'
Write-Output "Aluno: $StudentEmail"
Write-Output "Professora: $TeacherEmail"
Write-Output 'As senhas são as informadas no comando e não foram gravadas no repositório.'
