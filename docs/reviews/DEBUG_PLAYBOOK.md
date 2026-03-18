# Debug Playbook

## If probe fails

Likely cause:
- wrong AXI base address
- `/dev/mem` unavailable or inaccessible
- wrapper not present in the bitstream
- reset or clock not connected

Next action:
- verify the Vivado address map
- confirm the programmed image is the STUB bitstream
- confirm `/dev/mem` exists and the user has privilege
- retry with the exact assigned base address

## If STATUS never changes

Likely cause:
- `start` write never reaches the wrapper
- wrapper is held in reset
- PL clock is not running
- AXI interconnect hookup is incomplete

Next action:
- inspect PS-PL clock and reset hookup
- confirm AXI-Lite signals are connected to the PS path
- re-run probe and then selftest with the STUB image only

## If DONE never asserts

Likely cause:
- the design is not actually the STUB-mode image
- start reached the wrapper but the internal engine path is not progressing
- wrapper status logic is not connected correctly

Next action:
- confirm the top-level is `pqsig_top_stub_mode.sv`
- confirm the synthesized wrapper parameter is `ENGINE_MODE_STUB`
- check reset polarity and timing on the board design

## If signature is wrong

Likely cause:
- digest word ordering mismatch
- endianness mismatch in MMIO or software packing
- signature window read span is incomplete
- wrong bitstream image is loaded

Next action:
- compare the returned hex against `docs/reviews/STUB_TEST_VECTOR.md`
- verify the digest window writes all 16 words
- verify the region size is at least `0x1314` bytes
- rebuild and reload the STUB bitstream

## If MMIO crashes

Likely cause:
- invalid physical address
- region size is too small
- Linux denied or faulted the mapping
- platform design exported the wrong address map

Next action:
- stop using selftest and return to probe-only mode
- verify `.xsa` or address-handoff data against the software base address
- confirm `/dev/mem` access as root
- confirm the mapping span covers the full wrapper register window
