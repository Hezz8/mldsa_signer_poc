"""High-level MMIO device abstraction used by the daemon."""

from __future__ import annotations

import time

from .backend import BackendError, MMIOBackend
from . import register_map as reg


class DeviceError(RuntimeError):
    """Raised when the device reports an operational error."""


class DeviceTimeoutError(DeviceError):
    """Raised when the device does not complete before the timeout."""


class PQSignatureDevice:
    """High-level interface for the stubbed PQ signature appliance registers."""

    def __init__(self, backend: MMIOBackend) -> None:
        self.backend = backend

    def write_digest(self, digest: bytes) -> None:
        if len(digest) != reg.DIGEST_SIZE:
            raise ValueError(f"digest must be exactly {reg.DIGEST_SIZE} bytes")
        for index in range(reg.DIGEST_WORDS):
            chunk = digest[index * 4 : (index + 1) * 4]
            self.backend.write32(reg.digest_offset(index), int.from_bytes(chunk, "little"))

    def start_operation(self) -> None:
        self.backend.write32(reg.CONTROL, reg.CONTROL_START_MASK)

    def clear_status(self) -> None:
        self.backend.write32(reg.CONTROL, reg.CONTROL_CLEAR_STATUS_MASK)

    def read_status(self) -> int:
        return self.backend.read32(reg.STATUS)

    def wait_done(self, timeout_s: float, poll_interval_s: float = 0.0) -> None:
        deadline = time.monotonic() + timeout_s
        while True:
            status = self.read_status()
            if status & reg.STATUS_ERROR_MASK:
                error_code = self.backend.read32(reg.ERROR_CODE)
                raise DeviceError(f"device reported error code {error_code}")
            if status & reg.STATUS_DONE_MASK:
                return
            if time.monotonic() >= deadline:
                raise DeviceTimeoutError(f"operation did not complete within {timeout_s:.3f}s")
            self.backend.tick()
            if poll_interval_s > 0.0:
                time.sleep(poll_interval_s)

    def read_signature(self) -> bytes:
        sig_length = self.backend.read32(reg.SIG_LENGTH)
        if sig_length <= 0:
            raise DeviceError("signature length is zero; operation is not complete")
        if sig_length > reg.SIG_DATA_SIZE:
            raise DeviceError(f"signature length {sig_length} exceeds stub buffer size")
        output = bytearray()
        for index in range((sig_length + 3) // 4):
            output.extend(self.backend.read32(reg.sig_data_offset(index)).to_bytes(4, "little"))
        return bytes(output[:sig_length])

    def sign_digest(self, digest: bytes, timeout_s: float, poll_interval_s: float = 0.0) -> bytes:
        self.clear_status()
        self.write_digest(digest)
        self.start_operation()
        self.wait_done(timeout_s=timeout_s, poll_interval_s=poll_interval_s)
        signature = self.read_signature()
        self.clear_status()
        return signature

    def close(self) -> None:
        try:
            self.backend.close()
        except BackendError as exc:
            raise DeviceError(str(exc)) from exc
