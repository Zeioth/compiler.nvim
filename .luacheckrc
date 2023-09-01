-- Global objects
globals = {
  "vim",
  "_G",
  "utils",
}

-- Rerun tests only if their modification time changed
cache = true

-- Don't report unused self arguments of methods
self = false

max_line_length = 150

ignore = {
  311 -- ignore "Value assigned to a local variable is unused"
}
