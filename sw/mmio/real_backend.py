"""Real MMIO backend intended for Linux user-space bring-up on Zynq."""

from __future__ import annotations

import errno
import mmap
import os
import struct

from .backend import BackendError, MMIOBackend


class RealMMIOBackend(MMIOBackend):
    """PoC user-space MMIO backend using a memory-mapped file descriptor.

    The intended target-board path is ``/dev/mem`` on Linux with a page-aligned
    physical base address provided by software configuration. Local tests may
    point ``device_path`` at a normal file to exercise mapping and register I/O
    logic without target hardware.
    """

    def __init__(self, base_address: int, region_size: int, device_path: str = "/dev/mem") -> None:
        if base_address < 0:
            raise BackendError("base address must be non-negative")
        if region_size <= 0:
            raise BackendError("region size must be positive")

        self.base_address = base_address
        self.region_size = region_size
        self.device_path = device_path
        self.page_size = getattr(mmap, "PAGESIZE", getattr(mmap, "ALLOCATIONGRANULARITY", 4096))
        self.page_base = base_address & ~(self.page_size - 1)
        self.page_offset = base_address - self.page_base
        self.mapped_size = self.page_offset + region_size
        self._fd: int | None = None
        self._mapping: mmap.mmap | None = None

        try:
            self._fd = os.open(device_path, os.O_RDWR | getattr(os, "O_SYNC", 0))
            self._mapping = self._create_mapping(self._fd)
        except OSError as exc:
            self.close()
            raise BackendError(self._format_open_error(exc)) from exc

    def _format_open_error(self, exc: OSError) -> str:
        message = f"unable to map MMIO region via {self.device_path}: {exc.strerror or exc}"
        if self.device_path == "/dev/mem":
            if exc.errno == errno.ENOENT:
                message += "; /dev/mem is unavailable on this host or image"
            elif exc.errno in {errno.EACCES, errno.EPERM}:
                message += "; /dev/mem requires appropriate privileges on the target Linux system"
            message += "; expected bring-up path is Linux on Zynq with the wrapper base address supplied"
        return message

    def _create_mapping(self, fd: int) -> mmap.mmap:
        if os.name == "nt":
            return mmap.mmap(fd, length=self.mapped_size, access=mmap.ACCESS_WRITE, offset=self.page_base)
        return mmap.mmap(
            fd,
            length=self.mapped_size,
            flags=mmap.MAP_SHARED,
            prot=mmap.PROT_READ | mmap.PROT_WRITE,
            offset=self.page_base,
        )

    def _absolute_offset(self, offset: int) -> int:
        if offset < 0:
            raise BackendError("MMIO offsets must be non-negative")
        if offset % 4 != 0:
            raise BackendError(f"MMIO accesses must be 32-bit aligned, got offset 0x{offset:X}")
        if offset + 4 > self.region_size:
            raise BackendError(
                f"MMIO offset 0x{offset:X} exceeds mapped region size 0x{self.region_size:X}"
            )
        return self.page_offset + offset

    def read32(self, offset: int) -> int:
        if self._mapping is None:
            raise BackendError("MMIO region is not mapped")
        absolute_offset = self._absolute_offset(offset)
        return struct.unpack_from("<I", self._mapping, absolute_offset)[0]

    def write32(self, offset: int, value: int) -> None:
        if self._mapping is None:
            raise BackendError("MMIO region is not mapped")
        absolute_offset = self._absolute_offset(offset)
        struct.pack_into("<I", self._mapping, absolute_offset, value & 0xFFFFFFFF)

    def flush(self) -> None:
        if self._mapping is None:
            return
        try:
            self._mapping.flush()
        except OSError:
            pass

    def close(self) -> None:
        if self._mapping is not None:
            self._mapping.close()
            self._mapping = None
        if self._fd is not None:
            os.close(self._fd)
            self._fd = None