[CmdletBinding()]
param(
    [string]$PgUrl = 'postgresql://postgres:postgres@127.0.0.1:54322/postgres',
    [string]$DatabaseContainer
)

$ErrorActionPreference = 'Stop'
$scriptDirectory = $PSScriptRoot
$setupPath = Join-Path $scriptDirectory 'course-publication-concurrency-setup.sql'
$assertPath = Join-Path $scriptDirectory 'course-publication-concurrency-assert.sql'
$cleanupPath = Join-Path $scriptDirectory 'course-publication-concurrency-cleanup.sql'
$psqlCommand = Get-Command psql -ErrorAction SilentlyContinue
$dockerCommand = Get-Command docker -ErrorAction SilentlyContinue

if ($PgUrl -notmatch '^postgresql://[^@]+@(127\.0\.0\.1|localhost):54322/postgres$') {
    throw 'Execution refused: PgUrl must target the local Supabase PostgreSQL port.'
}

$useDocker = $null -eq $psqlCommand
if ($useDocker) {
    if ($null -eq $dockerCommand) {
        throw 'Neither psql nor docker is available.'
    }

    if (-not $DatabaseContainer) {
        $containers = @(
            & $dockerCommand.Source ps `
                --filter 'name=supabase_db_' `
                --format '{{.Names}}' |
                Where-Object { $_ -match '^supabase_db_[A-Za-z0-9_.-]+$' }
        )
        if ($LASTEXITCODE -ne 0) {
            throw 'Could not inspect local Docker containers.'
        }
        if ($containers.Count -ne 1) {
            throw "Expected exactly one local supabase_db_* container; found $($containers.Count)."
        }
        $DatabaseContainer = $containers[0]
    }

    if ($DatabaseContainer -notmatch '^supabase_db_[A-Za-z0-9_.-]+$') {
        throw 'Execution refused: invalid Supabase database container name.'
    }

    $runningContainer = & $dockerCommand.Source inspect `
        --format '{{.State.Running}}' `
        $DatabaseContainer 2>$null
    if ($LASTEXITCODE -ne 0 -or $runningContainer -ne 'true') {
        throw "Supabase database container is not running: $DatabaseContainer"
    }
}

function New-DatabaseProcess {
    param(
        [string]$Query,
        [switch]$ReadStandardInput
    )

    $startInfo = [System.Diagnostics.ProcessStartInfo]::new()
    $startInfo.UseShellExecute = $false
    $startInfo.RedirectStandardOutput = $true
    $startInfo.RedirectStandardError = $true
    $startInfo.RedirectStandardInput = $ReadStandardInput
    $arguments = [System.Collections.Generic.List[string]]::new()

    if ($useDocker) {
        $startInfo.FileName = $dockerCommand.Source
        foreach ($argument in @(
            'exec', '-i', $DatabaseContainer,
            'psql', '-U', 'postgres', '-d', 'postgres',
            '-X', '-v', 'ON_ERROR_STOP=1'
        )) {
            [void]$arguments.Add($argument)
        }
    }
    else {
        $startInfo.FileName = $psqlCommand.Source
        foreach ($argument in @($PgUrl, '-X', '-v', 'ON_ERROR_STOP=1')) {
            [void]$arguments.Add($argument)
        }
    }

    if ($ReadStandardInput) {
        [void]$arguments.Add('-f')
        [void]$arguments.Add('-')
    }
    else {
        [void]$arguments.Add('-c')
        [void]$arguments.Add($Query)
    }

    if ($null -ne $startInfo.ArgumentList) {
        foreach ($argument in $arguments) {
            [void]$startInfo.ArgumentList.Add($argument)
        }
    }
    else {
        # Windows PowerShell 5.1 does not expose ProcessStartInfo.ArgumentList.
        # Inputs are either fixed literals or validated container/localhost values.
        $startInfo.Arguments = ($arguments | ForEach-Object {
            '"' + ($_ -replace '(\\*)"', '$1$1\"' -replace '(\\+)$', '$1$1') + '"'
        }) -join ' '
    }
    return [System.Diagnostics.Process]::Start($startInfo)
}

function Wait-DatabaseProcess {
    param(
        [Parameter(Mandatory = $true)]
        [System.Diagnostics.Process]$Process,
        [Parameter(Mandatory = $true)]
        [string]$Label
    )

    $Process.WaitForExit()
    $output = $Process.StandardOutput.ReadToEnd()
    $errorOutput = $Process.StandardError.ReadToEnd()
    if ($Process.ExitCode -ne 0) {
        throw @"
$Label failed with exit code $($Process.ExitCode).
$output
$errorOutput
"@
    }
    return $output
}

function Invoke-PsqlFile {
    param([Parameter(Mandatory = $true)][string]$Path)

    $process = New-DatabaseProcess -ReadStandardInput
    $process.StandardInput.Write((Get-Content -Raw -LiteralPath $Path))
    $process.StandardInput.Close()
    [void](Wait-DatabaseProcess -Process $process -Label $Path)
}

function Start-PsqlQuery {
    param([Parameter(Mandatory = $true)][string]$Query)

    return New-DatabaseProcess -Query $Query
}

$publicationCall = @"
SELECT public.publish_course_idempotent(
  '90100000-0000-0000-0000-000000000001',
  '90100000-0000-0000-0000-000000000002',
  'Concurrent local publication',
  encode(digest('concurrent-publication-attempt-0001', 'sha256'), 'hex'),
  'concurrent-publication-request-hash-0001',
  NULL
);
"@

$firstQuery = "BEGIN; $publicationCall SELECT pg_sleep(2); COMMIT;"
$secondQuery = $publicationCall

try {
    Invoke-PsqlFile -Path $setupPath

    $first = Start-PsqlQuery -Query $firstQuery
    Start-Sleep -Milliseconds 150
    $second = Start-PsqlQuery -Query $secondQuery

    [void](Wait-DatabaseProcess -Process $first -Label 'first publication connection')
    [void](Wait-DatabaseProcess -Process $second -Label 'second publication connection')

    Invoke-PsqlFile -Path $assertPath
    Write-Output 'Concurrent publication passed with one version, request, and history row.'
}
finally {
    Invoke-PsqlFile -Path $cleanupPath
}
