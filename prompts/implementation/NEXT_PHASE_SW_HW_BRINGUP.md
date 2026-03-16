# Next Phase Prompt: Software/Hardware Bring-Up

Use this prompt scaffold when moving the software stack from the fake backend to real PS/PL communication on the target platform.

Focus areas:

- add a real MMIO backend for Linux on Zynq while preserving the current `PQSignatureDevice` API
- keep the fake backend available for local development and tests
- validate register sequencing, timeout handling, and signature readback against the real wrapper implementation
- extend service observability for bring-up and continuous-operation testing
- update README, software architecture, wrapper spec, register map, and verification collateral together

Do not integrate the external ML-DSA repository in the same prompt unless that phase is explicitly requested.
