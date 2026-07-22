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
$statusOutput = & npx --yes supabase@2.84.2 status -o env 2>&1
$statusExitCode = $LASTEXITCODE
$ErrorActionPreference = $previousErrorActionPreference
if ($statusExitCode -ne 0) {
    throw "Supabase local não está disponível. Execute: npx --yes supabase@2.84.2 start"
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

function Get-OrCreateLocalUser {
    param(
        [Parameter(Mandatory = $true)][string]$Email,
        [Parameter(Mandatory = $true)][string]$Password,
        [Parameter(Mandatory = $true)][string]$FullName
    )

    $usersResponse = Invoke-RestMethod `
        -Method Get `
        -Uri "$apiUrl/auth/v1/admin/users?page=1&per_page=1000" `
        -Headers $adminHeaders

    $existing = $usersResponse.users | Where-Object { $_.email -eq $Email } | Select-Object -First 1
    if ($existing) {
        $updateBody = @{
            password = $Password
            email_confirm = $true
            user_metadata = @{ full_name = $FullName }
        } | ConvertTo-Json -Depth 4

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
    } | ConvertTo-Json -Depth 4

    return Invoke-RestMethod `
        -Method Post `
        -Uri "$apiUrl/auth/v1/admin/users" `
        -Headers $adminHeaders `
        -Body $body
}

$student = Get-OrCreateLocalUser `
    -Email $StudentEmail `
    -Password $StudentPassword `
    -FullName 'Aluno Local'

$teacher = Get-OrCreateLocalUser `
    -Email $TeacherEmail `
    -Password $TeacherPassword `
    -FullName 'Professora Local'

if ($student.id -notmatch '^[0-9a-fA-F-]{36}$' -or $teacher.id -notmatch '^[0-9a-fA-F-]{36}$') {
    throw 'A Auth Admin API retornou identificadores inválidos.'
}

Get-Content -Raw -LiteralPath $fixturePath |
    docker exec -i supabase_db_site_ariane psql `
        -U postgres `
        -d postgres `
        -v ON_ERROR_STOP=1 `
        -v "student_id=$($student.id)" `
        -v "teacher_id=$($teacher.id)"

if ($LASTEXITCODE -ne 0) {
    throw 'Falha ao carregar a fixture SQL no Postgres local.'
}

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
Write-Output "Aluno: $StudentEmail"
Write-Output "Professora: $TeacherEmail"
Write-Output 'As senhas são as informadas no comando e não foram gravadas no repositório.'
