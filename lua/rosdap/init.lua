print("hello world")
Get_ros_config = function()
    print("called")
    local file_path = vim.fn.getcwd() .. "/ros_getconfig.py"
    if io.open(file_path, "r") ~= nil then
        print("readable")
    else
        print(file_path, "was not found")
    end
end,

vim.api.nvim_set_keymap('n', '<Leader>tc', ':lua Get_ros_config()<CR>', { noremap = true, silent = true, desc="Get ros configuration" })
