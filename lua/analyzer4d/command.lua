local M = {}
local utils = require("analyzer4d.utils")

local msgid = 1
local sock = nil

local connect_callbacks = {}

local handlers = {

}

function M.add_connect_callback(callback)
    table.insert(connect_callbacks, callback)
end

local function close_socket(socket)
    socket:shutdown()
    socket:close()
    sock = nil
end

function M.is_connected()
    return sock ~= nil
end

function M.disconnect()
    close_socket(sock)
end

local function debug_handler(msg)
    print("MSG: " .. vim.inspect(msg))
end

local function default_handler(response)
    --print(vim.inspect(response))
end

local function handle_responsesetappvar(response)
    if not response["ok"] then
        vim.schedule(function()
            vim.api.nvim_err_writeln("AppVar operation for appvar " .. response["p1"]  .. " was unsucessful")
        end)
        return
    end
    vim.schedule(function()
        vim.notify("Successfully set the AppVar " .. response["p1"])
    end)
end

local function get_response_handler(cmd)
    if handlers[cmd] then
        return handlers[cmd]
    else
        return handlers["default"]
    end
end

local function handle_response(data)
    if data == nil then
        close_socket(sock)
        return
    end
    local success, resp_table = pcall(function()
        local json_string = utils.remove_json_prefix(data)
        return vim.json.decode(json_string)
    end)
    if not success then
        vim.schedule_wrap(function()
            vim.api.nvim_err_writeln("Error while parsing response: " .. vim.inspect(data))
        end)
        return
    end
    if not resp_table["cmd"] then
        print("Got unexpected response: " .. vim.inspect(resp_table))
        return
    end

    local response_handler = get_response_handler(resp_table["cmd"])
    response_handler(resp_table)
end

local function add_response_handler(response_cmd, handler)
    handlers[response_cmd] = handler
end

local function add_response_handlers()
    add_response_handler("responsesetappvar", handle_responsesetappvar)
    add_response_handler("default", default_handler)
end

local function socket_loop(socket)
    assert(socket, "client not started")
    socket:read_start(function(err, chunk)
        if err then
            vim.schedule(function()
                vim.api.nvim_err_writeln("Error reading from socket")
            end)
            return
        end
        handle_response(chunk)
    end)
end

local function create_socket(host, port) -- returns a uv_connect_t object
    add_response_handlers()
    sock = vim.uv.new_tcp()
    sock:connect(host, port, function(err)
        if err then
            vim.schedule(function()
                vim.api.nvim_err_writeln("Error connecting to " .. host .. ":" .. port)
                sock = nil
            end)
            return
        end
        socket_loop(sock)
    end)
    if sock then
        for i=1, #connect_callbacks do
            connect_callbacks[i]()
        end
    end
    return sock
end

function M.set_socket(host, port)
    sock = create_socket(host, port)
    return sock ~= nil
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
    socket:write(msg)
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

function M.subscribe_to_log(msg_handler)
    add_response_handler("responselog", function(cmd)
        local msg = cmd["msg"]
        if msg then
            msg_handler(msg)
        end
    end)
    local cmd = {
        cmd = "reportlog",
        p1 = true,
        p2 = "striphtml"
    }
    send_cmd(cmd)
end


return M
