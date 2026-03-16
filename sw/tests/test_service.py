from __future__ import annotations

import unittest

from sw.daemon.service import SigningService, SigningValidationError
from sw.mmio.device import PQSignatureDevice
from sw.mmio.fake_backend import FakeMMIOBackend
from sw.mmio import register_map as reg


class SigningServiceTests(unittest.TestCase):
    def setUp(self) -> None:
        backend = FakeMMIOBackend()
        device = PQSignatureDevice(backend)
        self.service = SigningService(device=device, timeout_s=0.05, poll_interval_s=0.0)

    def test_invalid_digest_length_is_rejected(self) -> None:
        with self.assertRaises(SigningValidationError):
            self.service.sign_prehash(b"\xAA" * 63)

    def test_sign_prehash_returns_documented_stub_signature(self) -> None:
        digest = bytes(range(reg.DIGEST_SIZE))
        result = self.service.sign_prehash(digest)
        self.assertEqual(result.status, "STUB_OK")
        self.assertEqual(result.signature_length, reg.STUB_SIGNATURE_SIZE)
        self.assertEqual(result.signature, reg.build_stub_signature(digest))


if __name__ == "__main__":
    unittest.main()
