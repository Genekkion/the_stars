import color
import gleam/io
import log
import styles

// import log

pub fn main() {
  let value = "Hello from the_stars!"

  // let style =
  //   styles.new()
  //   |> styles.set_foreground(color.new(255, 0, 0, 1.0))
  //   |> styles.set_underline(True)
  //
  // let s = styles.render(style, value)
  // io.print(s)

  let logger =
    log.new()
    |> log.set_level(log.Debug)

  log.log(logger, log.Info, value)
  // log.log(logger, "HELLO!")
  // let c = color.new(1, 2, 3, 4.0)
  // c
  // |> color.to_rgba_hex_string()
  // |> io.print()
  // let logger = log.new_logger()
  // log.debug(logger, value)
  // log.info(logger, value)
  // log.warn(logger, value)
  // log.error(logger, value)
  // log.fatal(logger, value)
}
