///|
/// Block size for QuickXorHash.
/// This constant defines the internal block size (in bytes) used by the
/// QuickXorHash algorithm. It equals 20 * 11 * 8 and is used when folding
/// input data into the 160-bit internal buffer.
pub const BLOCK_SIZE : Int = 20 * 11 * 8

///|
/// In-memory state for a QuickXorHash computation.
///
/// Fields:
/// - buffer: internal state buffer (length = BLOCK_SIZE) where bytes are XORed
///   as data is fed into the hash.
/// - size: total number of bytes that have been fed into this hash instance.
pub struct QuickXorHash {
  buffer : Array[Byte]
  mut size : UInt64
}

///|
/// Create a new QuickXorHash instance.
///
/// Returns a `QuickXorHash` with its internal buffer zero-initialized and
/// `size` set to 0. Use `update` (or the typed variants) to feed data.
pub fn new() -> QuickXorHash {
  let buf = Array::make(BLOCK_SIZE, 0U.to_byte())
  QuickXorHash::{ buffer: buf, size: 0UL }
}

///|
/// Update the hash state with the provided `Bytes` data.
///
/// This function XORs incoming bytes into the internal `buffer` in a rolling
/// fashion using `BLOCK_SIZE`-sized blocks. It updates the internal `size`
/// counter to reflect the total number of bytes processed. The function does
/// nothing when `data` is empty.
///
/// Parameters:
/// - `self`: the QuickXorHash instance to update (mutated in-place).
/// - `data`: input bytes to feed into the hash.
///
/// Returns: Unit. Side effect: `self.buffer` and `self.size` are updated.
pub fn QuickXorHash::update(
  self : QuickXorHash,
  data : Bytes,
) -> Unit {
  if data.length() == 0 {
    return
  }
  let mut i = 0
  let mut pos_in_block = (self.size % BLOCK_SIZE.to_uint64()).to_int()
  while pos_in_block != 0 && i < data.length() {
    self.buffer[pos_in_block] = self.buffer[pos_in_block] ^ (data[i] & 0xFFU.to_byte())
    pos_in_block = (pos_in_block + 1) % BLOCK_SIZE
    self.size = self.size + 1UL
    i = i + 1
  }
  if i == data.length() {
    return
  }
  while data.length() - i >= BLOCK_SIZE {
    let mut j = 0
    while j < BLOCK_SIZE {
      self.buffer[j] = self.buffer[j] ^ (data[i + j] & 0xFFU.to_byte())
      j = j + 1
    }
    i = i + BLOCK_SIZE
    self.size = self.size + BLOCK_SIZE.to_uint64()
  }
  pos_in_block = 0
  while i < data.length() {
    self.buffer[pos_in_block] = self.buffer[pos_in_block] ^ (data[i] & 0xFFU.to_byte())
    pos_in_block = pos_in_block + 1
    self.size = self.size + 1UL
    i = i + 1
  }
}

/// Update the hash state using a `BytesView` slice.
///
/// Semantically identical to `update`, but accepts `BytesView` (a view into
/// existing bytes) rather than an owned `Bytes`. The internal buffer and size
/// are updated in the same way.
pub fn QuickXorHash::update_from_bytes_view(
  self : QuickXorHash,
  data : BytesView,
) -> Unit {
  if data.length() == 0 {
    return
  }
  let mut i = 0
  let mut pos_in_block = (self.size % BLOCK_SIZE.to_uint64()).to_int()
  while pos_in_block != 0 && i < data.length() {
    self.buffer[pos_in_block] = self.buffer[pos_in_block] ^ (data[i] & 0xFFU.to_byte())
    pos_in_block = (pos_in_block + 1) % BLOCK_SIZE
    self.size = self.size + 1UL
    i = i + 1
  }
  if i == data.length() {
    return
  }
  while data.length() - i >= BLOCK_SIZE {
    let mut j = 0
    while j < BLOCK_SIZE {
      self.buffer[j] = self.buffer[j] ^ (data[i + j] & 0xFFU.to_byte())
      j = j + 1
    }
    i = i + BLOCK_SIZE
    self.size = self.size + BLOCK_SIZE.to_uint64()
  }
  pos_in_block = 0
  while i < data.length() {
    self.buffer[pos_in_block] = self.buffer[pos_in_block] ^ (data[i] & 0xFFU.to_byte())
    pos_in_block = pos_in_block + 1
    self.size = self.size + 1UL
    i = i + 1
  }
}

/// Update the hash state using an `Array[Byte]` input.
///
/// Functionally the same as `update` but accepts a plain byte array. Useful
/// when caller already has data in `Array[Byte]` form.
pub fn QuickXorHash::update_from_byte_array(
  self : QuickXorHash,
  data : Array[Byte],
) -> Unit {
  if data.length() == 0 {
    return
  }
  let mut i = 0
  let mut pos_in_block = (self.size % BLOCK_SIZE.to_uint64()).to_int()
  while pos_in_block != 0 && i < data.length() {
    self.buffer[pos_in_block] = self.buffer[pos_in_block] ^ (data[i] & 0xFFU.to_byte())
    pos_in_block = (pos_in_block + 1) % BLOCK_SIZE
    self.size = self.size + 1UL
    i = i + 1
  }
  if i == data.length() {
    return
  }
  while data.length() - i >= BLOCK_SIZE {
    let mut j = 0
    while j < BLOCK_SIZE {
      self.buffer[j] = self.buffer[j] ^ (data[i + j] & 0xFFU.to_byte())
      j = j + 1
    }
    i = i + BLOCK_SIZE
    self.size = self.size + BLOCK_SIZE.to_uint64()
  }
  pos_in_block = 0
  while i < data.length() {
    self.buffer[pos_in_block] = self.buffer[pos_in_block] ^ (data[i] & 0xFFU.to_byte())
    pos_in_block = pos_in_block + 1
    self.size = self.size + 1UL
    i = i + 1
  }
}

///|
/// Finalize the QuickXorHash and return the 20-byte hash value.
///
/// This computes the QuickXorHash output from the internal `buffer` and
/// `size`. The algorithm shifts and XORs buffer bytes into a 21-byte
/// temporary array, folds the 21st byte into the first, then produces a
/// 20-byte result. The final 8 bytes (positions 12..19) are XORed with the
/// little-endian encoding of `size`.
///
/// Returns: Array[Byte] of length 20 containing the finalized hash.
pub fn QuickXorHash::finalize(self : QuickXorHash) -> Array[Byte] {
  let hash21 = Array::make(21, 0U.to_byte())
  let mut i = 0
  while i < BLOCK_SIZE {
    let shift_bits : Int = i * 11 % 160
    let shift_bytes : Int = shift_bits >> 3
    let shift_low : Int = shift_bits & 7
    let v : Int = self.buffer[i].to_int() << shift_low
    hash21[shift_bytes] = hash21[shift_bytes] ^ (v & 0xFF).to_byte()
    hash21[shift_bytes + 1] = hash21[shift_bytes + 1] ^ ((v >> 8) & 0xFF).to_byte()
    i = i + 1
  }
  hash21[0] = hash21[0] ^ hash21[20]
  let result = Array::make(20, 0U.to_byte())
  let mut t = 0
  while t < 20 {
    result[t] = hash21[t]
    t = t + 1
  }
  let mut s : UInt64 = self.size
  let mut b = 0
  while b < 8 {
    result[12 + b] = result[12 + b] ^ s.land(0xFFUL).to_byte()
    s = s >> 8
    b = b + 1
  }
  result
}

/// Convert the finalized 20-byte hash to a `Bytes` object.
///
/// This calls `finalize()` and returns the result as an owned `Bytes` object.
pub fn finalize_to_bytes(self : QuickXorHash) ->Bytes{
  let buf = @buffer.from_array(self.finalize())
  buf.to_bytes()
}

/// Finalize the hash and return the Base64 (standard) encoding as a string.
///
/// Steps: finalize -> convert to `Bytes` -> encode using standard base64.
pub fn finalize_to_base64(self : QuickXorHash) ->String{
  let bytes = self.finalize_to_bytes()
  @base64.std_encode2str(bytes.to_fixedarray())
}