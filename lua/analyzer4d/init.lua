local M = {}
local com = require("analyzer4d.command")
local config = require("analyzer4d.config")

Config = config.get_default_config()
local connected = false

local function check_connected(func)
    return function()
        if not connected and Config.always_connect then
            M.connect()
        end
        func()
    end
end

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
    if not Config.host then
        Config.host = vim.fn.input("Optimizer4D IP: ")
    end
    com.set_socket(Config.host, Config.port)
    connected = true
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
    Config = config.create_config(opts)
    vim.api.nvim_create_user_command("AnalyzerConnect", check_connected(M.connect), {})
    vim.api.nvim_create_user_command("AnalyzerQmlReload", check_connected(M.reload_qml), {})
    vim.api.nvim_create_user_command("AnalyzerSetAppVar", check_connected(M.set_appvar), {})
    vim.api.nvim_create_user_command("AnalyzerStartMeasuring", check_connected(M.start_measuring), {})
    vim.api.nvim_create_user_command("AnalyzerStopMeasuring", check_connected(M.stop_measuring), {})
    vim.api.nvim_create_user_command("AnalyzerStartOperator", check_connected(M.start_operator), {})
    vim.api.nvim_create_user_command("AnalyzerSubscribeLog", check_connected(M.subscribe_to_log), {})
end

return M
