# AXI-Lite Wrapper Testbench

`tb_axi_lite_wrapper.sv` is a lightweight transaction-level testbench for the stable AXI-Lite wrapper top.

Current coverage focus:

- reset state is idle
- digest window accepts writes
- `start` transitions the wrapper to `busy`
- deterministic completion transitions the wrapper to `done` in `STUB` and `CORE_PLACEHOLDER`
- signature length and signature data are readable in deterministic modes
- `MLDSA_OSH` mode is exercised honestly in the current Verilog-only flow by checking the documented fallback error behavior when the real mixed-language core is not compiled in

This remains simpler than a production AXI verification environment. Full local simulation of the imported ML-DSA-OSH sign path is currently blocked by mixed Verilog/VHDL tool requirements and is tracked separately in the build scripts and architecture notes.