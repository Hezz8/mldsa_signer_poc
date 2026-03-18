# Development Environment Setup

This repository uses a conservative setup strategy:

- keep Python dependencies in a repo-local `.venv`
- keep the canonical API contract in `sw/proto/signing.proto`
- prefer `verilator` as the HDL simulator, with `iverilog` as the practical fallback
- prefer `latexmk`, with `pdflatex` or a MiKTeX-based toolchain as the documentation fallback
- keep target-board MMIO access behind a selectable backend so local fake-mode development remains intact

## Quick Verification

```powershell
.\.venv\Scripts\python -m unittest discover -s sw/tests -v
.\.venv\Scripts\python tools\repo_sanity_check.py
.\.venv\Scripts\python -m sw.daemon.main selftest
.\.venv\Scripts\python -m sw.client.client --mode local
powershell -ExecutionPolicy Bypass -File scripts\build\run_sv_stub_tb.ps1
powershell -ExecutionPolicy Bypass -File scripts\docs\build_docs.ps1
```

## First Target-Board Inputs

The STUB-mode bring-up scripts require:

- `PQSIG_MMIO_BASE_ADDR`: physical wrapper base address from the platform design
- optional `PQSIG_MMIO_REGION_SIZE`: wrapper span in bytes if non-default
- optional `PQSIG_DEVMEM_PATH`: alternative MMIO device path if not using `/dev/mem`

## First Target-Board Commands

Probe only:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\build\run_real_mmio_probe.ps1 -MmioBaseAddr 0xA0000000
```

Explicit STUB selftest:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\build\run_real_stub_selftest.ps1 -MmioBaseAddr 0xA0000000
```

The first board image shall be a STUB-mode image. Do not start real board bring-up with an MLDSA_OSH-mode bitstream.