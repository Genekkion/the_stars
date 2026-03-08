import log

pub fn main() {
  // Instead of using the raw style to render, you
  // may opt to instead use a logger, which allows
  // you to store log level styles for easy
  // differentiating of logs via colors, etc.

  // We first create a logger, and set any settings
  // as desired. The tag strings and tag styles may
  // be overriden accordingly.
  let logger =
    log.new()
    |> log.set_level(log.Debug)

  // Now we can use it
  log.log(logger, log.Info, "Hello world!")
}
