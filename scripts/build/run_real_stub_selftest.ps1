param(
    [Parameter(Mandatory = $true)]
    [string]$MmioBaseAddr,
    [string]$MmioRegionSize = $env:PQSIG_MMIO_REGION_SIZE,
    [string]$DevmemPath = $env:PQSIG_DEVMEM_PATH,
    [string]$TimeoutS = $env:PQSIG_TIMEOUT_S
)

$ErrorActionPreference = "Stop"
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\.." )).Path
$PythonExe = Join-Path $RepoRoot ".venv\Scripts\python.exe"
if (-not (Test-Path $PythonExe)) {
    throw "Repo-local Python not found at $PythonExe"
}

$argsList = @("-m", "sw.daemon.main", "selftest", "--backend", "real", "--mmio-base-addr", $MmioBaseAddr)
if ($MmioRegionSize) {
    $argsList += @("--mmio-region-size", $MmioRegionSize)
}
if ($DevmemPath) {
    $argsList += @("--devmem-path", $DevmemPath)
}
if ($TimeoutS) {
    $argsList += @("--timeout-s", $TimeoutS)
}

Write-Host "Running real STUB selftest with arguments: $($argsList -join ' ')"
& $PythonExe @argsList
if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}