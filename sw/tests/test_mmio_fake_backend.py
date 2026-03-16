from __future__ import annotations

import unittest

from sw.mmio.device import PQSignatureDevice
from sw.mmio.fake_backend import FakeMMIOBackend
from sw.mmio import register_map as reg


class FakeBackendTests(unittest.TestCase):
    def test_write_digest_validates_length(self) -> None:
        device = PQSignatureDevice(FakeMMIOBackend())
        with self.assertRaises(ValueError):
            device.write_digest(b"\x00" * 63)

    def test_state_transitions_and_signature_readback(self) -> None:
        backend = FakeMMIOBackend()
        device = PQSignatureDevice(backend)
        digest = bytes(range(reg.DIGEST_SIZE))

        device.write_digest(digest)
        device.start_operation()

        busy_status = device.read_status()
        self.assertTrue(busy_status & reg.STATUS_BUSY_MASK)
        self.assertFalse(busy_status & reg.STATUS_DONE_MASK)

        device.wait_done(timeout_s=0.05, poll_interval_s=0.0)
        done_status = device.read_status()
        self.assertTrue(done_status & reg.STATUS_DONE_MASK)
        self.assertTrue(done_status & reg.STATUS_IDLE_MASK)

        signature = device.read_signature()
        self.assertEqual(signature, reg.build_stub_signature(digest))
        self.assertEqual(len(signature), reg.STUB_SIGNATURE_SIZE)

        device.clear_status()
        cleared_status = device.read_status()
        self.assertEqual(cleared_status, reg.STATUS_IDLE_MASK)


if __name__ == "__main__":
    unittest.main()
