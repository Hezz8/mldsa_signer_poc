# Tools Area

Use this directory for repository-managed helper utilities that support development, verification, documentation generation, or data preparation.

Current helpers:

- `repo_sanity_check.py`: validates the expected repository structure for the current project phase
- `environment_report.py`: reports Python, gRPC, HDL, and documentation tooling availability, including repo-local portable tools
- `third_party/`: non-admin portable tooling area for HDL and LaTeX support

Keep tools small, reviewable, and documented. Tool-specific assumptions should be captured near the utility or in the relevant workflow documentation.