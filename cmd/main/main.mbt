fn main()->Unit{
  let hash = @lib.new()
  let buf =  @buffer.new()
  buf.write_bytes(b"")
  let test_data = buf.to_bytes()
  hash.update_from_bytes(test_data)
  let res = hash.finalize_to_base64()
  println(res)
}
