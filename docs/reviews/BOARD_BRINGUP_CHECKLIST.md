# Board Bring-Up Checklist

## Scope

This checklist is for the first PS-to-PL software bring-up on the target Zynq UltraScale+ platform. It assumes Linux is running on the PS and the PL bitstream already contains the stable AXI-Lite wrapper.

## Preconditions

- The correct bitstream is loaded on the board.
- The wrapper base address is known from the Vivado address map or platform design handoff.
- Linux user space has an MMIO access path available for bring-up.
- The repository `.venv` and Python dependencies are present on the target or an equivalent Python environment is available.

## Safe First Sequence

1. Confirm which engine mode is present in the programmed bitstream.
2. Start with a bitstream built for `STUB` mode.
3. Set `PQSIG_BACKEND=real`.
4. Set `PQSIG_MMIO_BASE_ADDR` to the wrapper base address.
5. Optionally set `PQSIG_MMIO_REGION_SIZE` if the platform integration differs from the default documented span.
6. Run `python -m sw.daemon.main probe-mmio --backend real --mmio-base-addr <addr>`.
7. Confirm the status register is readable and decodes to `idle` or another expected visible state.
8. If needed, repeat the probe with `--clear-status`.
9. Only after successful register visibility, run `python -m sw.daemon.main selftest --backend real --mmio-base-addr <addr>` against the `STUB` bitstream.
10. Move to `MLDSA_OSH` bitstreams only after STUB-mode register and sequencing behavior is stable.

## What To Verify In STUB Mode First

- STATUS register is readable.
- CONTROL writes do not crash the backend path.
- `clear_status` behaves as expected.
- `start` transitions through busy and done.
- `SIG_LENGTH` reports `128`.
- Signature data readback matches the documented deterministic stub behavior.

## Before Switching To MLDSA_OSH Mode

- Confirm which bitstream or synthesis configuration selects `ENGINE_MODE_MLDSA_OSH`.
- Re-run the probe path to confirm register visibility did not regress.
- Expect larger signature lengths.
- Treat the digest-to-message adaptation as provisional.
- Treat static key provisioning as PoC-only.

## Known Blockers And Cautions

- The current digest-to-message adaptation in the shim is provisional.
- Key material is still static PoC provisioning data.
- Full local mixed-language simulation of the imported ML-DSA-OSH sign path is still limited by tool availability.
- The real backend uses a PoC `/dev/mem`-style access path and is not a hardened production interface.

## Success Criteria For This Phase

- Register visibility is confirmed on the target.
- STUB mode is controllable from the real backend.
- No claim is made yet about full end-to-end ML-DSA cryptographic validation on the board.