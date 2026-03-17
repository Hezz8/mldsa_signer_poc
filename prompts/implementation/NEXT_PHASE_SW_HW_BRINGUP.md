# Next Phase Prompt: Software/Hardware Bring-Up

Use this prompt scaffold when moving the software stack from the fake backend to real PS and PL communication on the target platform while preserving the stable wrapper and adapter contract.

Focus areas:

- add a real MMIO backend for Linux on Zynq while preserving the current `PQSignatureDevice` API
- keep the fake backend available for local development and tests
- validate register sequencing, timeout handling, and signature readback against `hw/wrapper/axi_lite_wrapper.sv`
- keep software behavior stable while hardware internals continue evolving behind `mldsa_engine_adapter`
- update README, software architecture, wrapper spec, register map, verification collateral, and bring-up notes together

Do not integrate the external ML-DSA repository in the same prompt unless that phase is explicitly requested.
