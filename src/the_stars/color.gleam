import gleam/int
import gleam/list
import gleam/result
import gleam/string
import the_stars/errors
import the_stars/utils

pub const rgb_min = 0

pub const rgb_max = 255

// The Color constructor should not be used directly.
// Instead use new or new_from_hex accordingly
pub type Color {
  Color(red: Int, green: Int, blue: Int)
  NoColor
}

fn rgb_to_hex_string(value: Int) -> Result(String, errors.ParseError) {
  let first = value / utils.hex_cap
  let second = value % utils.hex_cap

  use values <- result.try(
    [first, second]
    |> list.try_map(utils.int_to_hex_char),
  )

  Ok(string.join(values, ""))
}

pub fn to_rgb_hex_string(color: Color) -> String {
  let #(r, g, b) = rgb(color)
  let assert Ok(r) = rgb_to_hex_string(r)
  let assert Ok(g) = rgb_to_hex_string(g)
  let assert Ok(b) = rgb_to_hex_string(b)
  [r, g, b]
  |> string.join("")
}

pub fn new(red: Int, green: Int, blue: Int) -> Color {
  let red = utils.clamp_int(red, rgb_min, rgb_max)
  let green = utils.clamp_int(green, rgb_min, rgb_max)
  let blue = utils.clamp_int(blue, rgb_min, rgb_max)
  Color(red, green, blue)
}

// Accepts the following format: "RRGGBB" or "#RRGGBB"
pub fn new_from_hex(s: String) -> Result(Color, errors.ParseError) {
  let s = string.trim(s)
  case string.starts_with(s, "#") {
    True -> new_from_hex(string.drop_start(s, 1))
    False -> parse_hex_values(s)
  }
}

fn parse_hex_values_aux(chars: List(String)) -> Result(Color, errors.ParseError) {
  use values <- result.try(
    chars
    |> list.try_map(utils.hex_to_int)
    |> result.map_error(fn(_: Nil) -> errors.ParseError { errors.InvalidChar }),
  )

  let values =
    values
    |> list.index_fold([], fn(acc, v, i) -> List(Int) {
      case i % 2 == 0 {
        True -> [v * { utils.hex_max + 1 }, ..acc]
        False -> {
          // The length is already accounted for.
          let assert [first, ..acc] = acc
          [first + v, ..acc]
        }
      }
    })
    |> list.reverse()

  let color =
    case list.length(values) {
      3 -> values
      _ -> panic as { "length should already be checked
                previously " <> int.to_string(list.length(values)) }
    }
    |> list.index_fold(
      // rgba(NoColor)
      new(0, 0, 0),
      fn(c: Color, v: Int, i: Int) -> Color {
        case c {
          NoColor -> panic as "should have a base color as accumulator"
          Color(..) -> {
            case i {
              0 -> Color(..c, red: v)
              1 -> Color(..c, green: v)
              2 -> Color(..c, blue: v)
              _ -> panic as "length should already be checked previously"
            }
          }
        }
      },
    )

  Ok(color)
}

fn parse_hex_values(s: String) -> Result(Color, errors.ParseError) {
  let chars = string.to_graphemes(s)

  case list.length(chars) {
    6 -> parse_hex_values_aux(chars)
    _ -> Error(errors.InvalidLength)
  }
}

pub fn rgb(color: Color) -> #(Int, Int, Int) {
  case color {
    Color(r, g, b) -> #(r, g, b)
    NoColor -> #(rgb_min, rgb_min, rgb_min)
  }
}
