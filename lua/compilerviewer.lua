local os = require('os')
local io = require('io')
local string = require('string')
local json = require('lib/json')
local table = require('table')

local function main()
    print("new hello")
end

local split = "right"
local num = 0

local supportedfiletypes = {
    ["c"] = true,
    ["cpp"] = true,
    ["cxx"] = true,
}

local filetypetocompiler = {
    ["c"] = "cc -xc",
    ["cpp"] = "c++ -xc",
    ["cxx"] = "c++ -xc++",
}


local function compile()
    local filepath = vim.api.nvim_buf_get_name(0)
    --print(string.sub(string.reverse(filepath), 0, 2))
    print(vim.bo.filetype)
    if not supportedfiletypes[vim.bo.filetype] then
        return nil
    end
    
    --find compile_commands.json
    local build = io.open("./compile_commands.json", "r") 
    if not build then return nil end
    local c = json.decode(build:read("*a"))

    local command = filetypetocompiler[vim.bo.filetype]
    for key, val in pairs(c[1].arguments) do
        if val == "-c" then
           goto continue 
        end
        if val == "-o" then
           goto continue 
        end
        if string.sub(val, 0, 1) ~= "-"  then
           goto continue 
        end

        command = string.format("%s %s", command, val)
        ::continue::
    end

    command = string.format("%s -S -fverbose-asm -w %s -o a.s", command, filepath)
    os.execute(command)

    local asm = io.lines("./a.s")
    local lines = {}
    for line in asm do
        --todo: additional processing for lines
        --todo: optional removal of all but the asm for a function
        table.insert(lines, line)
    end

    
    os.remove("a.s")
    os.remove("a.d")
    
    return lines
end

local function create_buffer()
    local buf = vim.api.nvim_create_buf(true, true)
    vim.api.nvim_buf_set_name(buf, string.format("CV%d", num))
    num = num + 1

    vim.api.nvim_set_option_value("filetype", "asm",{buf = buf})
    local text = compile()
    if not text then
        return
    end
    --if not vim.api.win_find_buf(buf) then
        vim.api.nvim_open_win(buf, false, {
            split = split,
            win = 0
        })
    --end
    vim.api.nvim_buf_set_lines(buf, 0, -1, true, text)
    return
end


local function setsplit(sp)
    return function()
        split = sp
    end
end

local function setup()
    vim.api.nvim_create_user_command('CVrun', create_buffer, {})
    vim.api.nvim_create_user_command('CVright', setsplit("right"), {})
    vim.api.nvim_create_user_command('CVleft', setsplit("left"), {})
end


return { setup = setup, split = split }
