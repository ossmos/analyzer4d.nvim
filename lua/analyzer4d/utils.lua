local M = {}

function M.remove_json_prefix(str)
    local i = string.find(str, "{", 1, true)
    if i == nil then
        return str
    end
    return string.sub(str, i)
end


function M.split_string(str, separator)
    separator = separator or "%s"
    local t = {}
    for s in string.gmatch(str, "([^" .. separator .. "]+)") do
        table.insert(t, s)
    end
    return t
end

return M
