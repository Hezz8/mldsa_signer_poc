# Wrapper Stub Testbench

`tb_axi_lite_wrapper_stub.sv` is a lightweight transaction-level testbench for the AXI-Lite wrapper stub.

Current coverage focus:

- reset state is idle
- digest window accepts writes
- `start` transitions the wrapper to `busy`
- deterministic completion transitions the wrapper to `done`
- signature length is non-zero and fixed for the stub phase
- signature data window is readable and begins with the documented `STUBSIG` prefix

This is intentionally simpler than a production AXI verification environment and is honest about being an early bring-up scaffold.
