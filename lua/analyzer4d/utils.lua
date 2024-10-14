local M = {}

function M.split_string(str, separator)
    separator = separator or "%s"
    local t = {}
    for s in string.gmatch(str, "([^" .. separator .. "]+)") do
        table.insert(t, s)
    end
    return t
end

return M
