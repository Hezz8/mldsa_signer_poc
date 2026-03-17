# pq-signature-appliance

`pq-signature-appliance` is a hardware/software co-design project for a post-quantum digital signature appliance built around ML-DSA-87 on a Xilinx/AMD Zynq UltraScale+ platform. The long-term goal is a network-accessible signing appliance that accepts a 64-byte pre-hash digest over gRPC, transfers the request from Linux running on the processing system (PS) into programmable logic (PL), and returns an ML-DSA signature produced by dedicated hardware.

The repository now includes:

- a stable PS-visible AXI-Lite wrapper contract
- a mode-selectable hardware engine adapter with `STUB`, `CORE_PLACEHOLDER`, and `MLDSA_OSH` paths
- vendored ML-DSA-OSH source plus a project-owned shim behind the adapter boundary
- a software MMIO layer with both fake and real backend paths
- board bring-up scaffolding for future PS-to-PL validation on Zynq Linux

## Architecture Summary

The proof-of-concept architecture remains a layered HW/SW design:

1. A remote client submits a signing request containing a 64-byte digest.
2. A gRPC daemon on Linux running on the Zynq UltraScale+ PS validates and marshals the request.
3. The daemon writes the request into an AXI-Lite accessible wrapper connected to the PL.
4. The wrapper delegates the request to a generic ML-DSA engine adapter.
5. The selected engine path performs deterministic stub behavior or routes toward the imported ML-DSA-OSH integration.
6. The PS collects completion status and signature data, then returns the result through gRPC or a local fallback harness.

Current hardware boundary:

`AXI-Lite wrapper -> mldsa_engine_adapter -> (STUB | CORE_PLACEHOLDER | MLDSA_OSH)`

Current software boundary:

`client -> daemon -> MMIO abstraction -> (fake backend | real backend)`

## Current Software Backends

- `fake`: deterministic local register model used for development, tests, and local self-test.
- `real`: PoC user-space MMIO backend intended for Linux on Zynq using a `/dev/mem`-style access path.

The default remains `fake`, so local development behavior stays exactly as before.

## Current Bring-Up Strategy

The software stack is now ready for first PS-to-PL register visibility checks on target hardware. The recommended sequence is:

1. Start with a bitstream configured for `STUB` engine mode.
2. Configure `PQSIG_BACKEND=real` and provide the wrapper base address.
3. Run `python -m sw.daemon.main probe-mmio --backend real --mmio-base-addr <addr>`.
4. Only after successful register visibility, run `python -m sw.daemon.main selftest --backend real --mmio-base-addr <addr>`.
5. Move to `MLDSA_OSH` mode only after STUB-mode sequencing is stable.

No real board success is claimed yet in this repository state.

## Deterministic STUB Behavior

The `STUB` path is still deliberately deterministic and non-cryptographic:

- input must be exactly 64 bytes
- `start` transitions the device to `busy`
- after a deterministic two-cycle delay, the device transitions to `done`
- the reported signature length is fixed at 128 bytes
- the fake signature bytes are `STUBSIG || digest || zero padding`, truncated or padded to 128 bytes

This remains the regression and first-board-bring-up baseline.

## Real MMIO Backend Notes

The real backend is practical PoC code, not hardened production access. It assumes:

- Linux user-space access to a memory-mapped device path, default `/dev/mem`
- a known AXI-Lite wrapper base address from the platform design
- little-endian 32-bit register access
- page-aligned mapping behavior from the host kernel

For local testing on non-target hosts, the same backend can map a normal file so register I/O logic can be sanity-tested without real hardware.

## Current MLDSA_OSH Path Status

The repository contains a real imported ML-DSA-OSH source snapshot and a real project-owned shim based on the inspected upstream sign interface. That integration is real in the sense that:

- the upstream source is present in the repository with provenance recorded
- the adapter exposes a real `MLDSA_OSH` mode
- the project-owned shim sequences the inspected upstream sign input order and reorders the output stream into the wrapper-visible signature buffer
- PoC-only static key material is isolated in a dedicated include file and documented as temporary

However, the current local portable simulation flow still cannot fully elaborate the imported sign path because the upstream implementation mixes Verilog and VHDL, while the current user-space toolchain does not include `ghdl` or another mixed-language elaboration flow.

## Project Status

- local fake-mode execution remains working
- software tests remain working without hardware
- the real backend and probe path exist for future target-board bring-up
- the wrapper contract and gRPC API remain stable
- documentation now covers board bring-up sequencing and current blockers
- no full end-to-end PS-to-PL or cryptographic validation has been claimed yet on actual Zynq hardware

## Repository Structure

```text
.
├── README.md
├── docs/
├── hw/
├── sw/
├── scripts/
├── tests/
├── tools/
├── planning/
├── prompts/
├── agents/
└── .codex/
```

Key areas:

- `docs/`: architecture, interface, verification, and board bring-up documentation
- `hw/`: wrapper, adapter, ML-DSA-OSH integration glue, imported IP, and testbench collateral
- `sw/`: daemon, MMIO abstraction, backends, client, proto contract, and tests
- `scripts/`: local verification, doc builds, and target-board probe helpers
- `planning/`: roadmap and milestone tracking across bring-up phases

## Important Phase Boundaries

- The external gRPC API has not changed.
- The fake backend has not been removed.
- The local development and test flow still runs without hardware.
- The real backend exists for board bring-up preparation only.
- Board bring-up should start with `STUB` mode before `MLDSA_OSH` mode.
- The digest-to-message adaptation remains provisional.
- Key provisioning remains PoC-only static preload.

This repository should now be treated as the engineering baseline for the real-MMIO and first-board-bring-up preparation phase.