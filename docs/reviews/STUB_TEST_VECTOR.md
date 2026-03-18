# STUB Test Vector

## Purpose

This fixed vector is the known-good reference for the first real board execution in `STUB` mode.

## Digest

The selftest digest is exactly 64 bytes with values `0x00` through `0x3F`.

Hex:

```text
000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f
```

## Expected STUB Signature Rule

The wrapper-visible STUB signature is:

```text
STUBSIG || digest || zero padding
```

where the total signature length is exactly `128` bytes.

## Expected Signature Hex

```text
53545542534947000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
```

## Expected Success Indicators

- `signature_length=128`
- `verified_stub_signature=true`
- printed signature hex exactly matches the value above
