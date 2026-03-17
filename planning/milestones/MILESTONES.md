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

## M4: ML-DSA-OSH Core Attachment

- ML-DSA-OSH source imported into `hw/ip/mldsa_osh/` with provenance notes
- Real `MLDSA_OSH` engine mode attached behind the adapter through project-owned shim logic
- PoC-only static key provisioning path documented and isolated
- Wrapper contract and software behavior preserved
- Local verification explicitly split between deterministic wrapper regression and future mixed-language real-core verification

## M5: Real PS/PL Bring-Up

- PS software communicates with PL registers on target hardware
- End-to-end path exercised using the stable wrapper interface
- Optional real MMIO backend added without removing the fake backend
- Continuous signing loop infrastructure available on the target platform

## M6: PoC Review

- Correctness demonstrated within the verified scope
- Continuous signing soak results documented
- Remaining gaps, risks, and next-step recommendations captured