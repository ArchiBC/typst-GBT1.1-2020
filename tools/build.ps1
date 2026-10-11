param([string]$Python = 'python', [switch]$Render, [ValidateSet('open','reference','both')][string]$FontProfile = 'open')
$ErrorActionPreference = 'Stop'
& $Python -X utf8 (Join-Path $PSScriptRoot 'build.py') --font-profile $FontProfile
if ($LASTEXITCODE -ne 0) { throw 'Build or PDF verification failed.' }
if ($Render) {
    & $Python -X utf8 (Join-Path $PSScriptRoot 'render_outputs.py')
    if ($LASTEXITCODE -ne 0) { throw 'PDF rendering failed.' }
}
