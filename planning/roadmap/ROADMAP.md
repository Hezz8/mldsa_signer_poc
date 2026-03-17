# Roadmap

## Objective

Establish a credible engineering path from repository bootstrap to a working proof-of-concept post-quantum signature appliance on Zynq UltraScale+.

## Current Phase

The repository is in the imported-core integration phase. The external API, register map base layout, software sequencing, and wrapper behavior remain stable. ML-DSA-OSH source is now imported under `hw/ip/mldsa_osh/`, and the PL-side architecture includes a real adapter and shim path for ML-DSA-87 signing. Full local simulation of the imported sign path remains constrained by mixed-language tooling availability.

## Workstreams

### 1. System definition

- Keep the external signing service contract stable
- Keep the PS/PL register and control protocol synchronized across docs and code
- Capture non-functional expectations for reliability and maintainability

### 2. Software platform

- Maintain the transport-independent service core and MMIO device layer
- Keep the optional gRPC binding path aligned with the canonical proto
- Preserve the fake backend while adding a future real MMIO backend only when the target bring-up phase starts

### 3. Hardware platform

- Keep the AXI-Lite wrapper contract stable
- Keep the engine adapter as the only intended attachment point for ML-DSA-OSH integration
- Keep project-owned shim logic separate from the vendored third-party source
- Preserve `STUB` mode while the real core path matures

### 4. Verification and performance

- Maintain unit, simulation, integration, and end-to-end verification layers
- Separate deterministic wrapper regression from real imported-core verification
- Continue refining realistic throughput and latency models
- Prepare continuous signing and stability campaigns on hardware

### 5. Security hardening

- Replace PoC static key handling with a production-grade key-management approach later
- Review privilege boundaries and operational controls
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
- Local verification remains limited to deterministic wrapper regression plus honest fallback checks until mixed-language simulation or synthesis-backed validation is available

### Phase F: Real bring-up

- Replace the fake backend with real MMIO access on target hardware while preserving the software API
- Exercise PS and PL sequencing against the stable wrapper implementation
- Validate the imported-core path on actual target hardware or a stronger mixed-language verification flow

### Phase G: Refinement

- Throughput optimization
- Security posture improvement
- Documentation and review updates