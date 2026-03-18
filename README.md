# pq-signature-appliance

`pq-signature-appliance` is a hardware/software co-design project for a post-quantum digital signature appliance built around ML-DSA-87 on a Xilinx/AMD Zynq UltraScale+ platform. The long-term goal is a network-accessible signing appliance that accepts a 64-byte pre-hash digest over gRPC, transfers the request from Linux running on the processing system (PS) into programmable logic (PL), and returns an ML-DSA signature produced by dedicated hardware.

The repository now includes:

- a stable PS-visible AXI-Lite wrapper contract
- a mode-selectable hardware engine adapter with `STUB`, `CORE_PLACEHOLDER`, and `MLDSA_OSH` paths
- vendored ML-DSA-OSH source plus a project-owned shim behind the adapter boundary
- a software MMIO layer with both fake and real backend paths
- explicit STUB-mode board bring-up scaffolding for the first real Zynq interaction

## Architecture Summary

Current hardware boundary:

`AXI-Lite wrapper -> mldsa_engine_adapter -> (STUB | CORE_PLACEHOLDER | MLDSA_OSH)`

Current software boundary:

`client -> daemon -> MMIO abstraction -> (fake backend | real backend)`

The public gRPC API and the wrapper-visible register contract remain unchanged.

## First Real Board Target

The first real board bring-up target is `STUB` mode only.

Success for that phase means exactly two things:

1. the wrapper is visible from Linux through the real backend
2. one explicit STUB selftest transaction returns the documented deterministic fake signature

`MLDSA_OSH` mode is explicitly deferred until after that STUB-mode board validation succeeds.

## How STUB Mode Is Built

There is no runtime register-mode switch in the current hardware.

Engine mode is selected at compile time or synthesis time through the top-level used for the board image. The first board image shall use:

- `hw/rtl/pqsig_top_stub_mode.sv`

A future MLDSA image may use:

- `hw/rtl/pqsig_top_mldsa_osh_mode.sv`

This keeps the wrapper contract unchanged while making bitstream intent explicit.

## Real-Board Bring-Up Commands

Safe register probe on target hardware:

```powershell
python -m sw.daemon.main probe-mmio --backend real --mmio-base-addr <addr>
```

Explicit STUB selftest on target hardware:

```powershell
python -m sw.daemon.main selftest --backend real --mmio-base-addr <addr>
```

The selftest writes a known 64-byte digest, starts one operation, waits for completion, reads the signature, and verifies the exact STUB rule:

`STUBSIG || digest || zero padding`

## Current Development Modes

- `fake` backend: default local path for development, tests, local selftest, and client smoke checks
- `real` backend: PoC `/dev/mem`-style path intended for Linux on Zynq once a real AXI-Lite base address is available

The fake backend and local development flow remain intact.

## Current Claim Boundary

The repository is now prepared for first real board execution in STUB mode, but no actual board success is claimed yet in this repository state.

What is ready now:

- STUB-mode board-facing top-level scaffold
- compile-time engine-mode selection notes
- safe real-backend probe path
- explicit real STUB selftest path
- board bring-up documentation and scripts

What still depends on real hardware:

- AXI-Lite base-address assignment from the platform design
- bitstream generation and loading on Zynq
- Linux `/dev/mem` access and permissions on the target image
- actual PS-to-PL register visibility
- actual STUB transaction completion on the board

## Important Phase Boundaries

- The external gRPC API has not changed.
- The fake backend has not been removed.
- Local software tests still run without hardware.
- First real board bring-up must use `STUB` mode.
- `MLDSA_OSH` board work is deferred until after STUB validation.
- The digest-to-message adaptation remains provisional.
- Key provisioning remains PoC-only static preload.

This repository should now be treated as the engineering baseline for first real Zynq STUB-mode bring-up.