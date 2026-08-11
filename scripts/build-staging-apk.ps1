param(
    [Parameter(Mandatory = $true)]
    [ValidatePattern('^https://')]
    [string]$ApiBaseUrl,
    [string]$SupabaseUrl = 'https://ctjsmeyilapeliptelfk.supabase.co',
    [Parameter(Mandatory = $true)]
    [string]$SupabasePublishableKey
)

$ErrorActionPreference = 'Stop'
$workspaceRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$portableJdk = Get-ChildItem (Join-Path $workspaceRoot '.tools\jdk17') -Directory -ErrorAction SilentlyContinue |
    Where-Object { Test-Path (Join-Path $_.FullName 'bin\java.exe') } |
    Select-Object -First 1

if ($null -eq $portableJdk) {
    throw 'JDK 17 não encontrado em .tools\jdk17. Consulte o guia de staging.'
}

$env:JAVA_HOME = $portableJdk.FullName
$env:PATH = "$(Join-Path $env:JAVA_HOME 'bin');$env:PATH"

# Flutter otherwise prefers Android Studio's bundled JBR (currently Java 25 on
# this workstation), which Gradle 8 cannot parse. Pin Flutter to the portable
# Java 17 toolchain before resolving or building the Android project.
& flutter config --jdk-dir $env:JAVA_HOME | Out-Null
if ($LASTEXITCODE -ne 0) { throw 'Não foi possível configurar o JDK 17 no Flutter.' }

if ($ApiBaseUrl -match 'localhost|127\.0\.0\.1|10\.0\.2\.2') {
    throw 'O APK de staging não pode apontar para um endpoint local.'
}
if ($SupabaseUrl -eq 'https://xblesfvcrnbsfhlmoffz.supabase.co') {
    throw 'O APK de staging não pode apontar para o Supabase de produção.'
}
if ($SupabasePublishableKey -match 'service_role|^sb_secret_') {
    throw 'Use somente uma publishable key do Supabase no aplicativo.'
}

$flutterArgs = @(
    'build', 'apk', '--debug', '--flavor', 'staging',
    '--dart-define=ENV=staging',
    "--dart-define=API_BASE_URL=$ApiBaseUrl",
    "--dart-define=SUPABASE_URL=$SupabaseUrl",
    "--dart-define=SUPABASE_ANON_KEY=$SupabasePublishableKey"
)

Push-Location (Join-Path $workspaceRoot 'lawrence')
try {
    # Some Windows Flutter installations recreate Apple package caches with the
    # ReadOnly attribute. Clearing it is safe because these folders are generated
    # and otherwise `flutter pub get` can fail before an Android-only build.
    foreach ($generatedRoot in @('ios\Flutter\ephemeral', 'macos\Flutter\ephemeral')) {
        if (Test-Path -LiteralPath $generatedRoot) {
            Get-ChildItem -LiteralPath $generatedRoot -Recurse -Force |
                ForEach-Object {
                    $_.Attributes = $_.Attributes -band (-bnot [IO.FileAttributes]::ReadOnly)
                }
        }
    }

    & flutter @flutterArgs
    if ($LASTEXITCODE -ne 0) { throw "Flutter build falhou com código $LASTEXITCODE." }
    $source = Join-Path (Get-Location) 'build\app\outputs\flutter-apk\app-staging-debug.apk'
    $destination = Join-Path (Get-Location) 'build\app\outputs\flutter-apk\lawrence-academy-staging.apk'
    Copy-Item -LiteralPath $source -Destination $destination -Force
    Write-Output $destination
}
finally {
    Pop-Location
}
