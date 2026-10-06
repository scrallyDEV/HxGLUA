param([switch]$NoPath)
$ErrorActionPreference = 'Stop'
$sdkRoot = $PSScriptRoot
foreach ($dependency in @('python', 'haxe', 'haxelib')) {
    if (-not (Get-Command $dependency -ErrorAction SilentlyContinue)) {
        throw "$dependency is missing. Install Python 3.10+ and Haxe 4.3.7+, then reopen PowerShell."
    }
}
& python -c 'import sys; sys.exit(0 if sys.version_info >= (3, 10) else 1)'
if ($LASTEXITCODE -ne 0) { throw 'Python 3.10 or newer is required.' }
& python (Join-Path $sdkRoot 'tools\hxgmod.py') register
if ($LASTEXITCODE -ne 0) { throw 'Haxelib registration failed.' }
if (-not $NoPath) {
    $userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
    $entries = @($userPath -split ';' | Where-Object { $_ -and $_.TrimEnd('\') -ine $sdkRoot.TrimEnd('\') })
    [Environment]::SetEnvironmentVariable('Path', ((@($sdkRoot) + $entries) -join ';'), 'User')
    $env:Path = "$sdkRoot;$env:Path"
}
& python (Join-Path $sdkRoot 'tools\hxgmod.py') doctor
if ($LASTEXITCODE -ne 0) { throw 'Setup finished, but doctor found a problem. See above.' }
Write-Host 'Setup complete. Open a new terminal to use hxgmod everywhere.'
