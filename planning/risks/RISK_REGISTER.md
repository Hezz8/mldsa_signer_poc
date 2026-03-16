# Risk Register

| ID | Risk | Impact | Likelihood | Mitigation |
| --- | --- | --- | --- | --- |
| R1 | External and internal interfaces diverge before implementation matures | High | Medium | Keep proto, ICD, wrapper spec, and register map under coordinated review |
| R2 | AXI-Lite control path becomes a throughput bottleneck later | Medium | Medium | Treat AXI-Lite as a PoC interface and preserve room for future DMA or streaming paths |
| R3 | PoC key handling assumptions leak into production design | High | Medium | Mark hardcoded-key approach as PoC-only in every relevant document and ADR |
| R4 | Hardware/software teams make incompatible timing assumptions | High | Medium | Define explicit busy, done, error, and timeout semantics in the wrapper spec |
| R5 | Verification scope is too shallow for integration bring-up | High | Medium | Establish unit, simulation, integration, and soak-test layers early |
| R6 | Vendor tool outputs pollute the repository | Medium | Medium | Enforce `.gitignore` policy and keep generated artifacts out of source control |
| R7 | Future external core integration disturbs stable interfaces | Medium | Medium | Keep the wrapper contract independent of any single core implementation |
| R8 | Documentation becomes stale as architecture changes | High | Medium | Require doc updates in the same change as architecture-impacting modifications |
