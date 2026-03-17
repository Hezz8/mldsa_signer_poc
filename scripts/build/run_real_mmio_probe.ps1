param(
    [string]$MmioBaseAddr = $env:PQSIG_MMIO_BASE_ADDR,
    [string]$MmioRegionSize = $env:PQSIG_MMIO_REGION_SIZE,
    [string]$DevmemPath = $env:PQSIG_DEVMEM_PATH,
    [switch]$ClearStatus
)

$ErrorActionPreference = "Stop"
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\.." )).Path
$PythonExe = Join-Path $RepoRoot ".venv\Scripts\python.exe"
if (-not (Test-Path $PythonExe)) {
    throw "Repo-local Python not found at $PythonExe"
}

$argsList = @("-m", "sw.daemon.main", "probe-mmio", "--backend", "real")
if ($MmioBaseAddr) {
    $argsList += @("--mmio-base-addr", $MmioBaseAddr)
}
if ($MmioRegionSize) {
    $argsList += @("--mmio-region-size", $MmioRegionSize)
}
if ($DevmemPath) {
    $argsList += @("--devmem-path", $DevmemPath)
}
if ($ClearStatus) {
    $argsList += "--clear-status"
}

Write-Host "Running real MMIO probe with arguments: $($argsList -join ' ')"
& $PythonExe @argsList
if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}