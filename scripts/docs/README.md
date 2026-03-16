# Documentation Scripts

- `build_docs.sh`: Bash-oriented LaTeX build entrypoint for environments where Bash and a TeX engine are available.
- `build_docs.ps1`: Windows-native documentation build entrypoint that prefers the repo-local `tectonic` binary and falls back to `latexmk` or `pdflatex`.

The repository now supports a non-admin documentation workflow through `tools/third_party/tectonic/tectonic.exe`.