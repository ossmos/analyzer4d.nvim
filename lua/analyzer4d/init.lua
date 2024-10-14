local M = {}
local com = require("analyzer4d.command")

local defaults = {
    host = nil,
    port = 17000,
    always_connect = false
}

function M.set_appvar()
    local appvar_name = vim.fn.input("AppVar name: ")
    local appvar_value = vim.fn.input("AppVar value: ")
    if appvar_name == "" then
        vim.api.nvim_err_writeln("AppVar Name can not be an empty string")
        return
    end
    com.set_appvar(appvar_name, appvar_value)
end

function M.connect()
    local host
    if not defaults.host then
        host = vim.fn.input("Optimizer4D IP: ")
    else
        host = defaults.host
    end
    com.set_socket(host, defaults.port)
end

function M.reload_qml()
    com.reload_qml()
end

function M.start_measuring()
    com.stop_measuring()
end

function M.stop_measuring()
    com.stop_measuring()
end

function M.start_operator()
    local op_name = vim.fn.input("Operator Name: ")
    local params = vim.fn.input("Parameters: ")
    com.start_operator(op_name, params)
end

function M.subscribe_to_log()
    com.subscribe_to_log()
end

function M.setup(opts)
    for key, value in pairs(opts) do
        defaults[key] = value
    end
    defaults.host = defaults.host or os.getenv("ANALYZER_HOST")

    if defaults.host == nil then
        vim.api.nvim_err_writeln("Analyzer4D: Host unspecified, can not create socket")
        return
    end
    if defaults.always_connect then
        com.set_socket(defaults.host, defaults.port)
    end
    vim.api.nvim_create_user_command("AnalyzerConnect", M.connect, {})
    vim.api.nvim_create_user_command("AnalyzerQmlReload", M.reload_qml, {})
    vim.api.nvim_create_user_command("AnalyzerSetAppVar", M.set_appvar, {})
    vim.api.nvim_create_user_command("AnalyzerStartMeasuring", M.start_measuring, {})
    vim.api.nvim_create_user_command("AnalyzerStopMeasuring", M.stop_measuring, {})
    vim.api.nvim_create_user_command("AnalyzerStartOperator", M.start_operator, {})
    vim.api.nvim_create_user_command("AnalyzerSubscribeLog", M.subscribe_to_log, {})
end

return M
