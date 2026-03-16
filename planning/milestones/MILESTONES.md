# Milestones

## M0: Repository Bootstrap

- Top-level repository structure created
- Core documentation package created in LaTeX
- Agent rules, workflows, and handoff conventions defined

## M1: Interface Baseline

- `sw/proto/signing.proto` reviewed and versioned
- Initial register map and wrapper specification reviewed
- External and internal interface assumptions aligned

## M2: Executable Stub Skeleton

- Python MMIO abstraction and fake backend implemented
- Deterministic stub signing path available without target hardware
- Service and local client contract verified with tests
- AXI-Lite wrapper stub and simple testbench created

## M3: Software Skeleton Expansion

- Linux daemon skeleton hardened around the documented device contract
- Optional gRPC binding path enabled in a fully provisioned development environment
- Observability and error handling expanded

## M4: Real PS/PL Bring-Up

- PS software communicates with PL registers on target hardware
- End-to-end path exercised using the real register interface
- Continuous signing loop infrastructure available

## M5: ML-DSA Core Integration

- Hardware signing core connected behind stable wrapper interface
- Signature flow verified against known-good vectors
- Integration regressions automated

## M6: PoC Review

- Correctness demonstrated
- Continuous signing soak results documented
- Remaining gaps, risks, and next-step recommendations captured
