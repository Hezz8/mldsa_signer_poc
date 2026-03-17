# Next Phase Prompt: Software/Hardware Bring-Up

Use this prompt scaffold when moving the software stack from the fake backend to real PS and PL communication on the target platform while preserving the stable wrapper and adapter contract.

Focus areas:

- add a real MMIO backend for Linux on Zynq while preserving the current `PQSignatureDevice` API
- keep the fake backend available for local development and tests
- validate register sequencing, timeout handling, and signature readback against `hw/wrapper/axi_lite_wrapper.sv`
- treat the wrapper and adapter contract as stable even though the internals now include a real ML-DSA-OSH attachment path
- keep `STUB` mode available as a controlled fallback during first board bring-up
- update README, software architecture, wrapper spec, register map, verification collateral, and bring-up notes together

Do not replace the software contract or broaden scope into production key-management design in the same prompt.