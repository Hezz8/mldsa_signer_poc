$ErrorActionPreference = "Stop"

$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\.." )).Path
$OssCadRoot = Join-Path $RepoRoot "tools\third_party\oss-cad-suite\oss-cad-suite"
if (-not (Test-Path $OssCadRoot)) {
    throw "Portable OSS CAD Suite not found at $OssCadRoot"
}

$env:PATH = "$OssCadRoot\bin;$OssCadRoot\lib;$env:PATH"
$BuildDir = Join-Path $RepoRoot "build\sv_stub"
New-Item -ItemType Directory -Force $BuildDir | Out-Null

$Output = Join-Path $BuildDir "tb_axi_lite_wrapper_stub.vvp"
iverilog -g2012 -s tb_axi_lite_wrapper_stub -o $Output `
    (Join-Path $RepoRoot 'hw\wrapper\wrapper_pkg.sv') `
    (Join-Path $RepoRoot 'hw\wrapper\axi_lite_wrapper_stub.sv') `
    (Join-Path $RepoRoot 'hw\tb\tb_axi_lite_wrapper_stub.sv')

vvp $Output
