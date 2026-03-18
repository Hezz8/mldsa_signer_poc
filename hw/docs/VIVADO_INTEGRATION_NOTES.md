# Vivado Integration Notes

## Scope

This repository does not commit a generated Vivado project. These notes capture the remaining platform-specific steps for the first STUB-mode board image.

## Remaining Platform Work

- connect the chosen top-level to the Zynq PS and AXI interconnect
- assign the AXI-Lite wrapper base address
- hook PS or board clocking into `pl_clk`
- hook a clean active-low reset into `pl_resetn`
- generate the bitstream for the chosen top-level
- make the resulting address map available to Linux-side software bring-up

## First Image Recommendation

Use `hw/rtl/pqsig_top_stub_mode.sv` for the first board bitstream.

## Linux Bring-Up Dependencies

- `/dev/mem` or another approved MMIO access path must exist on the target Linux image
- the bring-up user must have sufficient permissions for the chosen MMIO path
- the wrapper base address must match the platform design handoff