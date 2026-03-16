# AXI-Lite Wrapper Stub

This directory now contains the first executable hardware-side scaffold for the repository:

- `wrapper_pkg.sv`: constants for register offsets, control bits, status bits, and stub sizing.
- `axi_lite_wrapper_stub.sv`: AXI-Lite slave wrapper stub with deterministic fake signing behavior.
- `TODO.md`: forward-looking wrapper implementation tasks.

Current behavior is intentionally stubbed:

- software writes a 64-byte digest into the documented digest window
- a `start` write transitions the wrapper into `busy`
- after a deterministic two-cycle delay the wrapper transitions to `done`
- the signature buffer is populated with `STUBSIG || digest || zero padding` up to 128 bytes
- no ML-DSA datapath or external crypto core is present

This stub is intended for interface validation, software sequencing, and early simulation only.
