-- Global objects
globals = {
  "vim",
  "_G",
}

-- Rerun tests only if their modification time changed
cache = true

-- Don't report unused self arguments of methods
self = false

checkers = {
  unused = false,
  global = false,
  unused_args = false,
  redefined = false,
}

max_line_length = 150

ignore = {
  "task",
  "entry",
  "entry_point",
}
