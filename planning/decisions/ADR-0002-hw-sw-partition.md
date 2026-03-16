# ADR-0002: Hardware/Software Partition

- Status: Accepted
- Date: 2026-03-16

## Context

The appliance must combine network-facing service logic with deterministic low-level control of a future ML-DSA hardware implementation. The partition must support iterative development while preserving a clean system boundary across PS and PL.

## Decision

The system will use a hardware/software co-design partition:

- Linux on the Zynq UltraScale+ PS hosts the gRPC daemon, request validation, orchestration, logging, and system integration logic
- FPGA logic in the PL hosts the ML-DSA signing datapath
- A simple AXI-Lite wrapper provides the control and status interface between software and hardware for the proof of concept

The PS is responsible for:

- Network ingress and egress
- Service-level error handling
- MMIO sequencing
- Timeout and health supervision

The PL is responsible for:

- Request acceptance from the wrapper
- Signing operation execution
- Status and signature result exposure

## Consequences

- Hardware and software teams can work in parallel once the wrapper contract is stable
- The initial interface favors simplicity over absolute throughput
- Future higher-bandwidth interfaces remain possible without invalidating early software abstractions
