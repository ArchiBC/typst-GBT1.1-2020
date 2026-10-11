param([string]$Python = 'python')
$ErrorActionPreference = 'Stop'
$taskRoot = Split-Path -Parent $PSScriptRoot
$taskDependencies = Join-Path $taskRoot '.tools\python'
New-Item -ItemType Directory -Force -Path $taskDependencies | Out-Null
& $Python -m pip install --target $taskDependencies -r (Join-Path $PSScriptRoot 'requirements.txt')
if ($LASTEXITCODE -ne 0) { throw 'Compiler dependency installation failed.' }
& $Python -X utf8 (Join-Path $PSScriptRoot 'bootstrap.py')
if ($LASTEXITCODE -ne 0) { throw 'Font preparation failed.' }
Write-Output 'Ready. Run tools/build.ps1 to compile and verify the open-font book and examples.'
