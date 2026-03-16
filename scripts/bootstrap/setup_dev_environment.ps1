param(
    [switch]$UseRepoVenv = $true
)

$ErrorActionPreference = "Stop"

$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\.." )).Path
Set-Location $RepoRoot

Write-Host "Repository root: $RepoRoot"

if ($UseRepoVenv) {
    if (-not (Test-Path ".venv\Scripts\python.exe")) {
        Write-Host "Creating repo-local virtual environment..."
        python -m venv .venv
    }

    Write-Host "Installing Python dependencies into .venv..."
    .\.venv\Scripts\python -m pip install pytest grpcio grpcio-tools protobuf
    $PythonExe = ".\.venv\Scripts\python.exe"
} else {
    $PythonExe = "python"
}

Write-Host "Tool summary:"
& $PythonExe --version
& $PythonExe -m pip --version
& $PythonExe -m pytest --version
& $PythonExe -c "import grpc; print('grpcio', grpc.__version__)"
& $PythonExe -c "from grpc_tools import protoc; print('grpcio-tools ok')"
& $PythonExe -c "import google.protobuf; print('protobuf', google.protobuf.__version__)"

Write-Host "Suggested next checks:"
Write-Host "  $PythonExe -m unittest discover -s sw/tests -v"
Write-Host "  $PythonExe tools\repo_sanity_check.py"
Write-Host "  $PythonExe -m sw.daemon.main selftest"
Write-Host "  $PythonExe -m sw.client.client --mode local"
