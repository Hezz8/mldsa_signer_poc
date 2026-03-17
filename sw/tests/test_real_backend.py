from __future__ import annotations

import os
import tempfile
import unittest

from sw.mmio.backend import BackendError
from sw.mmio.real_backend import RealMMIOBackend
from sw.mmio import register_map as reg


class RealBackendTests(unittest.TestCase):
    def _make_backing_file(self, size: int) -> str:
        fd, path = tempfile.mkstemp()
        os.close(fd)
        with open(path, "wb") as handle:
            handle.truncate(size)
        self.addCleanup(lambda: os.path.exists(path) and os.remove(path))
        return path

    def test_file_backed_mapping_supports_read_write(self) -> None:
        path = self._make_backing_file(reg.MMIO_REGION_SIZE)
        backend = RealMMIOBackend(base_address=0, region_size=reg.MMIO_REGION_SIZE, device_path=path)
        self.addCleanup(backend.close)

        backend.write32(reg.CONTROL, reg.CONTROL_CLEAR_STATUS_MASK)
        backend.write32(reg.digest_offset(0), 0x44332211)
        backend.flush()

        self.assertEqual(backend.read32(reg.CONTROL), reg.CONTROL_CLEAR_STATUS_MASK)
        self.assertEqual(backend.read32(reg.digest_offset(0)), 0x44332211)

    def test_unaligned_access_is_rejected(self) -> None:
        path = self._make_backing_file(0x1000)
        backend = RealMMIOBackend(base_address=0, region_size=0x1000, device_path=path)
        self.addCleanup(backend.close)

        with self.assertRaises(BackendError):
            backend.read32(0x002)

    def test_missing_device_path_fails_cleanly(self) -> None:
        with self.assertRaises(BackendError):
            RealMMIOBackend(base_address=0, region_size=0x1000, device_path="/definitely/missing")


if __name__ == "__main__":
    unittest.main()