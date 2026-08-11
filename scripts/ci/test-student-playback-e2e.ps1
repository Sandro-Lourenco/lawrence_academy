[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$BackendUrl,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$SupabaseUrl,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$SupabaseAnonKey,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$StudentPassword,
    [string]$StudentEmail = 'aluno.local@lawrence.test'
)

$ErrorActionPreference = 'Stop'
$courseId = '91000000-0000-0000-0000-000000000001'
$lessonId = '93000000-0000-0000-0000-000000000002'

function Assert-LocalEndpoint {
    param([Parameter(Mandatory = $true)][string]$Uri, [string[]]$AllowedPorts)

    $parsed = [Uri]$Uri
    if ($parsed.Scheme -ne 'http' -or $parsed.Host -notin @('127.0.0.1', 'localhost')) {
        throw "E2E recusado fora da stack local: $Uri"
    }
    if ($parsed.Port.ToString() -notin $AllowedPorts) {
        throw "Porta local inesperada para o E2E: $Uri"
    }
}

Assert-LocalEndpoint -Uri $BackendUrl -AllowedPorts @('8000')
Assert-LocalEndpoint -Uri $SupabaseUrl -AllowedPorts @('54321')

$login = Invoke-RestMethod `
    -Method Post `
    -Uri "$($SupabaseUrl.TrimEnd('/'))/auth/v1/token?grant_type=password" `
    -Headers @{ apikey = $SupabaseAnonKey; 'Content-Type' = 'application/json' } `
    -Body (@{ email = $StudentEmail; password = $StudentPassword } | ConvertTo-Json)

if (-not $login.access_token) {
    throw 'Login do aluno não retornou access token.'
}

$authHeaders = @{ Authorization = "Bearer $($login.access_token)" }
$stream = Invoke-RestMethod `
    -Method Get `
    -Uri "$($BackendUrl.TrimEnd('/'))/api/v1/courses/$courseId/lessons/$lessonId/stream" `
    -Headers $authHeaders

if (-not $stream.signedUrl -or -not $stream.signedUrl.StartsWith('/api/v1/')) {
    throw "Endpoint de stream não retornou um caminho protegido relativo: $($stream.signedUrl)"
}

$manifestUri = "$($BackendUrl.TrimEnd('/'))$($stream.signedUrl)"
$manifest = Invoke-WebRequest -UseBasicParsing -Method Get -Uri $manifestUri
if ($manifest.StatusCode -ne 200 -or $manifest.Content -notmatch '#EXTM3U') {
    throw 'Manifesto HLS protegido não foi carregado.'
}

$mediaUri = ($manifest.Content -split "`n" | ForEach-Object { $_.Trim() } |
    Where-Object { $_ -and -not $_.StartsWith('#') } | Select-Object -First 1)
if (-not $mediaUri) {
    throw 'Manifesto HLS não contém playlist ou segmento reproduzível.'
}

$childUri = [Uri]::new([Uri]$manifestUri, $mediaUri).AbsoluteUri
$mediaResponse = Invoke-WebRequest -UseBasicParsing -Method Get -Uri $childUri
if ($mediaResponse.StatusCode -ne 200) {
    throw "Primeiro recurso HLS não ficou acessível: HTTP $($mediaResponse.StatusCode)"
}

Write-Output 'Student protected HLS playback E2E passed.'
