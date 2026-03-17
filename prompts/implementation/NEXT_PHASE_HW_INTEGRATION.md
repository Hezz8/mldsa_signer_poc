# Next Phase Prompt: Hardware Integration

Use this prompt scaffold when replacing `CORE_PLACEHOLDER` inside `mldsa_engine_adapter` with the real ML-DSA-OSH integration.

Focus areas:

- preserve the existing AXI-Lite register map and wrapper-visible control semantics unless a documented design decision says otherwise
- keep `hw/wrapper/axi_lite_wrapper.sv` as the PS-visible contract boundary
- integrate the real signing engine behind `hw/rtl/mldsa_engine_adapter.sv`
- keep `CONTROL`, `STATUS`, `ERROR_CODE`, `SIG_LENGTH`, `DIGEST`, and `SIG_DATA` behavior aligned with the software source of truth
- update the wrapper spec, hardware microarchitecture document, ML-DSA-OSH integration guide, register map, and verification plan in the same workstream
- extend the testbench so deterministic `CORE_PLACEHOLDER` checks evolve into real adapter-to-core integration checks

Do not broaden scope into unrelated platform changes in the same prompt.
