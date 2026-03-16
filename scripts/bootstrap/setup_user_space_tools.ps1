$ErrorActionPreference = "Stop"

$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\.." )).Path
$ThirdParty = Join-Path $RepoRoot "tools\third_party"
$Downloads = Join-Path $ThirdParty "downloads"
New-Item -ItemType Directory -Force $ThirdParty, $Downloads | Out-Null

$OssCadAsset = Join-Path $Downloads "oss-cad-suite-windows-x64-20260316.exe"
$TectonicAsset = Join-Path $Downloads "tectonic-0.15.0-x86_64-pc-windows-msvc.zip"
$OssCadUrl = "https://github.com/YosysHQ/oss-cad-suite-build/releases/download/2026-03-16/oss-cad-suite-windows-x64-20260316.exe"
$TectonicUrl = "https://github.com/tectonic-typesetting/tectonic/releases/download/tectonic%400.15.0/tectonic-0.15.0-x86_64-pc-windows-msvc.zip"

if (-not (Test-Path $OssCadAsset)) {
    Write-Host "Downloading OSS CAD Suite..."
    Invoke-WebRequest -Uri $OssCadUrl -OutFile $OssCadAsset
}

if (-not (Test-Path (Join-Path $ThirdParty "oss-cad-suite\oss-cad-suite\bin\iverilog.exe"))) {
    Write-Host "Extracting OSS CAD Suite..."
    New-Item -ItemType Directory -Force (Join-Path $ThirdParty "oss-cad-suite") | Out-Null
    & $OssCadAsset -y "-o$ThirdParty\oss-cad-suite"
}

if (-not (Test-Path $TectonicAsset)) {
    Write-Host "Downloading Tectonic..."
    Invoke-WebRequest -Uri $TectonicUrl -OutFile $TectonicAsset
}

if (-not (Test-Path (Join-Path $ThirdParty "tectonic\tectonic.exe"))) {
    Write-Host "Extracting Tectonic..."
    Expand-Archive -Path $TectonicAsset -DestinationPath (Join-Path $ThirdParty "tectonic") -Force
}

Write-Host "Portable tool setup complete."
$OssCadRoot = Join-Path $ThirdParty "oss-cad-suite\oss-cad-suite"
$env:PATH = "$OssCadRoot\bin;$OssCadRoot\lib;$env:PATH"
Write-Host "HDL check:"
iverilog -V
Write-Host "Docs check:"
& (Join-Path $ThirdParty "tectonic\tectonic.exe") --version