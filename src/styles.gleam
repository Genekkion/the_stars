import color
import gleam/int
import gleam/list
import gleam/string

const ansi_escape_prefix = "\u{001b}["

const ansi_escape_end = "m"

const ansi_delimiter = ";"

// The main style type which contains what colors and
// effects are to be used for rendering
pub opaque type Style {
  Style(
    foreground: color.Color,
    background: color.Color,
    bold: Bool,
    dim: Bool,
    italic: Bool,
    underline: Bool,
    blink: Bool,
    invert: Bool,
    strikethrough: Bool,
  )
}

pub fn new() -> Style {
  Style(
    color.new(0, 0, 0),
    color.NoColor,
    False,
    False,
    False,
    False,
    False,
    False,
    False,
  )
}

fn render_clear() -> String {
  "\u{001b}[0m"
}

pub fn render(style: Style, s: String) -> String {
  let codes =
    [
      render_fg_color(style),
      render_bg_color(style),
      render_boolean(style.bold, "1"),
      render_boolean(style.dim, "2"),
      render_boolean(style.italic, "3"),
      render_boolean(style.underline, "4"),
      render_boolean(style.blink, "5"),
      render_boolean(style.invert, "7"),
      render_boolean(style.strikethrough, "9"),
    ]
    |> list.filter(fn(v: String) -> Bool { string.length(v) > 0 })
    |> string.join(ansi_delimiter)

  ansi_escape_prefix <> codes <> ansi_escape_end <> s <> render_clear()
}

fn render_fg_color(style: Style) -> String {
  case style.foreground {
    color.Color(r, g, b) -> {
      let r_str = int.to_string(r)
      let g_str = int.to_string(g)
      let b_str = int.to_string(b)
      "38;2;" <> r_str <> ";" <> g_str <> ";" <> b_str
    }
    color.NoColor -> {
      "39"
    }
  }
}

fn render_bg_color(style: Style) -> String {
  case style.background {
    color.Color(r, g, b) -> {
      let r_str = int.to_string(r)
      let g_str = int.to_string(g)
      let b_str = int.to_string(b)
      "48;2;" <> r_str <> ";" <> g_str <> ";" <> b_str
    }
    color.NoColor -> {
      "49"
    }
  }
}

fn render_boolean(flag: Bool, value: String) -> String {
  case flag {
    True -> value
    False -> ""
  }
}

pub fn set_foreground(style: Style, color: color.Color) -> Style {
  Style(..style, foreground: color)
}

pub fn get_foreground(style: Style) -> color.Color {
  style.foreground
}

pub fn set_background(style: Style, color: color.Color) -> Style {
  Style(..style, background: color)
}

pub fn get_background(style: Style) -> color.Color {
  style.background
}

pub fn set_bold(style: Style, value: Bool) -> Style {
  Style(..style, bold: value)
}

pub fn get_bold(style: Style) -> Bool {
  style.bold
}

pub fn set_dim(style: Style, value: Bool) -> Style {
  Style(..style, dim: value)
}

pub fn get_dim(style: Style) -> Bool {
  style.dim
}

pub fn set_italic(style: Style, value: Bool) -> Style {
  Style(..style, italic: value)
}

pub fn get_italic(style: Style) -> Bool {
  style.italic
}

pub fn set_underline(style: Style, value: Bool) -> Style {
  Style(..style, underline: value)
}

pub fn get_underline(style: Style) -> Bool {
  style.underline
}

pub fn set_blink(style: Style, value: Bool) -> Style {
  Style(..style, blink: value)
}

pub fn get_blink(style: Style) -> Bool {
  style.blink
}

pub fn set_invert(style: Style, value: Bool) -> Style {
  Style(..style, invert: value)
}

pub fn get_invert(style: Style) -> Bool {
  style.invert
}

pub fn set_strikethrough(style: Style, value: Bool) -> Style {
  Style(..style, strikethrough: value)
}

pub fn get_strikethrough(style: Style) -> Bool {
  style.strikethrough
}
