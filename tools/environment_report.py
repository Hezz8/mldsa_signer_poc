from __future__ import annotations

import importlib
import shutil
import subprocess
import sys
from pathlib import Path


def run_command(command: list[str]) -> tuple[bool, str]:
    try:
        completed = subprocess.run(
            command,
            check=True,
            capture_output=True,
            text=True,
        )
    except Exception as exc:
        return False, str(exc)
    return True, (completed.stdout or completed.stderr).strip()


def import_status(module_name: str) -> tuple[bool, str]:
    try:
        module = importlib.import_module(module_name)
    except Exception as exc:
        return False, str(exc)
    version = getattr(module, "__version__", "imported")
    return True, str(version)


def main() -> int:
    repo_root = Path(__file__).resolve().parents[1]
    print(f"repo_root={repo_root}")
    print(f"python_executable={sys.executable}")

    command_checks = {
        "git": ["git", "--version"],
        "python": [sys.executable, "--version"],
        "pip": [sys.executable, "-m", "pip", "--version"],
        "pytest": [sys.executable, "-m", "pytest", "--version"],
    }

    for label, command in command_checks.items():
        ok, output = run_command(command)
        print(f"{label}={'OK' if ok else 'MISSING'} {output}")

    module_checks = {
        "grpc": "grpc",
        "grpc_tools": "grpc_tools",
        "google.protobuf": "google.protobuf",
    }

    for label, module_name in module_checks.items():
        ok, output = import_status(module_name)
        print(f"{label}={'OK' if ok else 'MISSING'} {output}")

    tool_checks = {
        "verilator": shutil.which("verilator"),
        "iverilog": shutil.which("iverilog"),
        "latexmk": shutil.which("latexmk"),
        "pdflatex": shutil.which("pdflatex"),
    }

    for label, path in tool_checks.items():
        print(f"{label}={'FOUND' if path else 'MISSING'} {path or ''}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
