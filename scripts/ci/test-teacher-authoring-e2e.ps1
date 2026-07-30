[CmdletBinding()]
param(
    [string]$BackendUrl = 'http://127.0.0.1:8000',
    [string]$SupabaseUrl = $env:SUPABASE_URL,
    [string]$SupabaseAnonKey = $env:SUPABASE_ANON_KEY,
    [string]$SupabaseServiceRoleKey = $env:SUPABASE_SERVICE_ROLE_KEY,
    [string]$TeacherEmail = 'professora.local@lawrence.test',
    [string]$TeacherPassword = 'CI-Local-Teacher-2026!'
)

$ErrorActionPreference = 'Stop'

if ($BackendUrl -notmatch '^http://(127\.0\.0\.1|localhost):8000/?$') {
    throw 'Execution refused: BackendUrl must target localhost:8000.'
}
if ($SupabaseUrl -notmatch '^http://(127\.0\.0\.1|localhost):54321/?$') {
    throw 'Execution refused: SupabaseUrl must target the local Supabase API.'
}
if (-not $SupabaseAnonKey -or -not $SupabaseServiceRoleKey) {
    throw 'Local Supabase anon and service-role keys are required.'
}

$BackendUrl = $BackendUrl.TrimEnd('/')
$SupabaseUrl = $SupabaseUrl.TrimEnd('/')
$runId = [guid]::NewGuid().ToString('N')
$slug = "ci-authoring-$runId"
$courseId = $null
$teacherId = $null
$intentKeys = [ordered]@{
    course = "ci-course-$runId"
    module = "ci-module-$runId"
    lesson = "ci-lesson-$runId"
    block = "ci-block-$runId"
    publish = "ci-publish-$runId"
}

function ConvertTo-OpaqueKey {
    param([Parameter(Mandatory = $true)][string]$Value)

    $bytes = [System.Text.Encoding]::UTF8.GetBytes($Value)
    $sha256 = [System.Security.Cryptography.SHA256]::Create()
    try {
        $hash = $sha256.ComputeHash($bytes)
        return ($hash | ForEach-Object { $_.ToString('x2') }) -join ''
    }
    finally {
        $sha256.Dispose()
    }
}

function Invoke-JsonRequest {
    param(
        [Parameter(Mandatory = $true)][string]$Method,
        [Parameter(Mandatory = $true)][string]$Uri,
        [hashtable]$Headers = @{},
        $Body,
        [int[]]$ExpectedStatus = @(200)
    )

    $parameters = @{
        Method = $Method
        Uri = $Uri
        Headers = $Headers
    }
    if ((Get-Command Invoke-WebRequest).Parameters.ContainsKey('SkipHttpErrorCheck')) {
        $parameters.SkipHttpErrorCheck = $true
    }
    if ((Get-Command Invoke-WebRequest).Parameters.ContainsKey('UseBasicParsing')) {
        $parameters.UseBasicParsing = $true
    }
    if ($null -ne $Body) {
        $parameters.ContentType = 'application/json'
        $parameters.Body = $Body | ConvertTo-Json -Depth 12 -Compress
    }
    $response = Invoke-WebRequest @parameters
    if ($response.StatusCode -notin $ExpectedStatus) {
        throw "$Method $Uri returned $($response.StatusCode): $($response.Content)"
    }
    if ([string]::IsNullOrWhiteSpace($response.Content)) {
        return $null
    }
    return $response.Content | ConvertFrom-Json
}

function Remove-LocalE2eRows {
    param(
        [string]$CourseId,
        [Parameter(Mandatory = $true)][string]$ActorId,
        [Parameter(Mandatory = $true)][string[]]$OpaqueKeys
    )

    if ($CourseId -and $CourseId -notmatch '^[0-9a-fA-F-]{36}$') {
        throw 'Cleanup refused: invalid course UUID.'
    }
    if ($ActorId -notmatch '^[0-9a-fA-F-]{36}$') {
        throw 'Cleanup refused: invalid actor UUID.'
    }
    if ($OpaqueKeys.Where({ $_ -notmatch '^[0-9a-f]{64}$' }).Count -ne 0) {
        throw 'Cleanup refused: invalid opaque idempotency key.'
    }

    $docker = Get-Command docker -ErrorAction Stop
    $containers = @(
        & $docker.Source ps --filter 'name=supabase_db_' --format '{{.Names}}' |
        Where-Object { $_ -match '^supabase_db_[A-Za-z0-9_.-]+$' }
    )
    if ($LASTEXITCODE -ne 0 -or $containers.Count -ne 1) {
        throw 'Cleanup requires exactly one running local supabase_db_* container.'
    }

    $quotedKeys = ($OpaqueKeys | ForEach-Object { "'$_'" }) -join ','
    $courseCleanup = if ($CourseId) {
        "DELETE FROM public.courses WHERE id = '$CourseId'::uuid;"
    }
    else {
        ''
    }
    $query = @"
$courseCleanup
DELETE FROM public.course_authoring_idempotency_requests
WHERE actor_id = '$ActorId'::uuid
  AND idempotency_key IN ($quotedKeys);
"@
    & $docker.Source exec $containers[0] psql -U postgres -d postgres `
        -X -v ON_ERROR_STOP=1 -c $query | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw 'Local idempotency-ledger cleanup failed.'
    }
}

$serviceHeaders = @{
    apikey = $SupabaseServiceRoleKey
    Authorization = "Bearer $SupabaseServiceRoleKey"
    Prefer = 'return=representation'
}

try {
    $session = Invoke-JsonRequest `
        -Method Post `
        -Uri "$SupabaseUrl/auth/v1/token?grant_type=password" `
        -Headers @{ apikey = $SupabaseAnonKey } `
        -Body @{ email = $TeacherEmail; password = $TeacherPassword }
    if (-not $session.access_token -or -not $session.user.id) {
        throw 'Teacher login did not return an access token and user id.'
    }
    $teacherId = $session.user.id
    $authHeaders = @{ Authorization = "Bearer $($session.access_token)" }

    $coursePayload = @{
        title = 'CI Authoring Course'
        slug = $slug
        summary = 'Synthetic local end-to-end authoring course'
        category = 'costura'
        level = 'iniciante'
        monthly_price = 0
        learning_objectives = @('Validate reliable authoring')
        target_audience = @('Local CI')
        status = 'draft'
    }
    $courseHeaders = $authHeaders.Clone()
    $courseHeaders['Idempotency-Key'] = $intentKeys.course
    $course = Invoke-JsonRequest -Method Post `
        -Uri "$BackendUrl/api/v1/teacher/courses" `
        -Headers $courseHeaders -Body $coursePayload -ExpectedStatus @(201)
    $courseReplay = Invoke-JsonRequest -Method Post `
        -Uri "$BackendUrl/api/v1/teacher/courses" `
        -Headers $courseHeaders -Body $coursePayload -ExpectedStatus @(201)
    if ($course.id -ne $courseReplay.id) {
        throw 'Course replay returned a different resource id.'
    }
    $courseId = $course.id

    [void](Invoke-JsonRequest -Method Patch `
        -Uri "$SupabaseUrl/rest/v1/courses?id=eq.$courseId" `
        -Headers $serviceHeaders -Body @{ cover_status = 'ready' })

    $moduleHeaders = $authHeaders.Clone()
    $moduleHeaders['Idempotency-Key'] = $intentKeys.module
    $modulePayload = @{ title = 'CI Module'; order_index = 0; status = 'ready' }
    $module = Invoke-JsonRequest -Method Post `
        -Uri "$BackendUrl/api/v1/teacher/courses/$courseId/modules" `
        -Headers $moduleHeaders -Body $modulePayload -ExpectedStatus @(201)
    $moduleReplay = Invoke-JsonRequest -Method Post `
        -Uri "$BackendUrl/api/v1/teacher/courses/$courseId/modules" `
        -Headers $moduleHeaders -Body $modulePayload -ExpectedStatus @(201)
    if ($module.id -ne $moduleReplay.id) {
        throw 'Module replay returned a different resource id.'
    }

    $lessonHeaders = $authHeaders.Clone()
    $lessonHeaders['Idempotency-Key'] = $intentKeys.lesson
    $lessonPayload = @{
        title = 'CI Lesson'
        description = 'Synthetic local lesson'
        order_index = 0
        status = 'draft'
        is_required = $true
    }
    $lessonUri = "$BackendUrl/api/v1/teacher/courses/$courseId/modules/$($module.id)/lessons"
    $lesson = Invoke-JsonRequest -Method Post -Uri $lessonUri `
        -Headers $lessonHeaders -Body $lessonPayload -ExpectedStatus @(201)
    $lessonReplay = Invoke-JsonRequest -Method Post -Uri $lessonUri `
        -Headers $lessonHeaders -Body $lessonPayload -ExpectedStatus @(201)
    if ($lesson.id -ne $lessonReplay.id) {
        throw 'Lesson replay returned a different resource id.'
    }

    $blockHeaders = $authHeaders.Clone()
    $blockHeaders['Idempotency-Key'] = $intentKeys.block
    $blockPayload = @{
        block_type = 'text'
        content = @{ title = 'CI Content'; text = 'Idempotent authoring content.' }
        order_index = 0
        status = 'ready'
    }
    $blockUri = "$BackendUrl/api/v1/teacher/courses/$courseId/lessons/$($lesson.id)/blocks"
    $block = Invoke-JsonRequest -Method Post -Uri $blockUri `
        -Headers $blockHeaders -Body $blockPayload -ExpectedStatus @(201)
    $blockReplay = Invoke-JsonRequest -Method Post -Uri $blockUri `
        -Headers $blockHeaders -Body $blockPayload -ExpectedStatus @(201)
    if ($block.id -ne $blockReplay.id) {
        throw 'Lesson block replay returned a different resource id.'
    }

    $publishHeaders = $authHeaders.Clone()
    $publishHeaders['Idempotency-Key'] = $intentKeys.publish
    $publishPayload = @{ change_summary = 'Local CI publication' }
    $published = Invoke-JsonRequest -Method Post `
        -Uri "$BackendUrl/api/v1/teacher/courses/$courseId/publish" `
        -Headers $publishHeaders -Body $publishPayload
    $publishedReplay = Invoke-JsonRequest -Method Post `
        -Uri "$BackendUrl/api/v1/teacher/courses/$courseId/publish" `
        -Headers $publishHeaders -Body $publishPayload
    if ($published.id -ne $publishedReplay.id -or $published.status -ne 'published') {
        throw 'Publication replay did not return the same published course.'
    }

    $versions = @(Invoke-JsonRequest -Method Get `
        -Uri "$SupabaseUrl/rest/v1/course_versions?course_id=eq.$courseId&select=id,is_current" `
        -Headers $serviceHeaders)
    $modules = @(Invoke-JsonRequest -Method Get `
        -Uri "$SupabaseUrl/rest/v1/modules?course_id=eq.$courseId&select=id" `
        -Headers $serviceHeaders)
    $lessons = @(Invoke-JsonRequest -Method Get `
        -Uri "$SupabaseUrl/rest/v1/lessons?course_id=eq.$courseId&select=id" `
        -Headers $serviceHeaders)
    $blocks = @(Invoke-JsonRequest -Method Get `
        -Uri "$SupabaseUrl/rest/v1/lesson_blocks?course_id=eq.$courseId&select=id" `
        -Headers $serviceHeaders)
    $history = @(Invoke-JsonRequest -Method Get `
        -Uri "$SupabaseUrl/rest/v1/course_status_history?course_id=eq.$courseId&to_status=eq.published&select=id" `
        -Headers $serviceHeaders)
    $currentVersions = @($versions | Where-Object { $_.is_current -eq $true })

    if (
        $versions.Count -ne 1 -or
        $currentVersions.Count -ne 1 -or
        $modules.Count -ne 1 -or
        $lessons.Count -ne 1 -or
        $blocks.Count -ne 1 -or
        $history.Count -ne 1
    ) {
        throw "Unexpected cardinality: versions=$($versions.Count), current=$($currentVersions.Count), modules=$($modules.Count), lessons=$($lessons.Count), blocks=$($blocks.Count), history=$($history.Count)"
    }

    Write-Output 'Teacher authoring E2E passed without duplicate resources or versions.'
}
finally {
    if ($teacherId) {
        $opaqueKeys = @($intentKeys.Values | ForEach-Object {
            ConvertTo-OpaqueKey -Value $_
        })
        Remove-LocalE2eRows -CourseId $courseId -ActorId $teacherId -OpaqueKeys $opaqueKeys
    }
}
