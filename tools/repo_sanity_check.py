from __future__ import annotations

from pathlib import Path
import sys


REQUIRED_DIRECTORIES = [
    "docs",
    "docs/architecture",
    "docs/interfaces",
    "hw/wrapper",
    "hw/tb",
    "sw/daemon",
    "sw/mmio",
    "sw/client",
    "sw/tests",
    "scripts/build",
    "tools",
]

REQUIRED_FILES = [
    "README.md",
    "docs/main.tex",
    "docs/architecture/Software_Architecture.tex",
    "docs/architecture/Wrapper_Spec.tex",
    "docs/interfaces/Register_Map.tex",
    "hw/wrapper/axi_lite_wrapper_stub.sv",
    "hw/wrapper/wrapper_pkg.sv",
    "hw/tb/tb_axi_lite_wrapper_stub.sv",
    "sw/daemon/main.py",
    "sw/daemon/server.py",
    "sw/daemon/service.py",
    "sw/mmio/register_map.py",
    "sw/mmio/device.py",
    "sw/mmio/fake_backend.py",
    "sw/client/client.py",
    "sw/tests/test_service.py",
    "sw/tests/test_mmio_fake_backend.py",
    "sw/tests/test_client_server_contract.py",
    "scripts/build/run_python_tests.sh",
    "sw/proto/signing.proto",
]



def main() -> int:
    root = Path(__file__).resolve().parents[1]
    missing_dirs = [path for path in REQUIRED_DIRECTORIES if not (root / path).is_dir()]
    missing_files = [path for path in REQUIRED_FILES if not (root / path).is_file()]

    print("pq-signature-appliance repository sanity check")
    print(f"root={root}")
    print(f"directories_ok={len(REQUIRED_DIRECTORIES) - len(missing_dirs)}/{len(REQUIRED_DIRECTORIES)}")
    print(f"files_ok={len(REQUIRED_FILES) - len(missing_files)}/{len(REQUIRED_FILES)}")

    if missing_dirs:
        print("missing_directories:")
        for path in missing_dirs:
            print(f"  - {path}")
    if missing_files:
        print("missing_files:")
        for path in missing_files:
            print(f"  - {path}")

    if missing_dirs or missing_files:
        return 1

    print("status=PASS")
    return 0


if __name__ == "__main__":
    sys.exit(main())
