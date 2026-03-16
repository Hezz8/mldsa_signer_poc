# Next Phase Prompt: Hardware Integration

Use this prompt scaffold when replacing the deterministic wrapper stub datapath with the real ML-DSA hardware integration.

Focus areas:

- preserve the existing AXI-Lite register map and control semantics unless a documented design decision says otherwise
- integrate the real signing engine behind the existing wrapper contract
- keep `CONTROL`, `STATUS`, `ERROR_CODE`, `SIG_LENGTH`, `DIGEST`, and `SIG_DATA` behavior aligned with the software source of truth
- update the wrapper spec, hardware microarchitecture document, register map, and verification plan in the same workstream
- extend the testbench so stub-specific checks evolve into real core integration checks

Do not broaden scope into unrelated platform changes in the same prompt.
