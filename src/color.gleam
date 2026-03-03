import errors
import gleam/float
import gleam/int
import gleam/list
import gleam/pair
import gleam/result
import gleam/string
import utils

pub const rgb_min = 0

pub const rgb_max = 255

pub const alpha_min = 0.0

pub const alpha_max = 1.0

pub opaque type Color {
  Color(red: Int, green: Int, blue: Int, alpha: Float)
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
  let #(r, g, b, _) = rgba(color)
  let assert Ok(r) = rgb_to_hex_string(r)
  let assert Ok(g) = rgb_to_hex_string(g)
  let assert Ok(b) = rgb_to_hex_string(b)
  [r, g, b]
  |> string.join("")
}

pub fn to_rgba_hex_string(color: Color) -> String {
  let #(_, _, _, a) = rgba(color)

  let rgb_str = to_rgb_hex_string(color)

  let assert Ok(a) =
    rgb_to_hex_string(utils.clamp_int(
      float.round(a *. int.to_float(rgb_max)),
      rgb_min,
      rgb_max,
    ))
  [rgb_str, a]
  |> string.join("")
}

pub fn new(red: Int, green: Int, blue: Int, alpha: Float) -> Color {
  let red = utils.clamp_int(red, rgb_min, rgb_max)
  let green = utils.clamp_int(green, rgb_min, rgb_max)
  let blue = utils.clamp_int(blue, rgb_min, rgb_max)
  let alpha = utils.clamp_float(alpha, alpha_min, alpha_max)
  Color(red, green, blue, alpha)
}

// Accepts the following formats in hex values with optional
// starting '#':
// RRGGBB (defaults to alpha of 1)
// RRGGBBAA
pub fn from_hex(s: String) -> Result(Color, errors.ParseError) {
  let s = string.trim(s)
  case string.starts_with(s, "#") {
    True -> from_hex(string.drop_start(s, 1))
    False -> parse_hex_values(s)
  }
}

fn parse_hex_values_aux(chars: List(String)) -> Result(Color, errors.ParseError) {
  // use values <-
  // result.map_error(fn())
  use values <- result.try(
    chars
    |> list.try_map(utils.hex_to_int)
    |> result.map_error(fn(_: Nil) -> errors.ParseError { errors.InvalidChar }),
  )
  values
  |> list.window_by_2()
  |> list.map(fn(p: #(Int, Int)) -> Int { pair.first(p) + pair.second(p) })

  let color =
    case list.length(values) {
      3 -> values
      // rgb_max is used here as we will be using the
      // ratio to compute the final alpha value which is
      // between 0 and 1
      4 -> list.append(values, [rgb_max])
      _ -> panic as "length should already be checked previously"
    }
    |> list.index_fold(
      rgba(NoColor),
      fn(c: #(Int, Int, Int, Float), v: Int, i: Int) -> #(Int, Int, Int, Float) {
        case i {
          0 -> {
            let #(_, g, b, a) = c
            #(v, g, b, a)
          }
          1 -> {
            let #(r, _, b, a) = c
            #(r, v, b, a)
          }
          2 -> {
            let #(r, g, _, a) = c
            #(r, g, v, a)
          }
          3 -> {
            let #(r, g, b, _) = c
            #(r, g, b, int.to_float(v) /. int.to_float(rgb_max))
          }
          _ -> panic as "length should already be checked previously"
        }
      },
    )

  let #(r, g, b, a) = color
  Ok(new(r, g, b, a))
}

pub fn parse_hex_values(s: String) -> Result(Color, errors.ParseError) {
  let chars = string.to_graphemes(s)

  case list.length(chars) {
    6 | 8 -> parse_hex_values_aux(chars)
    _ -> Error(errors.InvalidLength)
  }
}

pub fn rgba(color: Color) -> #(Int, Int, Int, Float) {
  case color {
    Color(r, g, b, a) -> #(r, g, b, a)
    NoColor -> #(0, 0, 0, 0.0)
  }
}
