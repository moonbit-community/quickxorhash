# quickxorhash

A MoonBit implementation of the QuickXorHash algorithm. This package provides
a small in-memory hash computation that follows the QuickXorHash folding and
XOR rules and exposes a minimal API for incremental updates and finalization.

Contents
 - `quickxorhash.mbt` — core implementation and public API.
 - `cmd/main/` — example CLI (entry point) for the package.
 - `quickxorhash_test.mbt` — blackbox tests.

Quick start

API (high level)

The primary type is `QuickXorHash` with the following useful functions:

- `new() -> QuickXorHash`
	- Create a new hash instance.

- `QuickXorHash::update_from_bytes(self, data : Bytes) -> Unit`
	- Feed owned `Bytes` into the running hash.

- `QuickXorHash::update_from_bytes_view(self, data : BytesView) -> Unit`
	- Feed a view/slice of bytes without taking ownership.

- `QuickXorHash::update_from_byte_array(self, data : Array[Byte]) -> Unit`
	- Feed a plain byte array.

- `QuickXorHash::finalize_to_byte_array(self) -> Array[Byte]`
	- Produce the 20-byte raw hash as `Array[Byte]`.

- `QuickXorHash::finalize_to_bytes(self) -> Bytes`
	- Produce the 20-byte hash as `Bytes`.

- `QuickXorHash::finalize_to_base64(self) -> String`
	- Produce the standard Base64 encoding of the 20-byte hash.

Example

```text
let h = @quickxorhash.new()
h.update_from_bytes(@buffer.from_str("hello").to_bytes())
let raw = h.finalize_to_byte_array()
let b64 = h.finalize_to_base64()
```
