# Development Environment Setup

This repository uses a conservative setup strategy:

- keep Python dependencies in a repo-local `.venv`
- keep the canonical API contract in `sw/proto/signing.proto`
- prefer `verilator` as the HDL simulator, with `iverilog` as the practical fallback
- prefer `latexmk`, with `pdflatex` or a MiKTeX-based toolchain as the documentation fallback

## Recommended Setup

On Windows PowerShell:

```powershell
.\scripts\bootstrap\setup_dev_environment.ps1
```

On Bash-compatible shells:

```bash
./scripts/bootstrap/setup_dev_environment.sh
```

These scripts:

- create `.venv` if needed
- install `pytest`, `grpcio`, `grpcio-tools`, and `protobuf`
- print a short tool summary

## Quick Verification

With the repo-local environment:

```powershell
.\.venv\Scripts\python -m unittest discover -s sw/tests -v
.\.venv\Scripts\python tools\repo_sanity_check.py
.\.venv\Scripts\python -m sw.daemon.main selftest
.\.venv\Scripts\python -m sw.client.client --mode local
```

## Optional Machine-Level Tooling

- HDL simulation: prefer `verilator`; current practical fallback is `iverilog`
- Documentation build: prefer `latexmk`; fallback is `pdflatex` or MiKTeX

Machine-level installs may require an elevated shell on this host because Chocolatey writes under `C:\ProgramData\chocolatey`.
