# AXI-Lite Wrapper Testbench

`tb_axi_lite_wrapper.sv` is a lightweight transaction-level testbench for the stable AXI-Lite wrapper top.

Current coverage focus:

- reset state is idle
- digest window accepts writes
- `start` transitions the wrapper to `busy`
- deterministic completion transitions the wrapper to `done`
- signature length is non-zero and fixed for the current adapter modes
- signature data window is readable
- `STUB` mode and `CORE_PLACEHOLDER` mode both behave according to their documented deterministic semantics

This remains simpler than a production AXI verification environment and is intentionally scoped for early bring-up and interface stability.
