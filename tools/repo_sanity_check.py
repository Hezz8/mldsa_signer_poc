from __future__ import annotations

from pathlib import Path
import sys


REQUIRED_DIRECTORIES = [
    "docs",
    "docs/architecture",
    "docs/interfaces",
    "docs/reviews",
    "hw/include",
    "hw/ip/mldsa_osh",
    "hw/rtl",
    "hw/wrapper",
    "hw/tb",
    "hw/docs",
    "sw/daemon",
    "sw/mmio",
    "sw/client",
    "sw/tests",
    "sw/tools",
    "scripts/build",
    "tools",
]

REQUIRED_FILES = [
    "README.md",
    "docs/main.tex",
    "docs/architecture/PDR.tex",
    "docs/architecture/Hardware_Microarchitecture.tex",
    "docs/architecture/Software_Architecture.tex",
    "docs/architecture/Wrapper_Spec.tex",
    "docs/architecture/MLDSA_OSH_Integration_Guide.tex",
    "docs/architecture/MLDSA_Key_Provisioning_PoC.tex",
    "docs/architecture/MLDSA_OSH_Inspection_Notes.md",
    "docs/architecture/PS_PL_Bringup_Guide.tex",
    "docs/architecture/STUB_Mode_Target_Flow.tex",
    "docs/interfaces/ICD.tex",
    "docs/interfaces/Register_Map.tex",
    "docs/reviews/BOARD_BRINGUP_CHECKLIST.md",
    "docs/reviews/STUB_MODE_BRINGUP_PLAN.md",
    "docs/reviews/REAL_BOARD_EXECUTION_GUIDE.md",
    "docs/reviews/INTERFACE_VALIDATION_TABLE.md",
    "docs/reviews/STUB_TEST_VECTOR.md",
    "docs/reviews/DEBUG_PLAYBOOK.md",
    "docs/verification/Verification_Plan.tex",
    "hw/include/build_config.svh",
    "hw/include/mldsa_osh_poc_sk_87.mem",
    "hw/include/README.md",
    "hw/ip/mldsa_osh/README.md",
    "hw/rtl/mldsa_engine_adapter.sv",
    "hw/rtl/mldsa_osh_shim.sv",
    "hw/rtl/pqsig_top_stub_mode.sv",
    "hw/rtl/pqsig_top_mldsa_osh_mode.sv",
    "hw/docs/BUILD_MODES.md",
    "hw/docs/VIVADO_INTEGRATION_NOTES.md",
    "hw/constraints/README.md",
    "hw/wrapper/axi_lite_wrapper.sv",
    "hw/wrapper/wrapper_pkg.sv",
    "hw/tb/tb_axi_lite_wrapper.sv",
    "sw/daemon/config.py",
    "sw/daemon/main.py",
    "sw/daemon/server.py",
    "sw/daemon/service.py",
    "sw/mmio/backend.py",
    "sw/mmio/register_map.py",
    "sw/mmio/device.py",
    "sw/mmio/fake_backend.py",
    "sw/mmio/real_backend.py",
    "sw/mmio/probe.py",
    "sw/client/client.py",
    "sw/tools/__init__.py",
    "sw/tools/run_stub_bringup.py",
    "sw/tests/test_service.py",
    "sw/tests/test_mmio_fake_backend.py",
    "sw/tests/test_client_server_contract.py",
    "sw/tests/test_backend_selection.py",
    "sw/tests/test_real_backend.py",
    "sw/tests/test_probe.py",
    "sw/tests/test_stub_bringup_tool.py",
    "scripts/build/run_python_tests.sh",
    "scripts/build/run_sv_stub_tb.ps1",
    "scripts/build/run_sv_mldsa_osh_tb.ps1",
    "scripts/build/run_real_mmio_probe.ps1",
    "scripts/build/run_real_stub_selftest.ps1",
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
