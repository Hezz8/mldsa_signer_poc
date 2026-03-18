# STUB-Mode Bring-Up Plan

## Goal

Prepare and execute the first real Zynq board interaction in `STUB` mode only.

## Success Definition

Success for the first board execution is limited to:

1. wrapper register visibility from Linux on the PS
2. one completed STUB-mode signing transaction
3. signature bytes matching the deterministic rule `STUBSIG || digest || zero padding` for the known 64-byte selftest digest

## Required Build Choice

The first board image shall use the STUB-mode top-level:

- `hw/rtl/pqsig_top_stub_mode.sv`

Do not start with an MLDSA_OSH bitstream.

## Bring-Up Sequence

1. Integrate the STUB-mode top-level into the platform design.
2. Assign the AXI-Lite base address.
3. Generate and load the bitstream.
4. Boot Linux on the PS.
5. Run the real MMIO probe with the assigned base address.
6. If the probe is healthy, run the real STUB selftest.
7. Confirm the selftest reports `verified_stub_signature=true`.

## Expected Healthy Probe Output

- readable STATUS register
- `status_flags=idle` after reset or clear-status
- `error_name=none`
- `signature_length=0` before a transaction

## Expected Healthy STUB Selftest Output

- non-error completion
- `signature_length=128`
- `verified_stub_signature=true`
- the deterministic STUB signature hex payload for the known selftest digest

## Deferred Items

- MLDSA_OSH board bring-up
- production key management
- stronger MMIO isolation than `/dev/mem`
- full target-board performance characterization