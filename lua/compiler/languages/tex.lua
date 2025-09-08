--- LaTeX actions

local M = {}

--- Frontend - options displayed on telescope
M.options = {
	{ text = "Build PDF", value = "option1" },
	{ text = "Clean auxiliary files", value = "option2" },
	{ text = "Clean all generated files", value = "option3" },
}

--- Backend - overseer tasks performed on option selected
function M.action(selected_option)
	local overseer = require("overseer")
	local utils = require("compiler.utils")

	local entry_point = vim.fn.expand("%:p")
	local entry_dir = vim.fn.fnamemodify(entry_point, ":h")
	local file_name = vim.fn.fnamemodify(entry_point, ":t")
	local file_root = vim.fn.fnamemodify(entry_point, ":r")
	local final_message = "--task finished--"

	local rm_cmd = (vim.loop.os_uname().sysname == "Windows_NT") and "del /Q" or "rm -f"
	local cd_cmd = (vim.loop.os_uname().sysname == "Windows_NT") and "cd /d" or "cd"

	if selected_option == "option1" then
		-- 使用 latexmk 编译 PDF
		local task = overseer.new_task({
			name = "- LaTeX build",
			strategy = {
				"orchestrator",
				tasks = {
					{
						name = '- Build PDF → "' .. file_name .. '"',
						cmd = cd_cmd
							.. ' "'
							.. entry_dir
							.. '"'
							.. ' && latexmk -pdf -interaction=nonstopmode -file-line-error "'
							.. file_name
							.. '"'
							.. ' && echo "'
							.. entry_point
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
	elseif selected_option == "option2" then
		local task = overseer.new_task({
			name = "- LaTeX clean aux",
			strategy = {
				"orchestrator",
				tasks = {
					{
						name = '- Clean aux files → "' .. file_name .. '"',
						cmd = cd_cmd
							.. ' "'
							.. entry_dir
							.. '"'
							.. ' && latexmk -c "'
							.. file_name
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
	elseif selected_option == "option3" then
		local task = overseer.new_task({
			name = "- LaTeX clean all",
			strategy = {
				"orchestrator",
				tasks = {
					{
						name = '- Clean all files → "' .. file_name .. '"',
						cmd = cd_cmd
							.. ' "'
							.. entry_dir
							.. '"'
							.. ' && latexmk -C "'
							.. file_name
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
