"""Helpers for safe MMIO visibility probes."""

from __future__ import annotations

from dataclasses import dataclass

from .device import PQSignatureDevice
from . import register_map as reg


@dataclass(frozen=True)
class ProbeReport:
    status_value: int
    status_flags: tuple[str, ...]
    error_code: int
    error_name: str
    signature_length: int


def probe_device(device: PQSignatureDevice, clear_status: bool = False) -> ProbeReport:
    if clear_status:
        device.clear_status()

    status_value = device.read_status()
    error_code = device.read_error_code()
    signature_length = device.read_signature_length()

    return ProbeReport(
        status_value=status_value,
        status_flags=reg.decode_status(status_value),
        error_code=error_code,
        error_name=reg.decode_error_code(error_code),
        signature_length=signature_length,
    )