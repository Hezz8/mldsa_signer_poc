# Portable Third-Party Tools

This directory is reserved for non-admin, repo-local tool provisioning.

Current preferred portable tools:

- `oss-cad-suite/`: user-space HDL tool bundle from YosysHQ
  - used here for `iverilog`, `vvp`, and related simulator support
- `tectonic/`: portable LaTeX engine used for Windows-native document builds
- `downloads/`: cached release assets used to populate the local tools

These tools are intentionally kept outside the project source tree and can be recreated with:

- `scripts/bootstrap/setup_user_space_tools.ps1`

Machine-level Chocolatey installs remain optional and are not required for this repo-local workflow.
