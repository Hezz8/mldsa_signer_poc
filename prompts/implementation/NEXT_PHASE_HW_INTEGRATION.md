# Next Phase Prompt: Hardware Integration Follow-Through

Use this prompt scaffold after Phase 4 when extending the real ML-DSA-OSH attachment beyond the current adapter-and-shim baseline.

Focus areas:

- preserve the existing AXI-Lite register map semantics and wrapper-visible control behavior
- keep `hw/wrapper/axi_lite_wrapper.sv` as the PS-visible contract boundary
- preserve `STUB` mode for regression and board bring-up fallback
- refine `hw/rtl/mldsa_osh_shim.sv` only as needed to match the real imported-core interface more accurately
- do not modify the vendored upstream snapshot unless there is a documented and justified need
- improve mixed-language verification or synthesis-backed validation for the imported sign path
- update `MLDSA_OSH_Inspection_Notes.md`, the ML-DSA-OSH integration guide, the key provisioning chapter, and the verification plan in the same workstream

Do not broaden scope into software backend changes unless the prompt explicitly includes PS-to-PL bring-up.