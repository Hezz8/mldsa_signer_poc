$ErrorActionPreference = "Stop"

$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\.." )).Path
$OssCadRoot = Join-Path $RepoRoot "tools\third_party\oss-cad-suite\oss-cad-suite"
if (Test-Path $OssCadRoot) {
    $env:PATH = "$OssCadRoot\bin;$OssCadRoot\lib;$env:PATH"
}

$Ghdl = Get-Command ghdl -ErrorAction SilentlyContinue
if (-not $Ghdl) {
    Write-Host "MLDSA-OSH real-core simulation is blocked in the current local flow."
    Write-Host "Reason: the imported upstream signing path under hw/ip/mldsa_osh/upstream/ref_combined/src mixes Verilog (*.v) and VHDL (*.vhd), but the current portable toolchain does not provide ghdl or another mixed-language elaboration flow."
    Write-Host "The stable wrapper testbench still covers STUB, CORE_PLACEHOLDER, and the honest MLDSA_OSH fallback path through scripts/build/run_sv_stub_tb.ps1."
    exit 1
}

Write-Host "ghdl was found at $($Ghdl.Source), but a mixed-language MLDSA-OSH elaboration recipe is not yet automated in this repo script."
Write-Host "Use docs/architecture/MLDSA_OSH_Inspection_Notes.md and docs/architecture/MLDSA_OSH_Integration_Guide.tex as the integration baseline before adding a full mixed-language regression script."
exit 1