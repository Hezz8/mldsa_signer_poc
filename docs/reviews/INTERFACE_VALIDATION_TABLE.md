# Interface Validation Table

| Step | Expected register behavior | Expected software observation | Failure meaning |
| --- | --- | --- | --- |
| Read `STATUS` after reset | `STATUS` is readable; `idle` is normally asserted | `probe-mmio` prints `status=0x...` and `status_flags=idle` | AXI-Lite path, address assignment, reset, or MMIO access is broken |
| Read `ERROR_CODE` after reset | `ERROR_CODE=0` | `error_name=none` | stale error, invalid reset behavior, or wrong address map |
| Read `SIG_LENGTH` before start | `SIG_LENGTH=0` in idle state | `signature_length=0` during probe | stale state, incomplete clear-status, or wrong wrapper image |
| Write digest window | sixteen 32-bit words accept the 64-byte digest | selftest does not fail before start | bad AXI write path, endianness mismatch, or invalid region |
| Write `CONTROL.start` | wrapper accepts the start pulse and leaves idle | no immediate backend exception | control register not mapped, write path broken, or wrong image |
| Observe busy interval | `STATUS.busy` asserts during the operation | selftest waits without immediate timeout | clock/reset issue or engine mode/image mismatch |
| Observe done state | `STATUS.done` asserts and busy deasserts | selftest completes instead of timing out | engine path never completes or status logic is broken |
| Read `SIG_LENGTH` after completion | `SIG_LENGTH=128` in STUB mode | selftest prints `signature_length=128` | wrong engine mode, bad wrapper state, or partial completion |
| Read signature window | signature buffer returns the deterministic STUB payload | selftest prints `verified_stub_signature=true` | digest ordering, endianness, buffer span, or image selection is wrong |
| Clear status | `done` and stale error state clear | a later probe returns `signature_length=0` and a sane status | stale state retention or clear-status logic is broken |
