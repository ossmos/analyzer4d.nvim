local M = {}
local com = require("analyzer4d.command")
local config = require("analyzer4d.config")

Config = config.get_default_config()
local connected = false
local log_buf = vim.api.nvim_create_buf(false, true)
local log_win = nil


local function configure_log_buffer(buf)
    vim.api.nvim_set_option_value("buftype", "nofile", {buf = buf})
    vim.api.nvim_buf_set_name(buf, "Analyzer4D log")
    vim.api.nvim_create_autocmd({"BufWritePre"}, {
        pattern = "Analyzer4D log",
        callback = function()
            vim.api.nvim_buf_set_var(buf, "modified", false)
        end
    })
end

local function check_connected(func)
    return function()
        if not com.is_connected() and Config.auto_connect then
            M.connect()
            if not connected then return end
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
end

function M.reload_qml()
    if Config.clear_log_on_qml_reload then
        vim.api.nvim_buf_set_lines(log_buf, 0, -1, false, {})
    end
    com.reload_qml()
end

function M.start_measuring()
    com.start_measuring()
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
    configure_log_buffer(log_buf)
    local log_handler = function(entry)
        vim.schedule(function()
            vim.api.nvim_buf_set_lines(log_buf, -1, -1, false, { entry })
            if not Config.auto_scroll_log then
                return
            end
            local windows = vim.fn.win_findbuf(log_buf)
            for i=1, #windows do
                vim.api.nvim_win_set_cursor(windows[i], {vim.api.nvim_buf_line_count(log_buf), 0})
            end
        end)
    end
    com.subscribe_to_log(log_handler)
end

function M.toggle_log()
    if log_win then
        vim.api.nvim_win_close(log_win, true)
        log_win = nil
        return
    end
    log_win = vim.api.nvim_open_win(log_buf, true, {split = "left", win = 0})
    vim.api.nvim_set_option_value("wrap", true, {win = log_win})
    if Config.auto_scroll_log then
        vim.api.nvim_win_set_cursor(log_win, {vim.api.nvim_buf_line_count(log_buf), 0})
    end
end

function M.setup(opts)
    Config = config.create_config(opts)
    if Config.subscribe_log then
        com.add_connect_callback(M.subscribe_to_log)
    end
    vim.api.nvim_create_autocmd({"VimLeave"}, {
        callback = function()
            com.disconnect()
        end
    })
    vim.api.nvim_create_user_command("AnalyzerToggleLog", M.toggle_log, {})
    vim.api.nvim_create_user_command("AnalyzerQmlReload", check_connected(M.reload_qml), {})
    vim.api.nvim_create_user_command("AnalyzerSetAppVar", check_connected(M.set_appvar), {})
    vim.api.nvim_create_user_command("AnalyzerStartMeasuring", check_connected(M.start_measuring), {})
    vim.api.nvim_create_user_command("AnalyzerStopMeasuring", check_connected(M.stop_measuring), {})
    vim.api.nvim_create_user_command("AnalyzerStartOperator", check_connected(M.start_operator), {})
    vim.api.nvim_create_user_command("AnalyzerSubscribeLog", check_connected(M.subscribe_to_log), {})
    vim.api.nvim_create_user_command("AnalyzerConnect", M.connect, {})
end

return M
