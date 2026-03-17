# Roadmap

## Objective

Establish a credible engineering path from repository bootstrap to a working proof-of-concept post-quantum signature appliance on Zynq UltraScale+.

## Current Phase

The repository is in the real-MMIO and board-bring-up preparation phase. The external API, register map base layout, software sequencing, and wrapper behavior remain stable. ML-DSA-OSH source is already imported behind the hardware adapter, and software now includes a target-facing real backend while still preserving the local fake backend.

## Workstreams

### 1. System definition

- Keep the external signing service contract stable
- Keep the PS-PL register and control protocol synchronized across docs and code
- Capture non-functional expectations for reliability and maintainability

### 2. Software platform

- Maintain the transport-independent service core and MMIO device layer
- Keep the fake backend as the default local development path
- Use the new real backend for target-board bring-up without changing the public software API

### 3. Hardware platform

- Keep the AXI-Lite wrapper contract stable
- Keep the engine adapter as the only intended attachment point for ML-DSA-OSH integration
- Preserve `STUB` mode as the first real-board bring-up target

### 4. Verification and performance

- Maintain unit, simulation, integration, and end-to-end verification layers
- Separate deterministic wrapper regression from real imported-core verification
- Add target-board register visibility and sequencing checks incrementally

### 5. Security hardening

- Replace PoC static key handling with a production-grade key-management approach later
- Replace PoC MMIO access mechanisms with a more controlled deployment approach later
- Add robustness features for malformed input and fault handling

## Sequencing

### Phase A: Bootstrap

- Repository, docs, rules, and planning created
- No crypto implementation

### Phase B: Interface definition

- Proto and register contracts reviewed
- Wrapper and daemon interfaces stable enough for parallel work

### Phase C: Executable stub

- Software daemon path exercises a deterministic fake backend
- Hardware wrapper and simple testbench validate the register contract
- Local tests validate busy, done, and signature readback behavior

### Phase D: Adapter stabilization

- Stable wrapper top and engine adapter introduced in RTL
- `STUB` and `CORE_PLACEHOLDER` modes validate the future integration seam
- The software contract remains unchanged while hardware internals become more modular

### Phase E: Imported-core attachment

- ML-DSA-OSH source is imported with provenance recorded
- The adapter gains a real `MLDSA_OSH` mode through project-owned shim logic
- Wrapper semantics and software behavior remain stable

### Phase F: Real MMIO scaffolding

- Software gains a practical target-facing MMIO backend
- A safe probe path is available for first PS-to-PL register visibility checks
- Local development remains on the fake backend by default

### Phase G: Real bring-up

- Exercise PS and PL sequencing against the stable wrapper implementation on actual hardware
- Start with `STUB` mode on target before attempting `MLDSA_OSH` mode
- Validate the imported-core path on actual target hardware or a stronger verification flow

### Phase H: Refinement

- Throughput optimization
- Security posture improvement
- Documentation and review updates