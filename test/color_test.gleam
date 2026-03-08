import color
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

pub fn hex_test() {
  color.new_from_hex("#FFFFFF")
  |> should.be_ok
  |> color.to_rgb_hex_string()
  |> should.equal("FFFFFF")
}
