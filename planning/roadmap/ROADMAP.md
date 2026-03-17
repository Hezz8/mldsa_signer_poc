# Roadmap

## Objective

Establish a credible engineering path from repository bootstrap to a working proof-of-concept post-quantum signature appliance on Zynq UltraScale+.

## Current Phase

The repository is in the hardware adapter stabilization phase. The external API, internal register map, software sequencing, and wrapper behavior remain stable, and the PL-side architecture now includes an explicit engine adapter seam for future ML-DSA-OSH integration. No real ML-DSA implementation has been integrated yet.

## Workstreams

### 1. System definition

- Keep the external signing service contract stable
- Keep the PS/PL register and control protocol synchronized across docs and code
- Capture non-functional expectations for reliability and maintainability

### 2. Software platform

- Maintain the transport-independent service core and MMIO device layer
- Keep the optional gRPC binding path aligned with the canonical proto
- Expand validation, telemetry, and soak-test hooks without breaking the public software API

### 3. Hardware platform

- Keep the AXI-Lite wrapper contract stable
- Keep the engine adapter as the only intended attachment point for future ML-DSA-OSH integration
- Replace deterministic adapter modes with the real core without breaking wrapper-visible behavior

### 4. Verification and performance

- Maintain unit, simulation, integration, and end-to-end verification layers
- Continue refining realistic throughput and latency models
- Prepare continuous signing and stability campaigns on hardware

### 5. Security hardening

- Replace PoC key handling assumptions with a production-grade key management approach later
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

### Phase E: Real bring-up

- Replace the fake backend with real MMIO access on target hardware
- Exercise PS and PL sequencing against the stable wrapper implementation

### Phase F: Core integration

- Integrate ML-DSA-OSH behind the engine adapter
- Demonstrate end-to-end signing on target hardware

### Phase G: Refinement

- Throughput optimization
- Security posture improvement
- Documentation and review updates
