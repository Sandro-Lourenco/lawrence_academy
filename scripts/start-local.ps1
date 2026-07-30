[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$StudentPassword,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$TeacherPassword
)

$ErrorActionPreference = 'Stop'
$repositoryRoot = Split-Path -Parent $PSScriptRoot
$composeBase = Join-Path $repositoryRoot 'docker-compose.yml'
$composeLocal = Join-Path $repositoryRoot 'docker-compose.local.yml'

$previousErrorActionPreference = $ErrorActionPreference
$ErrorActionPreference = 'Continue'
docker info *> $null
$dockerInfoExitCode = $LASTEXITCODE
$ErrorActionPreference = $previousErrorActionPreference
if ($dockerInfoExitCode -ne 0) {
    throw 'Docker Desktop não está disponível.'
}

$previousErrorActionPreference = $ErrorActionPreference
$ErrorActionPreference = 'Continue'
$statusOutput = & npx --yes supabase@2.109.1 status -o env 2>&1
$statusExitCode = $LASTEXITCODE
$ErrorActionPreference = $previousErrorActionPreference

if ($statusExitCode -ne 0) {
    $previousErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    & npx --yes supabase@2.109.1 start
    $startExitCode = $LASTEXITCODE
    $ErrorActionPreference = $previousErrorActionPreference
    if ($startExitCode -ne 0) {
        throw 'Falha ao iniciar a stack Supabase local.'
    }

    $previousErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    $statusOutput = & npx --yes supabase@2.109.1 status -o env 2>&1
    $statusExitCode = $LASTEXITCODE
    $ErrorActionPreference = $previousErrorActionPreference
}

if ($statusExitCode -ne 0) {
    throw 'A stack Supabase local não retornou uma configuração válida.'
}

foreach ($line in $statusOutput) {
    if ($line -match '^ANON_KEY="(.*)"$') {
        $env:SUPABASE_LOCAL_ANON_KEY = $Matches[1]
    }
    if ($line -match '^SERVICE_ROLE_KEY="(.*)"$') {
        $env:SUPABASE_LOCAL_SERVICE_ROLE_KEY = $Matches[1]
    }
}

if (-not $env:SUPABASE_LOCAL_ANON_KEY -or -not $env:SUPABASE_LOCAL_SERVICE_ROLE_KEY) {
    throw 'Não foi possível obter as chaves efêmeras da stack Supabase local.'
}

$previousErrorActionPreference = $ErrorActionPreference
$ErrorActionPreference = 'Continue'
docker compose `
    -f $composeBase `
    -f $composeLocal `
    up -d --build
$composeExitCode = $LASTEXITCODE
$ErrorActionPreference = $previousErrorActionPreference
if ($composeExitCode -ne 0) {
    throw 'Falha ao construir ou iniciar a aplicação local.'
}

$healthDeadline = (Get-Date).AddMinutes(2)
do {
    try {
        $backendHealth = Invoke-RestMethod -Uri 'http://127.0.0.1:8000/ready'
        $frontendHealth = Invoke-WebRequest -UseBasicParsing -Uri 'http://127.0.0.1:8080/health'
        if ($backendHealth.status -eq 'ready' -and $frontendHealth.StatusCode -eq 200) {
            break
        }
    }
    catch {
        Start-Sleep -Seconds 3
    }
} while ((Get-Date) -lt $healthDeadline)

if (
    $backendHealth.status -ne 'ready' -or
    $frontendHealth.StatusCode -ne 200
) {
    throw 'A aplicação iniciou, mas os health checks locais não ficaram prontos.'
}

& (Join-Path $PSScriptRoot 'load-local-fixtures.ps1') `
    -StudentPassword $StudentPassword `
    -TeacherPassword $TeacherPassword

if ($LASTEXITCODE -ne 0) {
    throw 'A aplicação subiu, mas as fixtures locais falharam.'
}

Write-Output ''
Write-Output 'Lawrence Academy local pronta.'
Write-Output 'Frontend: http://localhost:8080'
Write-Output 'Backend:  http://localhost:8000'
Write-Output 'Supabase: http://localhost:54321'
