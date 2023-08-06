vim.g.rosdap_dir = vim.fn.stdpath('data') .. '/lazy/rosdap/'

local get_bpts = function ()
    return vim.api.nvim_call_function('vimspector#GetBreakpointsAsQuickFix', {})
end

local set_bpts = function(bpts)
    for _, bpt in ipairs(bpts) do
        vim.api.nvim_call_function('vimspector#SetLineBreakpoint', {bpt['filename'], bpt['lnum']})
        -- print(bpt)
    end
end

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
    local current_tabpage = vim.api.nvim_tabpage_get_number(0)
    local current_buff = vim.api.nvim_get_current_buf()
    local bpts = get_bpts()
    -- print(vim.inspect(json_obj))
    for _, cfg in ipairs(json_obj['nodes']) do
        vim.fn['vimspector#NewSession'](cfg['rosdap']['configuration']['name'])
        vim.cmd('badd ' .. cfg['rosdap']['configuration']['program'])
        vim.cmd('buffer ' .. cfg['rosdap']['configuration']['program'])
        vim.fn['vimspector#LaunchWithConfigurations'](cfg)
        set_bpts(bpts)
        vim.cmd('TabooRename ROSDAP-' .. cfg['rosdap']['configuration']['name'])
        vim.api.nvim_set_current_tabpage(current_tabpage)
        vim.api.nvim_set_current_buf(current_buff)
    end
end

function Rosdap_launch()
    local python_get_cfg_path = vim.g.rosdap_dir .. "ros_get_config.py"
    local roslaunch_file = vim.fn.getcwd() .. "/.roslaunch"

    if (check_file(python_get_cfg_path) == true) and (check_file(roslaunch_file) == true)then
        local configurations = getpython_output(python_get_cfg_path, roslaunch_file)
        launch_vimspector(configurations)
    end
end
