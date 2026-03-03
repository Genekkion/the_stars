import errors
import gleam/float
import gleam/int
import gleam/string

pub fn clamp_int(value: Int, min: Int, max: Int) -> Int {
  value
  |> int.min(min)
  |> int.max(max)
}

pub fn clamp_float(value: Float, min: Float, max: Float) -> Float {
  value
  |> float.min(min)
  |> float.max(max)
}

pub fn hex_to_int(value: String) -> Result(Int, Nil) {
  let value = string.uppercase(value)
  case value {
    "0" -> Ok(0)
    "1" -> Ok(1)
    "2" -> Ok(2)
    "3" -> Ok(3)
    "4" -> Ok(4)
    "5" -> Ok(5)
    "6" -> Ok(6)
    "7" -> Ok(7)
    "8" -> Ok(8)
    "9" -> Ok(9)
    "A" -> Ok(10)
    "B" -> Ok(11)
    "C" -> Ok(12)
    "D" -> Ok(13)
    "E" -> Ok(14)
    "F" -> Ok(15)
    _ -> Error(Nil)
  }
}

const hex_min = 0

const hex_max = 15

pub fn int_to_hex_char(value: Int) -> Result(String, errors.ParseError) {
  case value >= hex_min && value <= hex_max {
    False -> Error(errors.InvalidValue)
    True ->
      case value < 10 {
        True -> Ok(int.to_string(value))
        False -> {
          // ascii table "A" = 65
          let assert Ok(codepoint) =
            65 + { value - 10 }
            |> string.utf_codepoint
          Ok(string.from_utf_codepoints([codepoint]))
        }
      }
  }
}
