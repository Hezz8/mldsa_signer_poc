# Next Phase Prompt: Real Hardware MMIO Backend

Use this prompt scaffold when adding a real PS-to-wrapper backend on Linux running on the Zynq UltraScale+ processing system.

Focus areas:

- implement a real MMIO backend for the existing `PQSignatureDevice` abstraction
- preserve the fake backend and the current unit-test path
- keep `sw/proto/signing.proto` semantics unchanged
- map reads and writes exactly to the stable wrapper-visible register contract
- document timeout handling, polling cadence, error propagation, and signature-window reads for real ML-DSA-87 signatures
- plan for controlled selection between `STUB` and `MLDSA_OSH` hardware modes during bring-up
- update the software architecture document, wrapper spec, register map, verification plan, and operator notes together

Do not change the public service behavior or remove the local development path in the same prompt.