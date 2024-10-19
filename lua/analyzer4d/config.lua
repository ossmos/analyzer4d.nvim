local M = {}

function M.get_default_config()
    return {
        host = nil,
        port = 17000,
        auto_connect= true,
        subscribe_log = false,
        clear_log_on_qml_reload = false,
        auto_scroll_log = true,
    }
end

function M.create_config(opts)
    local default_config = M.get_default_config()
    for key, value in pairs(opts) do
        default_config[key] = value
    end
    default_config.host = default_config.host or os.getenv("ANALYZER_HOST")

    if default_config.host == nil then
        vim.api.nvim_err_writeln("Analyzer4D: Host unspecified, can not create socket")
        return
    end
    return default_config
end

return M
