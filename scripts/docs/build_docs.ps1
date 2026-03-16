$ErrorActionPreference = "Stop"

$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\.." )).Path
$DocsDir = Join-Path $RepoRoot "docs"
$BuildDir = Join-Path $DocsDir "build"
New-Item -ItemType Directory -Force $BuildDir | Out-Null

$TectonicExe = Join-Path $RepoRoot "tools\third_party\tectonic\tectonic.exe"
$LocalOssCad = Join-Path $RepoRoot "tools\third_party\oss-cad-suite\oss-cad-suite"
if (Test-Path $LocalOssCad) {
    $env:PATH = "$LocalOssCad\bin;$LocalOssCad\lib;$env:PATH"
}

Push-Location $DocsDir
try {
    if (Test-Path $TectonicExe) {
        & $TectonicExe --outdir $BuildDir main.tex
    } elseif (Get-Command latexmk -ErrorAction SilentlyContinue) {
        latexmk -pdf -interaction=nonstopmode -output-directory=$BuildDir main.tex
    } elseif (Get-Command pdflatex -ErrorAction SilentlyContinue) {
        pdflatex -interaction=nonstopmode -output-directory=$BuildDir main.tex
        pdflatex -interaction=nonstopmode -output-directory=$BuildDir main.tex
    } else {
        throw "No local TeX engine found. Expected tools/third_party/tectonic/tectonic.exe, latexmk, or pdflatex."
    }
} finally {
    Pop-Location
}

Write-Host "Documentation build complete: $BuildDir"
