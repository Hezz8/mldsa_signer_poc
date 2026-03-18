"""Entry point for the pq-signature-appliance software daemon skeleton."""

from __future__ import annotations

import argparse
import logging
import sys

from sw.mmio import register_map as reg
from sw.mmio.probe import probe_device

from .config import ConfigError, DaemonConfig, _parse_optional_int
from .server import (
    BackendSelectionError,
    GrpcDependencyError,
    GrpcSigningServer,
    LocalSigningServer,
    create_default_service,
    create_device_from_config,
)
from .service import SigningExecutionError


def _default_digest() -> bytes:
    return bytes(range(reg.DIGEST_SIZE))


def _build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="PQ signature appliance daemon skeleton")
    parser.add_argument("mode", choices=("serve", "selftest", "probe-mmio"), help="execution mode")
    parser.add_argument("--host", default=None, help="server bind host")
    parser.add_argument("--port", type=int, default=None, help="server bind port")
    parser.add_argument("--timeout-s", type=float, default=None, help="device timeout in seconds")
    parser.add_argument("--poll-interval-s", type=float, default=None, help="poll interval in seconds")
    parser.add_argument("--backend", choices=("fake", "real"), default=None, help="backend mode")
    parser.add_argument("--mmio-base-addr", default=None, help="physical wrapper base address, for example 0xA0000000")
    parser.add_argument("--mmio-region-size", default=None, help="mapped MMIO span in bytes")
    parser.add_argument("--devmem-path", default=None, help="memory device path, default /dev/mem")
    parser.add_argument("--clear-status", action="store_true", help="clear device status before a probe")
    return parser


def _build_config(args: argparse.Namespace) -> DaemonConfig:
    config = DaemonConfig.from_env()
    return config.with_overrides(
        host=args.host,
        port=args.port,
        timeout_s=args.timeout_s,
        poll_interval_s=args.poll_interval_s,
        backend_mode=args.backend,
        mmio_base_addr=_parse_optional_int(args.mmio_base_addr),
        mmio_region_size=_parse_optional_int(args.mmio_region_size),
        devmem_path=args.devmem_path,
    )


def _run_probe(config: DaemonConfig, clear_status: bool) -> int:
    device = create_device_from_config(config)
    try:
        report = probe_device(device, clear_status=clear_status)
    finally:
        device.close()

    print(f"backend={config.backend_mode}")
    if config.mmio_base_addr is not None:
        print(f"mmio_base_addr=0x{config.mmio_base_addr:08X}")
    print(f"mmio_region_size=0x{config.mmio_region_size:X}")
    print(f"status=0x{report.status_value:08X}")
    print(f"status_flags={','.join(report.status_flags) if report.status_flags else 'none'}")
    print(f"error_code={report.error_code}")
    print(f"error_name={report.error_name}")
    print(f"signature_length={report.signature_length}")
    return 0


def _run_stub_selftest(config: DaemonConfig) -> int:
    digest = _default_digest()
    expected_signature = reg.build_stub_signature(digest)
    service = create_default_service(config)
    try:
        local_server = LocalSigningServer(service)
        result = local_server.handle_digest(digest)
    except SigningExecutionError as exc:
        logging.error("selftest failed: %s", exc)
        return 3
    finally:
        service.close()

    if result.signature_length != len(expected_signature):
        logging.error(
            "selftest signature length mismatch: expected %d bytes, got %d bytes",
            len(expected_signature),
            result.signature_length,
        )
        return 4

    if result.signature != expected_signature:
        logging.error("selftest signature mismatch against documented STUB rule")
        logging.error("expected=%s", expected_signature.hex())
        logging.error("actual=%s", result.signature.hex())
        return 4

    print(f"selftest status={result.status} signature_length={result.signature_length}")
    print("verified_stub_signature=true")
    print(result.signature.hex())
    return 0


def main(argv: list[str] | None = None) -> int:
    logging.basicConfig(level=logging.INFO, format="%(levelname)s %(message)s")
    args = _build_parser().parse_args(argv)

    try:
        config = _build_config(args)
    except (ConfigError, ValueError) as exc:
        logging.error("invalid configuration: %s", exc)
        return 2

    if args.mode == "probe-mmio":
        try:
            return _run_probe(config, clear_status=args.clear_status)
        except BackendSelectionError as exc:
            logging.error("cannot create backend: %s", exc)
            return 2
        except OSError as exc:
            logging.error("probe failed: %s", exc)
            return 3
        except Exception as exc:
            logging.error("probe failed: %s", exc)
            return 3

    if args.mode == "selftest":
        try:
            return _run_stub_selftest(config)
        except BackendSelectionError as exc:
            logging.error("cannot create backend: %s", exc)
            return 2

    try:
        service = create_default_service(config)
    except BackendSelectionError as exc:
        logging.error("cannot create backend: %s", exc)
        return 2

    grpc_server = GrpcSigningServer(service, config)
    try:
        grpc_server.start()
    except GrpcDependencyError as exc:
        logging.error("cannot start gRPC server: %s", exc)
        logging.error("install 'grpcio', 'grpcio-tools', and 'protobuf' to enable the transport binding")
        service.close()
        return 2
    grpc_server.wait_for_termination()
    return 0


if __name__ == "__main__":
    sys.exit(main())