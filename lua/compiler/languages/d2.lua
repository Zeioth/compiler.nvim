--- D2 language compiler actions
local M = {}

--- Telescope display options
M.options = {
  { text = "Compile D2 to SVG", value = "option1" },
  { text = "Compile D2 to PNG", value = "option2" },
  { text = "Compile D2 to TXT (only file)", value = "option3" },
  { text = "Compile D2 to TXT (file + terminal output)", value = "option4" },
}

--- Execute compiler tasks based on selected option
function M.action(selected_option)
  local utils = require("compiler.utils")
  local overseer = require("overseer")

  -- Get D2 entry point (current buffer > first .d2 in cwd)
  local entry_point = utils.os_path(vim.api.nvim_buf_get_name(0))
  if
    not entry_point
    or entry_point == ""
    or not entry_point:match("%.d2$")
  then
    local d2_files = utils.find_files(vim.fn.getcwd(), "*.d2")
    entry_point = d2_files and #d2_files > 0 and utils.os_path(d2_files[1])
      or nil
  end

  -- Exit if no D2 file found
  if not entry_point then
    vim.notify("No D2 file found!", vim.log.levels.ERROR)
    return
  end

  -- Output paths (same dir as source D2 file)
  local source_dir = utils.os_path(entry_point:match("^(.-[/\\])[^/\\]*$"))
  local filename = entry_point:match("([^/\\]+)%.d2$") or "output"
  local output_svg = utils.os_path(source_dir .. filename .. ".svg")
  local output_png = utils.os_path(source_dir .. filename .. ".png")
  local output_txt = utils.os_path(source_dir .. filename .. ".txt")
  local final_message = "--task finished--"

  -- Compile to SVG
  if selected_option == "option1" then
    local task = overseer.new_task({
      name = "- D2 compiler",
      strategy = {
        "orchestrator",
        tasks = {
          {
            name = '- Compile D2 to SVG → "' .. output_svg .. '"',
            cmd = 'rm -f "'
              .. output_svg
              .. '" || true'
              .. ' && d2 "'
              .. entry_point
              .. '" "'
              .. output_svg
              .. '"'
              .. ' && echo "Compiled: '
              .. entry_point
              .. " → "
              .. output_svg
              .. '"'
              .. ' && echo "'
              .. final_message
              .. '"',
            components = { "default_extended" },
          },
        },
      },
    })
    task:start()

  -- Compile to PNG
  elseif selected_option == "option2" then
    local task = overseer.new_task({
      name = "- D2 compiler",
      strategy = {
        "orchestrator",
        tasks = {
          {
            name = '- Compile D2 to PNG → "' .. output_png .. '"',
            cmd = 'rm -f "'
              .. output_png
              .. '" || true'
              .. ' && d2 "'
              .. entry_point
              .. '" "'
              .. output_png
              .. '"'
              .. ' && echo "Compiled: '
              .. entry_point
              .. " → "
              .. output_png
              .. '"'
              .. ' && echo "'
              .. final_message
              .. '"',
            components = { "default_extended" },
          },
        },
      },
    })
    task:start()

  -- Compile to TXT (only generate file, no terminal output)
  elseif selected_option == "option3" then
    local task = overseer.new_task({
      name = "- D2 compiler",
      strategy = {
        "orchestrator",
        tasks = {
          {
            name = '- Compile D2 to TXT → "' .. output_txt .. '"',
            cmd = 'rm -f "'
              .. output_txt
              .. '" || true'
              .. ' && d2 "'
              .. entry_point
              .. '" "'
              .. output_txt
              .. '"'
              .. ' && echo "Compiled: '
              .. entry_point
              .. " → "
              .. output_txt
              .. '"'
              .. ' && echo "'
              .. final_message
              .. '"',
            components = { "default_extended" },
          },
        },
      },
    })
    task:start()

  -- Compile to TXT (generate file + output content to terminal)
  elseif selected_option == "option4" then
    local task = overseer.new_task({
      name = "- D2 compiler",
      strategy = {
        "orchestrator",
        tasks = {
          {
            name = '- Compile D2 to TXT (with terminal output) → "'
              .. output_txt
              .. '"',
            cmd = 'rm -f "'
              .. output_txt
              .. '" || true'
              .. ' && d2 "'
              .. entry_point
              .. '" "'
              .. output_txt
              .. '"'
              .. ' && echo "=== D2 ASCII Output ==="' -- Separator for clarity
              .. ' && cat "'
              .. output_txt
              .. '"' -- Print TXT content to terminal
              .. ' && echo -e "\\n=== Completion ==="' -- New line + separator
              .. ' && echo "Compiled: '
              .. entry_point
              .. " → "
              .. output_txt
              .. '"'
              .. ' && echo "'
              .. final_message
              .. '"',
            components = { "default_extended" },
          },
        },
      },
    })
    task:start()
  end
end

return M
