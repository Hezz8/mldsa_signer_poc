# ML-DSA-OSH Inspection Notes

## Source Inspected

- Repository: `https://github.com/KULeuven-COSIC/ML-DSA-OSH.git`
- Imported revision: `751009199ac081091a9059805e6921453bde0154`
- Local imported path: `hw/ip/mldsa_osh/upstream/`

## Files Used for Integration Analysis

Primary files inspected:

- `hw/ip/mldsa_osh/upstream/ref_combined/src/combined_top.v`
- `hw/ip/mldsa_osh/upstream/ref_combined/src_tb/tb_sign_top.v`
- `hw/ip/mldsa_osh/upstream/common/mldsa_params.v`
- `hw/ip/mldsa_osh/upstream/KAT/SigGen_sk_87.txt`

## Chosen Integration Point

The chosen near-top-level integration point is `combined_top` in `ref_combined/src/combined_top.v`.

This module exposes a streaming command and data interface that is substantially closer to a system integration boundary than the lower-level arithmetic blocks. It supports multiple operations, including signing, and matches the role expected by the project-owned adapter and shim layer.

## Relevant Signing Configuration

For ML-DSA-87 signing, the upstream code path uses:

- `mode = 2` for signing
- `sec_lvl = 5` for ML-DSA-87 / security level V

## Real Inspected Handshake

Observed top-level or near-top-level interface on `combined_top`:

Inputs:

- `clk`
- `rst`
- `start`
- `mode[1:0]`
- `sec_lvl[2:0]`
- `valid_i`
- `data_i[63:0]`
- `ready_o`

Outputs:

- `ready_i`
- `valid_o`
- `data_o[63:0]`

Operationally:

- the producer sends 64-bit input words only when `ready_i` is asserted
- the consumer accepts 64-bit output words by asserting `ready_o`
- the upstream sign path is stream-oriented rather than memory-mapped

## Real Inspected Sign-Input Order

From `tb_sign_top.v`, the signing transaction for the selected upstream path sends data in this order:

1. `SK_rho` (32 bytes)
2. one 64-bit word carrying `mlen + ctxlen` semantics used by the upstream formatter
3. `SK_tr` (64 bytes)
4. formatted message bytes (`0x00 || ctxlen || ctx || message`)
5. `SK_K` (32 bytes)
6. `RND` (32 bytes)
7. `SK_s1`
8. `SK_s2`
9. `SK_t0`

The signature stream is then observed in this order:

1. `z`
2. `h`
3. `ctilde`

## Parameters Relevant to ML-DSA-87

From `common/mldsa_params.v` and the inspected sign testbench:

- secret key bytes: `4896`
- signature bytes: `4627`
- `SK_rho`: `32` bytes
- `SK_K`: `32` bytes
- `SK_tr`: `64` bytes
- `SK_s1`: `672` bytes
- `SK_s2`: `768` bytes
- `SK_t0`: `3328` bytes
- random bytes input: `32` bytes
- `ctilde`: `64` bytes
- `z`: `4480` bytes
- `h`: `83` bytes

## Key Material Assumption for the Current PoC

The upstream sign path expects the secret-key material already partitioned in the upstream layout. For the current controlled PoC integration, the project-owned shim uses a static secret-key image derived from the first ML-DSA-87 signing KAT secret key and stored in `hw/include/mldsa_osh_poc_sk_87.mem`.

This is explicitly PoC-only and is not a production key-management design.

## Digest Adaptation Assumption

The appliance contract accepts a 64-byte digest. The inspected upstream core signs a message stream, not a dedicated prehash-signing primitive.

The current project-owned shim therefore uses the following provisional adaptation:

- treat the appliance digest bytes as message bytes
- emit formatted message bytes `0x00 || 0x00 || digest[63:0]`
- send `mlen = 64`
- send zero-valued `RND` for deterministic controlled bring-up

This preserves the existing appliance boundary while making the adaptation explicit. It is an integration assumption, not a claim that the current end-to-end behavior has already been proven against a standardized prehash profile.

## Mixed-Language Verification Constraint

The imported upstream sign path includes both Verilog and VHDL source files under `ref_combined/src/`.

Observed examples:

- Verilog: `combined_top.v`, `operation_module.v`, `encoder.v`
- VHDL: `keccak_top.vhd`, `countern.vhd`, `piso.vhd`

The current local portable toolchain provides `iverilog`, `vvp`, and `verilator`, but not `ghdl` or another mixed-language elaboration path. As a result:

- the wrapper-level adapter seam can be compiled and tested locally in fallback form
- the full imported ML-DSA-OSH sign path cannot yet be simulated locally in this environment

## Chosen Project-Owned Shim Boundary

The project-owned shim boundary is:

- wrapper stays AXI-Lite and digest-oriented
- `mldsa_engine_adapter` stays mode-selectable and wrapper-agnostic
- `mldsa_osh_shim.sv` performs stream sequencing, key segmentation, message formatting, output reordering, and failure signaling

This keeps imported third-party code unmodified while isolating the appliance-specific assumptions to project-owned RTL.