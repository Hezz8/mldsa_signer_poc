# Roadmap

## Objective

Establish a credible engineering path from repository bootstrap to a working proof-of-concept post-quantum signature appliance on Zynq UltraScale+.

## Current Phase

The repository is in the executable stub phase. The external API, internal register map, software sequencing, and hardware wrapper behavior are now exercised through deterministic scaffolding, but no real ML-DSA implementation has been integrated yet.

## Workstreams

### 1. System definition

- Keep the external signing service contract stable
- Keep the PS/PL register and control protocol synchronized across docs and code
- Capture non-functional expectations for reliability and maintainability

### 2. Software platform

- Maintain the transport-independent service core and MMIO device layer
- Keep the optional gRPC binding path aligned with the canonical proto
- Expand validation, telemetry, and soak-test hooks

### 3. Hardware platform

- Keep the AXI-Lite wrapper contract stable
- Use the wrapper stub and testbench to validate control semantics early
- Replace the fake datapath with the future ML-DSA integration without breaking software contracts

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
- Hardware wrapper stub and simple testbench validate the register contract
- Local tests validate busy, done, and signature readback behavior

### Phase D: Real bring-up

- Replace the fake backend with real MMIO access on target hardware
- Exercise PS/PL sequencing against the real wrapper implementation

### Phase E: Integration

- Integrate the real ML-DSA core into PL
- Demonstrate end-to-end signing on target hardware

### Phase F: Refinement

- Throughput optimization
- Security posture improvement
- Documentation and review updates
