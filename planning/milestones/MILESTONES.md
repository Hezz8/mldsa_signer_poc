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

## M3: Engine Adapter Stabilization

- Stable AXI-Lite wrapper top established as the PS-visible contract boundary
- `mldsa_engine_adapter` introduced between the wrapper and future core integration
- `STUB` and `CORE_PLACEHOLDER` adapter modes verified in simulation
- Software contracts preserved while hardware internals gain a clean integration seam

## M4: Real PS/PL Bring-Up

- PS software communicates with PL registers on target hardware
- End-to-end path exercised using the stable wrapper interface
- Continuous signing loop infrastructure available

## M5: ML-DSA-OSH Core Attachment

- Real ML-DSA-OSH integration attached behind the engine adapter
- Signature flow verified against known-good vectors
- Adapter and wrapper regressions automated

## M6: PoC Review

- Correctness demonstrated
- Continuous signing soak results documented
- Remaining gaps, risks, and next-step recommendations captured
