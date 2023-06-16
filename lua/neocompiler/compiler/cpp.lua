--- c language actions

local M = {}

-- Frontend  - options displayed on telescope
M.options = {
  { text = "1 - Compile and run", value = "option1" },
  { text = "2 - Compile", value = "option2" },
  { text = "3 - Run", value = "option3" }
}

-- Backend - overseer tasks performed on option selected
function M.action(selected_option)

  if selected_option == "option1" then
    print("ENTRA OPCION 1") -- TODO: Llama tarea overseer
  elseif selected_option == "option2" then
    print("ENTRA OPCION 2")
  elseif selected_option == "option3" then
    print("ENTRA OPCION 3")
  end

end

return M
