fn main()->Unit{
  let hash = @lib.new_quick_xor_hash()
  let test_data = Array::make(10,0U.to_byte())
  hash.update(test_data)
  let res = hash.finalize()
  println(res)
}
