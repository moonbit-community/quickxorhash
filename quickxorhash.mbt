///|
/// Block size for QuickXorHash
pub const BLOCK_SIZE : Int = 20 * 11 * 8

///|
pub struct QuickXorHash {
  buffer : Array[Byte]
  mut size : UInt64
}

///|
pub fn new() -> QuickXorHash {
  let buf = Array::make(BLOCK_SIZE, 0U.to_byte())
  QuickXorHash::{ buffer: buf, size: 0UL }
}

///|
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

///|
pub fn QuickXorHash::finalize(self : QuickXorHash) -> Array[Byte] {
  let hash21 = Array::make(21, 0U.to_byte())
  let mut i = 0
  while i < BLOCK_SIZE {
    let shift_bits : Int = i * 11 % 160
    let shift_bytes : Int = shift_bits >> 3
    let shift_low : Int = shift_bits & 7
    let v : Byte = (self.buffer[i] << shift_low) & 0xFFFFU.to_byte()
    hash21[shift_bytes] = hash21[shift_bytes] ^ (v & 0xFFU.to_byte())
    hash21[shift_bytes + 1] = hash21[shift_bytes + 1] ^ ((v >> 8) & 0xFFU.to_byte())
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

pub fn finalize_to_bytes(self : QuickXorHash) ->Bytes{
  let buf = @buffer.from_array(self.finalize())
  buf.to_bytes()
}

pub fn finalize_to_base64(self : QuickXorHash) ->String{
  let bytes = self.finalize_to_bytes()
  @base64.std_encode2str(bytes.to_fixedarray())
}