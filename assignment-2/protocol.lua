local protocol = {}

-- :-)
local smile = "\\:-)\\"
local smile_pattern = "\\:%-%)\\"

protocol.error = "___ERRORPC: "

-- produces "value1\nvalue2\nvalue3\n...\nvalueN\n"
function protocol.marshall(values)
    if #values == 0 then return "\n" end
    
    local str = ""
    for _, value in ipairs(values) do
        if type(value) == "string" then
            value = string.gsub(value, "\n", smile)
        end
        str = str .. tostring(value) .. "\n"
    end
    return str
end

function protocol.marshall_error(message)
    return protocol.marshall({protocol.error, message})
end

function protocol.unmarshall(string)
    local values = {}
    for value in string:gmatch("[^\n]+") do
        value = string.gsub(value, smile_pattern, "\n")
        table.insert(values, value)
    end
    return values
end

return protocol
