$ErrorActionPreference = "Stop"

$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\.." )).Path
$OssCadRoot = Join-Path $RepoRoot "tools\third_party\oss-cad-suite\oss-cad-suite"
if (-not (Test-Path $OssCadRoot)) {
    throw "Portable OSS CAD Suite not found at $OssCadRoot"
}

$env:PATH = "$OssCadRoot\bin;$OssCadRoot\lib;$env:PATH"
$BuildDir = Join-Path $RepoRoot "build\sv_wrapper"
New-Item -ItemType Directory -Force $BuildDir | Out-Null

$Output = Join-Path $BuildDir "tb_axi_lite_wrapper.vvp"
iverilog -g2012 -s tb_axi_lite_wrapper -o $Output `
    (Join-Path $RepoRoot 'hw\wrapper\wrapper_pkg.sv') `
    (Join-Path $RepoRoot 'hw\rtl\mldsa_engine_adapter.sv') `
    (Join-Path $RepoRoot 'hw\wrapper\axi_lite_wrapper.sv') `
    (Join-Path $RepoRoot 'hw\tb\tb_axi_lite_wrapper.sv')

vvp $Output
