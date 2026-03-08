import gleam/dict
import gleam/io
import gleam/string
import the_stars/color
import the_stars/styles

pub type LogLevel {
  Debug
  Info
  Warn
  Error
  Fatal
}

fn log_level_val(level: LogLevel) {
  case level {
    Debug -> 0
    Info -> 1
    Warn -> 2
    Error -> 3
    Fatal -> 4
  }
}

// The logger type contains level specific configs on how
// to render the logs accordingly. In particular, the
// prefix_fn is a special function in which the result
// string will be printed before the tag. This is useful for
// putting things such as timestamp generators, or
// dynamic data.
pub opaque type Logger {
  Logger(
    level: LogLevel,
    tags: dict.Dict(LogLevel, String),
    styles: dict.Dict(LogLevel, styles.Style),
    prefix_fn: fn() -> String,
  )
}

// Creates a new logger.
pub fn new() -> Logger {
  Logger(Info, default_tags(), default_styles(), fn() -> String { "" })
}

// Returns the default tags used in constructing a new
// logger.
pub fn default_tags() -> dict.Dict(LogLevel, String) {
  let def_tags = [
    #(Debug, " D "),
    #(Info, " I "),
    #(Warn, " W "),
    #(Error, " E "),
    #(Fatal, " F "),
  ]

  dict.from_list(def_tags)
}

// Returns the default styles used in constructing a new
// logger.
pub fn default_styles() -> dict.Dict(LogLevel, styles.Style) {
  let style =
    styles.new()
    |> styles.set_bold(True)

  let create_style = fn(fg_hex: String, bg_hex: String) -> styles.Style {
    let assert Ok(fg) = color.new_from_hex(fg_hex)
    let assert Ok(bg) = color.new_from_hex(bg_hex)
    style
    |> styles.set_foreground(fg)
    |> styles.set_background(bg)
  }

  let debug_style = create_style("#FFFFFF", "#414868")
  let info_style = create_style("#FFFFFF", "#485E30")
  let warn_style = create_style("#FFFFFF", "#FF9E64")
  let error_style = create_style("#FFFFFF", "#F7768E")
  let fatal_style = create_style("#FFFFFF", "#BB9AF7")

  let def_styles = [
    #(Debug, debug_style),
    #(Info, info_style),
    #(Warn, warn_style),
    #(Error, error_style),
    #(Fatal, fatal_style),
  ]

  dict.from_list(def_styles)
}

pub fn get_level(logger: Logger) -> LogLevel {
  logger.level
}

pub fn set_level(logger: Logger, level: LogLevel) -> Logger {
  Logger(..logger, level: level)
}

pub fn get_style(logger: Logger, level: LogLevel) -> styles.Style {
  // Guaranteed to be ok so long as there is a style set
  // for the log level. This is enforced via the opaque type
  // and constructor.
  let assert Ok(style) = dict.get(logger.styles, level)
  style
}

pub fn set_style(logger: Logger, level: LogLevel, style: styles.Style) -> Logger {
  let new_styles = dict.insert(logger.styles, level, style)
  Logger(..logger, styles: new_styles)
}

pub fn get_tag(logger: Logger, level: LogLevel) -> String {
  // Guaranteed to be ok so long as there is a tag set
  // for the log level. This is enforced via the opaque type
  // and constructor.
  let assert Ok(style) = dict.get(logger.tags, level)
  style
}

pub fn set_tags(logger: Logger, level: LogLevel, tag: String) -> Logger {
  let new_tags = dict.insert(logger.tags, level, tag)
  Logger(..logger, tags: new_tags)
}

pub fn get_prefix_fn(logger: Logger) -> fn() -> String {
  logger.prefix_fn
}

pub fn set_prefix_fn(logger: Logger, prefix_fn: fn() -> String) -> Logger {
  Logger(..logger, prefix_fn: prefix_fn)
}

// Prints the output to standard output, rendered using the
// style of the level provided.
pub fn log(logger: Logger, level: LogLevel, value: String) {
  case log_level_val(logger.level) <= log_level_val(level) {
    True -> {
      {
        {
          let s = logger.prefix_fn()
          case string.length(s) > 0 {
            True -> s <> " "
            False -> ""
          }
        }
        <> styles.render(get_style(logger, level), get_tag(logger, level))
        <> " "
        <> value
      }
      |> io.println
    }
    False -> Nil
  }
}
