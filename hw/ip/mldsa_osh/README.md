# ML-DSA-OSH Third-Party Integration

This directory contains the imported ML-DSA-OSH hardware implementation used as the Phase 4 integration baseline for `pq-signature-appliance`.

## Provenance

- Source repository: `https://github.com/KULeuven-COSIC/ML-DSA-OSH.git`
- Imported revision: `751009199ac081091a9059805e6921453bde0154`
- Imported commit subject: `initial commit sources`
- Imported commit date: `2025-12-30 18:17:54 +0100`
- Upstream license: MIT, with additional provenance notes in the imported `NOTICE` file for files derived from the GMU CERG Apache-2.0 Dilithium source

## Integration Method

The project uses a vendored snapshot / documented source drop under `hw/ip/mldsa_osh/upstream/`.

This method was chosen instead of a submodule for the current environment because it is more reliable under restricted network conditions, keeps the inspected source available locally for deterministic builds and documentation review, and avoids coupling day-to-day repository use to recursive submodule fetches.

## Imported Scope

The snapshot currently includes:

- `common/`
- `KAT/`
- `ref_combined/`
- upstream `README.md`, `LICENSE`, `NOTICE`, and `CITATION`

The current project-owned integration work primarily targets the sign path in `upstream/ref_combined/src/combined_top.v` with ML-DSA signing mode and security level corresponding to ML-DSA-87.

## Project-Owned Glue vs Unmodified Third-Party Source

The files under `hw/ip/mldsa_osh/upstream/` are treated as imported third-party source.

Project-owned glue remains outside this directory, primarily in:

- `hw/rtl/mldsa_engine_adapter.sv`
- `hw/rtl/mldsa_osh_shim.sv`
- `hw/wrapper/wrapper_pkg.sv`
- `hw/include/mldsa_osh_poc_sk_87.mem`

Those project-owned files translate between the stable wrapper-visible appliance contract and the actual imported ML-DSA-OSH stream interface without modifying the imported source tree.

## Expected Usage

The imported snapshot is currently used for:

- interface inspection
- adapter and shim design
- PoC key-format alignment
- future mixed-language simulation or synthesis integration

The current repository state does not claim full end-to-end local simulation of the real upstream sign path. The local portable wrapper testbench still verifies `STUB`, `CORE_PLACEHOLDER`, and the documented `MLDSA_OSH` fallback behavior that is available without mixed-language elaboration.