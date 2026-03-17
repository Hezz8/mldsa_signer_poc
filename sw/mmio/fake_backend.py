"""Deterministic fake MMIO backend used for local execution and tests."""

from __future__ import annotations

from .backend import BackendError, MMIOBackend
from . import register_map as reg


class FakeMMIOBackend(MMIOBackend):
    """Emulates the documented register map with a deterministic stub signer."""

    def __init__(self) -> None:
        self.reset()

    def reset(self) -> None:
        self._digest = bytearray(reg.DIGEST_SIZE)
        self._signature = bytearray(reg.SIG_WINDOW_SIZE)
        self._busy_ticks_remaining = 0
        self._done = False
        self._error = False
        self._error_code = reg.ERROR_NONE
        self._sig_length = 0

    def read32(self, offset: int) -> int:
        if offset == reg.CONTROL:
            return 0
        if offset == reg.STATUS:
            return self._compose_status()
        if offset == reg.ERROR_CODE:
            return self._error_code
        if offset == reg.SIG_LENGTH:
            return self._sig_length
        if self._is_digest_offset(offset):
            index = (offset - reg.DIGEST_BASE) // 4
            start = index * 4
            return int.from_bytes(self._digest[start : start + 4], "little")
        if self._is_sig_data_offset(offset):
            index = (offset - reg.SIG_DATA_BASE) // 4
            start = index * 4
            return int.from_bytes(self._signature[start : start + 4], "little")
        self._raise_invalid_offset(offset)

    def write32(self, offset: int, value: int) -> None:
        value &= 0xFFFFFFFF
        if offset == reg.CONTROL:
            if value & reg.CONTROL_CLEAR_STATUS_MASK:
                self._clear_status()
            if value & reg.CONTROL_START_MASK:
                self._start_operation()
            return
        if self._is_digest_offset(offset):
            index = (offset - reg.DIGEST_BASE) // 4
            start = index * 4
            self._digest[start : start + 4] = value.to_bytes(4, "little")
            return
        self._raise_invalid_offset(offset)

    def tick(self) -> None:
        if not self._busy_ticks_remaining:
            return
        self._busy_ticks_remaining -= 1
        if self._busy_ticks_remaining == 0:
            self._complete_operation()

    def _compose_status(self) -> int:
        status = 0
        if self._busy_ticks_remaining == 0:
            status |= reg.STATUS_IDLE_MASK
        if self._busy_ticks_remaining > 0:
            status |= reg.STATUS_BUSY_MASK
        if self._done:
            status |= reg.STATUS_DONE_MASK
        if self._error:
            status |= reg.STATUS_ERROR_MASK
        return status

    def _start_operation(self) -> None:
        if self._busy_ticks_remaining > 0:
            self._error = True
            self._done = False
            self._error_code = reg.ERROR_START_WHILE_BUSY
            return
        self._error = False
        self._done = False
        self._error_code = reg.ERROR_NONE
        self._sig_length = 0
        self._signature[:] = bytes(reg.SIG_WINDOW_SIZE)
        self._busy_ticks_remaining = reg.STUB_COMPLETION_TICKS

    def _complete_operation(self) -> None:
        signature = reg.build_stub_signature(bytes(self._digest))
        self._signature[:] = bytes(reg.SIG_WINDOW_SIZE)
        self._signature[: len(signature)] = signature
        self._sig_length = len(signature)
        self._done = True

    def _clear_status(self) -> None:
        self._done = False
        self._error = False
        self._error_code = reg.ERROR_NONE
        if self._busy_ticks_remaining == 0:
            self._sig_length = 0
            self._signature[:] = bytes(reg.SIG_WINDOW_SIZE)

    @staticmethod
    def _is_digest_offset(offset: int) -> bool:
        return reg.DIGEST_BASE <= offset < reg.DIGEST_BASE + (reg.DIGEST_WORDS * 4) and offset % 4 == 0

    @staticmethod
    def _is_sig_data_offset(offset: int) -> bool:
        return reg.SIG_DATA_BASE <= offset < reg.SIG_DATA_BASE + (reg.SIG_DATA_WORDS * 4) and offset % 4 == 0

    def _raise_invalid_offset(self, offset: int) -> None:
        self._error = True
        self._error_code = reg.ERROR_INVALID_OFFSET
        raise BackendError(f"unsupported MMIO offset: 0x{offset:03X}")