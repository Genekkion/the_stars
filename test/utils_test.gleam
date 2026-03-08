import gleeunit
import gleeunit/should
import the_stars/utils

pub fn main() {
  gleeunit.main()
}

pub fn clamp_int_test() {
  utils.clamp_int(2, 1, 3)
  |> should.equal(2)

  utils.clamp_int(1, 2, 3)
  |> should.equal(2)

  utils.clamp_int(3, 2, 3)
  |> should.equal(3)

  utils.clamp_int(4, 2, 3)
  |> should.equal(3)
}

pub fn clamp_float_test() {
  utils.clamp_float(2.0, 1.0, 3.0)
  |> should.equal(2.0)

  utils.clamp_float(1.1, 1.5, 2.0)
  |> should.equal(1.5)

  utils.clamp_float(3.3, 1.0, 3.0)
  |> should.equal(3.0)

  utils.clamp_float(3.2, 1.0, 3.2)
  |> should.equal(3.2)
}
