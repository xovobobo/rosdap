vim.g.rosdap_dir = vim.fn.stdpath('data') .. '/lazy/rosdap/'

local getpython_output = function (path)
    return vim.fn.system("python3 " .. path)
end


Get_ros_config = function()
    print("called")
    local python_get_cfg_path = vim.g.rosdap_dir .. "ros_get_config.py"
    local found = false
    if io.open(python_get_cfg_path, "r") ~= nil then
        
        local result = getpython_output(python_get_cfg_path)

    else
        print(python_get_cfg_path, "was not found")
    end
end,



vim.api.nvim_set_keymap('n', '<Leader>tc', ':lua Get_ros_config()<CR>', { noremap = true, silent = true, desc="Get ros configuration" })
