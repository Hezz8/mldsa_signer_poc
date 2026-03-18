# Board Bring-Up Checklist

## Scope

This checklist is for the first PS-to-PL software bring-up on the target Zynq UltraScale+ platform. It assumes Linux is running on the PS and the PL bitstream already contains the stable AXI-Lite wrapper.

## Preconditions

- The correct STUB-mode bitstream is loaded on the board.
- The wrapper base address is known from the Vivado address map or platform design handoff.
- Linux user space has an MMIO access path available for bring-up.
- The repository `.venv` and Python dependencies are present on the target or an equivalent Python environment is available.

## Safe First Sequence

1. Confirm the programmed bitstream is the STUB-mode image.
2. Set `PQSIG_BACKEND=real`.
3. Set `PQSIG_MMIO_BASE_ADDR` to the wrapper base address.
4. Optionally set `PQSIG_MMIO_REGION_SIZE` if the platform integration differs from the default documented span.
5. Run `python -m sw.daemon.main probe-mmio --backend real --mmio-base-addr <addr>`.
6. Confirm the status register is readable and decodes to `idle` or another expected visible state.
7. If needed, repeat the probe with `--clear-status`.
8. Only after successful register visibility, run `python -m sw.daemon.main selftest --backend real --mmio-base-addr <addr>`.
9. Confirm the selftest prints `verified_stub_signature=true`.
10. Defer MLDSA_OSH-mode board work until after this STUB flow is stable.

## What To Verify In STUB Mode First

- STATUS register is readable.
- CONTROL writes do not crash the backend path.
- `clear_status` behaves as expected.
- `start` transitions through busy and done.
- `SIG_LENGTH` reports `128`.
- Selftest verifies the exact STUB signature rule.

## Known Blockers And Cautions

- The current digest-to-message adaptation in the shim is provisional.
- Key material is still static PoC provisioning data.
- Full local mixed-language simulation of the imported ML-DSA-OSH sign path is still limited by tool availability.
- The real backend uses a PoC `/dev/mem`-style access path and is not a hardened production interface.

## Success Criteria For This Phase

- Register visibility is confirmed on the target.
- One STUB transaction completes from the real backend.
- The returned signature matches the documented deterministic STUB rule.
- No claim is made yet about ML-DSA-OSH board success.