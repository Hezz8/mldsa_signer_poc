# ADR-0001: Project Scope

- Status: Accepted
- Date: 2026-03-16

## Context

The project needs a clear initial scope so repository work, documentation, and future implementation prompts remain aligned. Without an explicit scope, the effort could drift into premature optimization, full productization, or unbounded security requirements before a proof of concept exists.

## Decision

The project scope for the initial repository and first proof-of-concept phase is:

- Build a post-quantum signature appliance centered on ML-DSA-87
- Target a Xilinx/AMD Zynq UltraScale+ platform
- Expose signing through a gRPC service over Ethernet
- Accept a 64-byte digest as the signing input
- Use Linux on the PS and a hardware signing core in the PL
- Focus on correctness, interface stability, and continuous operation first

The following items are explicitly out of scope for the bootstrap phase:

- Implementing the actual ML-DSA cryptographic core
- Integrating third-party repositories or IP
- Final production key management
- Aggressive throughput optimization
- Production enclosure, manufacturing, or lifecycle support

## Consequences

- The repository is optimized for staged implementation
- Documentation and interfaces can be stabilized before core integration
- Security and performance work can be planned without blocking bootstrap progress
