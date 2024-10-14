local M = {}

local msgid = 1
local sock = nil

local function create_socket(host, port)
    local success, socket = pcall(function()
        return vim.fn.sockconnect("tcp", host .. ":" .. port)
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
    send(sock, cmd)
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

return M
