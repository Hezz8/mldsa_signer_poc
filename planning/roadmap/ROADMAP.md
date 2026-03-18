# Roadmap

## Objective

Establish a credible engineering path from repository bootstrap to a working proof-of-concept post-quantum signature appliance on Zynq UltraScale+.

## Current Phase

The repository is in the STUB-mode real-board bring-up preparation phase. The external API, register map base layout, software sequencing, and wrapper behavior remain stable. Software now contains both fake and real MMIO backends, and hardware now has explicit STUB-mode top-level scaffolding for the first real Zynq image.

## Workstreams

### 1. System definition

- Keep the external signing service contract stable
- Keep the PS-PL register and control protocol synchronized across docs and code
- Keep first-board success criteria limited and explicit

### 2. Software platform

- Maintain the fake backend as the default local development path
- Use the real backend only for target-board probe and STUB selftest work
- Preserve the public software API and gRPC contract

### 3. Hardware platform

- Keep the AXI-Lite wrapper contract stable
- Select engine mode through build-time top-level choice, not runtime software switching
- Use a dedicated STUB-mode board image for the first real bring-up

### 4. Verification and performance

- Maintain unit, simulation, integration, and end-to-end verification layers
- Separate deterministic wrapper regression from target-board execution
- Defer MLDSA_OSH board execution until STUB-mode board validation is complete

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

### Phase E: Imported-core attachment

- ML-DSA-OSH source is imported with provenance recorded
- The adapter gains a real `MLDSA_OSH` mode through project-owned shim logic

### Phase F: Real MMIO scaffolding

- Software gains a practical target-facing MMIO backend
- A safe probe path is available for first PS-to-PL register visibility checks

### Phase G: STUB-mode board readiness

- First board image is explicitly a STUB-mode image
- Real selftest validates the deterministic STUB signature rule
- Board-facing scripts and documentation are ready for first execution

### Phase H: First real STUB execution

- Exercise PS and PL sequencing against the stable wrapper on actual hardware
- Confirm one correct STUB transaction on the board

### Phase I: MLDSA_OSH board work

- Move to MLDSA_OSH-mode bitstreams only after STUB-mode board success
- Validate imported-core behavior on actual target hardware or stronger verification flow