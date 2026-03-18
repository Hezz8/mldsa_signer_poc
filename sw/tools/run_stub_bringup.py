"""Board-facing helper that runs probe plus STUB selftest."""

from __future__ import annotations

import argparse
import logging
import sys

from sw.daemon.config import ConfigError, DaemonConfig, _parse_optional_int
from sw.daemon.server import BackendSelectionError, LocalSigningServer, create_default_service, create_device_from_config
from sw.daemon.service import SigningExecutionError
from sw.mmio import register_map as reg
from sw.mmio.probe import probe_device


DEFAULT_DIGEST = bytes(range(reg.DIGEST_SIZE))


def _build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Run the real-board STUB probe and selftest sequence")
    parser.add_argument("--backend", choices=("fake", "real"), default="real", help="backend mode")
    parser.add_argument("--mmio-base-addr", default=None, help="physical wrapper base address, for example 0xA0000000")
    parser.add_argument("--mmio-region-size", default=None, help="mapped MMIO span in bytes")
    parser.add_argument("--devmem-path", default=None, help="memory device path, default /dev/mem")
    parser.add_argument("--timeout-s", type=float, default=None, help="device timeout in seconds")
    parser.add_argument("--poll-interval-s", type=float, default=None, help="poll interval in seconds")
    parser.add_argument("--clear-status", action="store_true", help="clear device status before the probe")
    return parser


def _build_config(args: argparse.Namespace) -> DaemonConfig:
    config = DaemonConfig.from_env()
    return config.with_overrides(
        backend_mode=args.backend,
        mmio_base_addr=_parse_optional_int(args.mmio_base_addr),
        mmio_region_size=_parse_optional_int(args.mmio_region_size),
        devmem_path=args.devmem_path,
        timeout_s=args.timeout_s,
        poll_interval_s=args.poll_interval_s,
    )


def _run_probe(config: DaemonConfig, clear_status: bool) -> None:
    device = create_device_from_config(config)
    try:
        report = probe_device(device, clear_status=clear_status)
    finally:
        device.close()

    print("== Probe ==")
    print(f"backend={config.backend_mode}")
    if config.mmio_base_addr is not None:
        print(f"mmio_base_addr=0x{config.mmio_base_addr:08X}")
    print(f"mmio_region_size=0x{config.mmio_region_size:X}")
    print(f"status=0x{report.status_value:08X}")
    print(f"status_flags={','.join(report.status_flags) if report.status_flags else 'none'}")
    print(f"error_code={report.error_code}")
    print(f"error_name={report.error_name}")
    print(f"signature_length={report.signature_length}")


def _run_selftest(config: DaemonConfig) -> None:
    expected_signature = reg.build_stub_signature(DEFAULT_DIGEST)
    service = create_default_service(config)
    try:
        local_server = LocalSigningServer(service)
        result = local_server.handle_digest(DEFAULT_DIGEST)
    finally:
        service.close()

    print("== Selftest ==")
    print(f"selftest_status={result.status}")
    print(f"signature_length={result.signature_length}")
    print(f"signature_hex={result.signature.hex()}")

    if result.signature_length != len(expected_signature):
        raise RuntimeError(
            f"signature length mismatch: expected {len(expected_signature)} bytes, got {result.signature_length} bytes"
        )
    if result.signature != expected_signature:
        raise RuntimeError("signature mismatch against the documented STUB vector")

    print("verified_stub_signature=true")


def main(argv: list[str] | None = None) -> int:
    logging.basicConfig(level=logging.INFO, format="%(levelname)s %(message)s")
    args = _build_parser().parse_args(argv)

    try:
        config = _build_config(args)
    except (ConfigError, ValueError) as exc:
        logging.error("invalid configuration: %s", exc)
        print("BRINGUP_RESULT=FAIL")
        return 2

    try:
        _run_probe(config, clear_status=args.clear_status)
        _run_selftest(config)
    except BackendSelectionError as exc:
        logging.error("cannot create backend: %s", exc)
        print("BRINGUP_RESULT=FAIL")
        return 2
    except SigningExecutionError as exc:
        logging.error("selftest failed: %s", exc)
        print("BRINGUP_RESULT=FAIL")
        return 3
    except OSError as exc:
        logging.error("hardware access failed: %s", exc)
        print("BRINGUP_RESULT=FAIL")
        return 3
    except RuntimeError as exc:
        logging.error("bring-up validation failed: %s", exc)
        print("BRINGUP_RESULT=FAIL")
        return 4

    print("BRINGUP_RESULT=PASS")
    return 0


if __name__ == "__main__":
    sys.exit(main())
