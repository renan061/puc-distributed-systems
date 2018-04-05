local protocol = {}

protocol.ERROR = "___ERRORPC: "

-- "value1\nvalue2\nvalue3\n...\nvalueN\n"
function protocol.marshall(values)
    local string = ""
    for _, value in ipairs(values) do
        string = string .. tostring(value) .. "\n"
    end
    return string
end

function protocol.unmarshall(string)
    local values = {}
    for value in string:gmatch("[^\n]+") do
        table.insert(values, value)
    end
    return values
end

return protocol
