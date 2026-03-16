from __future__ import annotations

import unittest

from sw.client.client import LocalSigningClient, build_digest_from_args
from sw.mmio import register_map as reg


class ClientServerContractTests(unittest.TestCase):
    def test_local_client_matches_stub_contract(self) -> None:
        client = LocalSigningClient()
        digest = bytes(range(reg.DIGEST_SIZE))
        response = client.sign_prehash(digest)
        self.assertEqual(response.status, "STUB_OK")
        self.assertEqual(response.signature_length, reg.STUB_SIGNATURE_SIZE)
        self.assertEqual(response.signature, reg.build_stub_signature(digest))

    def test_digest_parser_validates_length(self) -> None:
        digest = build_digest_from_args((bytes(range(reg.DIGEST_SIZE))).hex())
        self.assertEqual(len(digest), reg.DIGEST_SIZE)
        with self.assertRaises(Exception):
            build_digest_from_args("00")


if __name__ == "__main__":
    unittest.main()
