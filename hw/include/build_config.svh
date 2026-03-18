`ifndef PQSIG_BUILD_CONFIG_SVH
`define PQSIG_BUILD_CONFIG_SVH

// Compile-time or synthesis-time engine mode selection constants.
// The first real board image shall use PQSIG_ENGINE_MODE_STUB.
`define PQSIG_ENGINE_MODE_STUB 0
`define PQSIG_ENGINE_MODE_CORE_PLACEHOLDER 1
`define PQSIG_ENGINE_MODE_MLDSA_OSH 2

`endif