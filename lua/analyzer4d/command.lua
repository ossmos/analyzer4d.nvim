local M = {}
local utils = require("analyzer4d.utils")

local msgid = 1
local sock = nil


local function default_handler(response)
    --print(vim.inspect(response))
end

local function handle_responsesetappvar(response)
    if not response["ok"] then
        vim.api.nvim_err_writeln("AppVar operation for appvar " .. response["p1"]  .. " was unsucessful")
        return
    end
    vim.notify("Successfully set the AppVar " .. response["p1"])
end

local function get_response_handler(cmd)
    local handlers = {
        ["responsesetappvar"] = handle_responsesetappvar,
        ["default"] = default_handler
    }
    if handlers[cmd] then
        return handlers[cmd]
    else
        return handlers["default"]
    end
end

local function handle_response(chan_id, data, name)
    local success, resp_table = pcall(function()
        local json_string = utils.remove_json_prefix(data[1])
        return vim.json.decode(json_string)
    end)
    if not success then
        vim.api.nvim_err_writeln("Error while parsing response: " .. vim.inspect(data))
        return
    end
    if not resp_table["cmd"] then
        print("Got unexpected response: " .. vim.inspect(resp_table))
        return
    end

    local response_handler = get_response_handler(resp_table["cmd"])
    response_handler(resp_table)
end

local function create_socket(host, port)
    local success, socket = pcall(function()
        return vim.fn.sockconnect("tcp", host .. ":" .. port, {on_data=handle_response})
    end)
    if success then
        return socket
    end
    vim.api.nvim_err_writeln("Unable to connect to " .. host .. ":" .. port)
end

function M.set_socket(host, port)
    sock = create_socket(host, port)
end

local function add_msgid(cmd)
    cmd.msgid = msgid
    msgid = msgid + 1
    return cmd
end

local function send(socket, cmd)
    cmd = add_msgid(cmd)
    local msg = vim.json.encode(cmd)
    if not sock then
        vim.api.nvim_err_writeln("Socket is not connected")
        return
    end
    vim.fn.chansend(socket, msg)
end

local function send_appcmd(opts)
    opts.cmd = "AppCmd"
    send(sock, opts)
end

local function send_cmd(cmd)
    send(sock, cmd)
end

function M.reload_qml()
    local opts = {
        p1 = "LoadPenGUI",
        p2 = "reload"
    }
    send_appcmd(opts)
end

function M.set_appvar(appvar, value)
    assert(type(appvar) == "string", "appvar name must be a string")
    assert(type(value) == "string", "appvar value must be a string")

    local cmd = {
        cmd = "setappvar",
        p1 = appvar,
        p2 = value
    }
    send_cmd(cmd)
end

function M.start_measuring()
    local opts = {
        p1 = "startMeasuring"
    }
    send_appcmd(opts)
end

function M.stop_measuring()
    local opts = {
        p1 = "stopMeasuring"
    }
    send_appcmd(opts)
end

function M.start_operator(op_name, params)
    local cmd = {
        cmd = "startoperator",
        p1 = op_name,
        p2 = params
    }
    send_cmd(cmd)
end

function M.subscribe_to_log()
    local cmd = {
        cmd = "reportlog",
        p1 = true,
        p2 = "striphtml"
    }
    send_cmd(cmd)
end

return M
