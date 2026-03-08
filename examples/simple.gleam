import gleam/io
import the_stars/color
import the_stars/styles

pub fn main() {
  // Create a color object via the hex value.
  // Hex string inclusive of alpha value is supported.
  let color = color.new_from_hex("#FF0000")
  // or via its rgba values directly
  let color = color.new(255, 0, 0)

  // Create a new style, then set all the settings
  // as desired.
  let style =
    styles.new()
    |> styles.set_foreground(color)
    |> styles.set_bold(True)

  // Render the value desired with the correct
  // ansi codes.
  let s = styles.render(style, "Hello world!")
  io.println(s)
}
