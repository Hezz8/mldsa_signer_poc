# ADR-0003: Initial PoC Target

- Status: Accepted
- Date: 2026-03-16

## Context

A first implementation target is needed to prioritize engineering effort. Trying to optimize throughput or security hardening before proving end-to-end correctness would increase risk and slow integration.

## Decision

The initial proof of concept will optimize for:

- Correct end-to-end signing behavior
- Continuous signing operation without service collapse
- Clear observability of failures and timeouts
- Stable external and internal interfaces

The initial proof of concept will not optimize for:

- Maximum signatures per second
- Minimum latency
- Final key storage architecture
- Final hardened service deployment model

For the PoC, private key material may be hardcoded or otherwise statically provisioned within PL implementation artifacts strictly for bring-up and controlled testing.

## Consequences

- Verification will emphasize repeatability, long-duration operation, and interface correctness
- Performance modeling remains important, but measured throughput is not the primary acceptance gate
- The architecture leaves room for later key-management and throughput upgrades
