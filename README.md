# pq-signature-appliance

`pq-signature-appliance` is a hardware/software co-design project for a post-quantum digital signature appliance built around ML-DSA-87 on a Xilinx/AMD Zynq UltraScale+ platform. The long-term goal is a network-accessible signing appliance that accepts a 64-byte pre-hash digest over gRPC, transfers the request from Linux running on the processing system (PS) into programmable logic (PL), and returns an ML-DSA signature produced by dedicated hardware.

The repository now includes the first real third-party hardware-core integration phase. ML-DSA-OSH source has been imported under `hw/ip/mldsa_osh/`, and the PL architecture now supports a real engine path behind the existing adapter boundary. The software contract, register map base layout, and wrapper-visible behavior remain stable.

## Architecture Summary

The proof-of-concept architecture remains a layered HW/SW design:

1. A remote client submits a signing request containing a 64-byte digest.
2. A gRPC daemon on Linux running on the Zynq UltraScale+ PS validates and marshals the request.
3. The daemon writes the request into an AXI-Lite accessible wrapper connected to the PL.
4. The wrapper delegates the request to a generic ML-DSA engine adapter.
5. The adapter selects one of three engine modes:
   - `STUB`
   - `CORE_PLACEHOLDER`
   - `MLDSA_OSH`
6. The PS collects completion status and signature data, then returns the result through gRPC or the local fallback harness.

For the initial proof of concept, the focus remains correctness, deterministic interfaces, bring-up practicality, and continuous signing operation. Peak throughput optimization is explicitly deferred.

## Current Hardware Boundary

The current PL-side architecture is organized as:

`AXI-Lite wrapper -> mldsa_engine_adapter -> selected engine path`

For the real-core path, the selected engine path is currently:

`AXI-Lite wrapper -> mldsa_engine_adapter -> mldsa_osh_shim -> imported ML-DSA-OSH sign path`

The wrapper remains the PS-visible contract boundary. The adapter and shim isolate wrapper-visible control and register semantics from ML-DSA-OSH-specific stream ordering, key segmentation, output ordering, and future implementation churn.

## Current Engine Modes

- `STUB`: deterministic fake signature used for software regression and wrapper contract testing.
- `CORE_PLACEHOLDER`: deterministic non-cryptographic seam-testing mode.
- `MLDSA_OSH`: real attachment path to the imported ML-DSA-OSH source through a project-owned shim.

## Exact STUB Behavior

The `STUB` path is deliberately deterministic and non-cryptographic:

- input must be exactly 64 bytes
- `start` transitions the device to `busy`
- after a deterministic two-cycle delay, the device transitions to `done`
- the reported signature length is fixed at 128 bytes
- the fake signature bytes are `STUBSIG || digest || zero padding`, truncated or padded to 128 bytes

## Current MLDSA_OSH Path Status

The repository now contains a real imported ML-DSA-OSH source snapshot and a real project-owned shim based on the inspected upstream sign interface. That integration is real in the sense that:

- the upstream source is present in the repository with provenance recorded
- the adapter exposes a real `MLDSA_OSH` mode
- the project-owned shim sequences the inspected upstream sign input order and reorders the output stream into the wrapper-visible signature buffer
- PoC-only static key material is isolated in a dedicated include file and documented as temporary

However, the current local portable simulation flow cannot fully elaborate the imported sign path because the upstream implementation mixes Verilog and VHDL, while the current user-space toolchain does not include `ghdl` or another mixed-language elaboration flow. For that reason:

- `STUB` and `CORE_PLACEHOLDER` remain the deterministic regression path
- the local wrapper testbench also exercises the honest `MLDSA_OSH` fallback behavior that reports engine error when the real mixed-language core is not compiled in
- full local cryptographic correctness is not yet claimed

## Planned HW/SW Stack

- Platform: Xilinx/AMD Zynq UltraScale+
- PS software environment: Embedded Linux on ARM application cores
- Network service: gRPC signing daemon over Ethernet
- PS/PL boundary: AXI-Lite control and status wrapper
- Hardware accelerator boundary: stable ML-DSA engine adapter inside PL
- Real hardware accelerator basis: imported ML-DSA-OSH sign path adapted for ML-DSA-87 PoC integration
- PoC key strategy: static secret-key image for controlled bring-up only, explicitly non-production

## Project Status

- Executable software skeleton remains working and unchanged at the public API level
- Stable wrapper-to-engine adapter boundary remains intact
- ML-DSA-OSH source is imported under `hw/ip/mldsa_osh/`
- Project-owned RTL shim translates the stable adapter contract to the inspected upstream sign-stream interface
- Documentation, planning, and verification collateral have been updated for the imported-core phase
- Full local mixed-language simulation of the real upstream sign path is still blocked by tooling availability

## Project Phases

1. Repository bootstrap and engineering baseline
2. Interface freezing and wrapper definition
3. Executable stub implementation for software and hardware sequencing validation
4. Hardware adapter stabilization for future core integration
5. Real ML-DSA-OSH attachment behind the engine adapter
6. PS-to-real-wrapper MMIO backend and target-board bring-up
7. System integration, verification, and performance refinement
8. Security hardening, operationalization, and production readiness review

## Repository Structure

```text
.
├── README.md
├── LICENSE
├── .gitignore
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

- `docs/`: LaTeX documentation package for requirements, architecture, interfaces, verification, and performance
- `hw/`: wrapper, engine adapter, ML-DSA-OSH integration glue, imported IP, simulation, and testbench collateral
- `sw/`: daemon, MMIO abstraction, client, proto contract, and tests
- `planning/`: roadmap, milestones, architectural decisions, and risk register
- `prompts/`: implementation and bring-up prompt scaffolding for later phases
- `agents/` and `.codex/`: multi-agent roles, handoff conventions, repository rules, and working context

## How Future Work Will Be Organized

Major design choices should still be captured in planning decisions before substantial implementation changes. Architecture-affecting changes must update the corresponding LaTeX documents, inspection notes, and interface specifications in the same workstream.

Near-term implementation work should proceed in this order:

1. Keep the proto, software MMIO API, wrapper contract, and register map stable.
2. Preserve `STUB` mode as the deterministic regression and bring-up path.
3. Add a real Linux MMIO backend for target hardware while keeping the fake backend intact.
4. Complete mixed-language verification or synthesis-backed validation of the imported ML-DSA-OSH path.
5. Bring the real wrapper and real engine path up on Zynq UltraScale+ hardware.

## Important Phase Boundaries

- The external gRPC API has not changed.
- The public Python software behavior has not changed.
- The wrapper base register layout remains stable.
- The `SIG_DATA` window has been compatibly extended to cover the largest supported engine result so the real ML-DSA-87 signature can be surfaced without introducing a new software-visible register bank.
- `STUB` mode remains the deterministic regression path.
- The imported ML-DSA-OSH path is integrated behind the adapter, but full local cryptographic correctness is not yet claimed in the current portable tool flow.

This repository should now be treated as the authoritative engineering baseline for the imported-core integration phase leading into real PS/PL bring-up on target hardware.