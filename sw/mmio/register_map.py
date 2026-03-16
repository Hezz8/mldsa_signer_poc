"""Register map constants shared by software tests and the stub device model."""

from __future__ import annotations

from dataclasses import dataclass

CONTROL = 0x000
STATUS = 0x004
ERROR_CODE = 0x008
SIG_LENGTH = 0x00C
DIGEST_BASE = 0x010
DIGEST_WORDS = 16
DIGEST_SIZE = 64
SIG_DATA_BASE = 0x100
SIG_DATA_WORDS = 32
SIG_DATA_SIZE = 128

CONTROL_START_MASK = 1 << 0
CONTROL_CLEAR_STATUS_MASK = 1 << 1

STATUS_IDLE_MASK = 1 << 0
STATUS_BUSY_MASK = 1 << 1
STATUS_DONE_MASK = 1 << 2
STATUS_ERROR_MASK = 1 << 3

ERROR_NONE = 0
ERROR_START_WHILE_BUSY = 1
ERROR_INVALID_OFFSET = 2
ERROR_TIMEOUT = 3

STUB_SIGNATURE_PREFIX = b"STUBSIG"
STUB_SIGNATURE_SIZE = SIG_DATA_SIZE
STUB_COMPLETION_TICKS = 2


def digest_offset(index: int) -> int:
    if not 0 <= index < DIGEST_WORDS:
        raise IndexError(f"digest register index out of range: {index}")
    return DIGEST_BASE + (index * 4)



def sig_data_offset(index: int) -> int:
    if not 0 <= index < SIG_DATA_WORDS:
        raise IndexError(f"signature register index out of range: {index}")
    return SIG_DATA_BASE + (index * 4)



def build_stub_signature(digest: bytes) -> bytes:
    if len(digest) != DIGEST_SIZE:
        raise ValueError(f"digest must be exactly {DIGEST_SIZE} bytes")
    payload = STUB_SIGNATURE_PREFIX + digest
    return (payload + bytes(STUB_SIGNATURE_SIZE - len(payload)))[:STUB_SIGNATURE_SIZE]


@dataclass(frozen=True)
class RegisterLayout:
    control: int = CONTROL
    status: int = STATUS
    error_code: int = ERROR_CODE
    sig_length: int = SIG_LENGTH
    digest_base: int = DIGEST_BASE
    digest_words: int = DIGEST_WORDS
    sig_data_base: int = SIG_DATA_BASE
    sig_data_words: int = SIG_DATA_WORDS


LAYOUT = RegisterLayout()
