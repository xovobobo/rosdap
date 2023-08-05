vim.g.rosdap_dir = vim.fn.stdpath('data') .. '/lazy/rosdap/'

local getpython_output = function (path, arg)
    return vim.fn.system("python3 " .. path .. " " .. arg)
end

local check_file = function (path)
    if io.open(path, "r") ~= nil then
        return true
    else
        print("[ROSDAP] file not found: " .. path)
        return false
    end
end

local launch_vimspector = function(configurations)
    local json_obj = vim.fn.json_decode(configurations)
    
    for key, cfg in ipairs(json_obj['python']) do
        print(key, vim.inspect(cfg))
        vim.fn['vimspector#LaunchWithConfigurations'](cfg)
    end
end

Get_ros_config = function()
    local python_get_cfg_path = vim.g.rosdap_dir .. "ros_get_config.py"
    local roslaunch_file = vim.fn.getcwd() .. "/.roslaunch"

    if (check_file(python_get_cfg_path) == true) and (check_file(roslaunch_file) == true)then
        local configurations = getpython_output(python_get_cfg_path, roslaunch_file)
        launch_vimspector(configurations)
    end
end,


    

vim.api.nvim_set_keymap('n', '<Leader>tc', ':lua Get_ros_config()<CR>', { noremap = true, silent = true, desc="Get ros configuration" })
