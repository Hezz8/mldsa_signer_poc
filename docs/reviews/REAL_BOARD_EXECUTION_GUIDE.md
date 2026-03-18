# Real Board Execution Guide

## Scope

This guide is the literal first-board execution procedure for `pq-signature-appliance` in `STUB` mode on a Zynq UltraScale+ target.

Do not skip directly to `MLDSA_OSH` mode.
Do not claim success until the probe and the STUB selftest both pass on the actual board.

## Fixed Reference Values

- Example AXI-Lite base address: `0xA0000000`
- Minimum wrapper region size: `0x1314` bytes
- Engine mode for the first image: `STUB`
- Required RTL top: `hw/rtl/pqsig_top_stub_mode.sv`
- Default Linux MMIO path: `/dev/mem`

## Phase A - Hardware Preparation

1. Open the platform design in Vivado.
2. Instantiate or preserve the Zynq PS block for the target board.
3. Instantiate the project wrapper path using `hw/rtl/pqsig_top_stub_mode.sv` as the project-owned top-level scaffold.
4. Connect the AXI-Lite slave interface from the project wrapper into the PS-facing AXI interconnect.
5. Connect PS to PL clock and reset so the wrapper sees a stable PL clock and an active-low reset.
6. Assign an AXI-Lite base address to the wrapper in the Vivado address editor.
7. Record that base address exactly. The software examples below use `0xA0000000` only as a placeholder example.
8. Ensure the assigned region spans at least `0x1314` bytes.
9. Generate the bitstream.
10. Export the hardware handoff for software bring-up.

Required hardware outputs:
- bitstream file: `.bit`
- hardware handoff: `.xsa` or the platform-equivalent handoff artifact

## Phase B - Linux Preparation

1. Program the board with the STUB-mode bitstream.
2. Boot Linux on the Zynq PS.
3. Copy or clone this repository onto the board.
4. Ensure Python and the repository virtual environment are available, or use an equivalent Python environment with the same dependencies.
5. Confirm that `/dev/mem` exists.
6. Run bring-up commands with sufficient privileges for `/dev/mem` access. In practice this usually means `root`.
7. Export the wrapper base address or keep it ready for the command line.

Useful checks:
- `ls -l /dev/mem`
- `id`
- `python --version`

## Phase C - First Probe

Exact command:

```bash
python -m sw.daemon.main probe-mmio --backend real --mmio-base-addr <ADDR>
```

Example with the placeholder address:

```bash
python -m sw.daemon.main probe-mmio --backend real --mmio-base-addr 0xA0000000
```

Expected success characteristics:
- command exits with code `0`
- `backend=real`
- `mmio_base_addr=0xA0000000` or the assigned address
- readable `status=0x...`
- `status_flags=idle` after reset or after a clear-status path
- `error_name=none`
- `signature_length=0` before any transaction

Failure cases and interpretation:
- `cannot create backend: real backend requires ... base address`
  - interpretation: software configuration is incomplete
- `cannot create backend: unable to map MMIO region via /dev/mem ...`
  - interpretation: `/dev/mem` is missing, inaccessible, or the user lacks privilege
- `probe failed: [Errno ...]`
  - interpretation: the mapping exists but the MMIO read path failed; check address assignment and Linux permissions
- process crash, bus error, or kernel MMIO fault
  - interpretation: wrong physical address, invalid region, or broken platform integration

If probe does not succeed, stop and fix probe visibility before attempting selftest.

## Phase D - First STUB Selftest

Exact command:

```bash
python -m sw.daemon.main selftest --backend real --mmio-base-addr <ADDR>
```

Example with the placeholder address:

```bash
python -m sw.daemon.main selftest --backend real --mmio-base-addr 0xA0000000
```

Expected success characteristics:
- command exits with code `0`
- `selftest status=DEVICE_OK signature_length=128`
- `verified_stub_signature=true`
- printed signature hex exactly matches the known-good STUB vector documented in `docs/reviews/STUB_TEST_VECTOR.md`

Failure modes and interpretation:
- timeout or `operation did not complete within ...`
  - interpretation: start reached the wrapper but busy/done sequencing did not complete; check clock, reset, AXI connectivity, and whether the programmed bitstream is actually the STUB image
- `selftest signature length mismatch`
  - interpretation: register visibility exists but the engine-visible behavior is not the expected STUB path; confirm the correct bitstream and wrapper image
- `selftest signature mismatch against documented STUB rule`
  - interpretation: transaction completed but the returned bytes are wrong; check digest write ordering, endianness, and whether the hardware image is really STUB mode
- truncated signature, partial read, or repeated zero data
  - interpretation: signature window reads are not covering the full buffer or the wrapper region size is too small
- process crash, bus error, or kernel MMIO fault
  - interpretation: invalid address map or unstable MMIO path; return to probe-stage debugging

## Optional Single-Command Board Flow

A helper is provided for board use:

```bash
python -m sw.tools.run_stub_bringup --backend real --mmio-base-addr <ADDR>
```

This runs probe first, then STUB selftest, and prints a single PASS or FAIL summary.

## Stop Conditions

Stop and debug before moving forward if any of the following occur:
- probe does not complete cleanly
- status is unreadable
- selftest does not print `verified_stub_signature=true`
- signature length is not `128`
- returned signature hex differs from the known-good vector

## Explicit Deferral

`MLDSA_OSH` board execution remains deferred until this exact STUB-mode flow passes on the real board.
