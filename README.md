# pq-signature-appliance

`pq-signature-appliance` is a hardware/software co-design project for a post-quantum digital signature appliance built around ML-DSA-87 on a Xilinx/AMD Zynq UltraScale+ platform. The long-term goal is a network-accessible signing appliance that accepts a 64-byte pre-hash digest over gRPC, transfers the request from Linux running on the processing system (PS) into programmable logic (PL), and returns an ML-DSA signature produced by a dedicated hardware signing core.

The repository has now advanced past documentation-only bootstrap and includes the first executable system skeleton. The current implementation is still intentionally stubbed: it exercises the external request path, MMIO sequencing, register behavior, and signature readback without integrating any real ML-DSA cryptographic implementation.

## Architecture Summary

The proof-of-concept architecture remains a layered HW/SW design:

1. A remote client submits a signing request containing a 64-byte digest.
2. A gRPC daemon on Linux running on the Zynq UltraScale+ PS validates and marshals the request.
3. The daemon writes the request into an AXI-Lite accessible wrapper connected to the PL.
4. The current stub path synthesizes a deterministic fake signature instead of invoking a real ML-DSA core.
5. The PS collects completion status and signature data, then returns the result through gRPC or a local fallback harness.

For the initial proof of concept, the focus is correctness, deterministic interfaces, and continuous signing operation. Peak throughput optimization is explicitly deferred.

## Current Executable Skeleton

The repository now includes:

- a Python MMIO abstraction with a backend interface and deterministic fake backend
- a transport-independent signing service layer
- an optional gRPC server/client path that is ready for real bindings once `grpcio`, `grpcio-tools`, and `protobuf` are installed
- a dependency-free local self-test and local client path for immediate execution in constrained environments
- a SystemVerilog AXI-Lite wrapper stub and matching testbench
- Python unit and contract tests that do not require target hardware

## Stub Signing Behavior

The stub signing path is deliberately deterministic and non-cryptographic:

- input must be exactly 64 bytes
- `start` transitions the device to `busy`
- after a deterministic two-tick or two-cycle delay, the device transitions to `done`
- the reported signature length is fixed at 128 bytes in the current stub phase
- the fake signature bytes are `STUBSIG || digest || zero padding` truncated or padded to 128 bytes

This behavior exists only to validate interfaces, register sequencing, software orchestration, and test infrastructure.

## Planned HW/SW Stack

- Platform: Xilinx/AMD Zynq UltraScale+
- PS software environment: Embedded Linux on ARM application cores
- Network service: gRPC signing daemon over Ethernet
- PS/PL boundary: AXI-Lite control and status wrapper
- Hardware accelerator: future ML-DSA-87 signing core in PL
- PoC key strategy: provisioned or hardcoded key material in PL for bring-up only, not implemented yet

## Project Status

- Executable stub skeleton for sequencing and interface validation
- Architecture, requirements, interface, verification, and performance baselines remain authoritative
- Repository conventions established for iterative work with Codex and multiple agents
- No external IP or crypto implementation integrated yet

## Project Phases

1. Repository bootstrap and engineering baseline
2. Interface freezing and wrapper definition
3. Executable stub implementation for software/hardware sequencing validation
4. Real hardware wrapper refinement and simulation infrastructure expansion
5. ML-DSA core integration and bring-up
6. System integration, verification, and performance refinement
7. Security hardening, operationalization, and production readiness review

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
- `hw/`: wrapper stub, RTL placeholders, simulation, and testbench collateral
- `sw/`: daemon, MMIO abstraction, client, proto contract, and tests
- `planning/`: roadmap, milestones, architectural decisions, and risk register
- `prompts/`: implementation and bring-up prompt scaffolding for later phases
- `agents/` and `.codex/`: multi-agent roles, handoff conventions, repository rules, and working context

## How Future Work Will Be Organized

Major design choices should still be captured in planning decisions before substantial implementation changes. Architecture-affecting changes must update the corresponding LaTeX documents, interface specifications, and rule files in the same workstream. Hardware, software, and verification work are intentionally separated so multiple contributors or agents can progress in parallel while preserving a common system contract.

Near-term implementation work should proceed in this order:

1. Keep the proto, register map, wrapper stub, and software MMIO source of truth aligned.
2. Expand the software daemon and observability around the stubbed path.
3. Replace the fake backend with real PS/PL access on the target platform.
4. Replace the wrapper stub datapath with the future ML-DSA hardware integration while preserving the visible contract.

## Important Phase Boundaries

- No actual ML-DSA implementation is present yet.
- No external repository, vendor IP drop, or generated hardware project has been integrated.
- The current signing behavior is deterministic scaffolding, not cryptography.
- The gRPC transport binding is dependency-gated in the current environment; the local execution path remains available immediately.

This repository should be treated as the authoritative engineering baseline for the stub integration phase leading into real hardware bring-up.
