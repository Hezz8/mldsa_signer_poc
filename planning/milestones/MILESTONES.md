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

## M5: Real MMIO Backend And Bring-Up Scaffolding

- Software MMIO layer supports both `fake` and `real` backends
- Real backend supports practical Linux user-space MMIO mapping for target bring-up
- Safe MMIO probe path exists for future register visibility checks on Zynq
- Local software tests still pass without hardware

## M6: STUB-Mode Zynq Bring-Up Readiness

- STUB-mode board-facing top-level scaffold exists
- Engine mode selection is explicitly documented as a build-time choice
- Real STUB selftest verifies the deterministic STUB signature rule
- Board-facing scripts and checklists are ready for first Zynq execution
- MLDSA_OSH board bring-up remains explicitly deferred

## M7: Real STUB-Mode Board Execution

- PS software communicates with PL registers on target hardware
- One STUB transaction completes on the actual board
- STUB signature matches the documented deterministic rule

## M8: MLDSA_OSH Board Bring-Up

- MLDSA_OSH-mode image is exercised only after STUB-mode board validation
- Remaining imported-core board issues are characterized with real data