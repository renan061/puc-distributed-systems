local idl = {}

-----------------------------------------------------
--
--  Auxiliary
--
-----------------------------------------------------

-- validates a interface type
local function validatetype(t, canvoid)
    if t == "void" then assert(canvoid, "invalid type void for parameter")
    else assert(t == "double" or t == "string", "invalid type " .. t) end
end

-----------------------------------------------------
--
--  new TODO
--
-----------------------------------------------------

function idl.compatible_type(value, interface_type)
    local value_type = type(value)
    if interface_type == "double" then
        if value_type == "number" then
            return nil
        elseif tonumber(value) ~= nil then
            return nil
        end
    elseif interface_type == "string" then
        if value_type == "string" then
            return nil
        elseif tostring(value) ~= nil then
            return nil
        end
    else
        error("invalid interface type - " .. interface_type)
    end
    
    return string.format("value '%s' must have type %s", value, interface_type)
end

-----------------------------------------------------
--
--  IDL
--
-----------------------------------------------------

-- parses an idl file to a lua object
function idl.parse(file)
    local interface_object
    function interface(i) interface_object = i end
    dofile(file)
    return assert(interface_object)
end

function idl.convertvalue(value, interface_type) -- returns value, error
    local convert
    if interface_type == "double" then convert = tonumber
    elseif interface_type == "string" then convert = tostring
    else error("invalid interface type - " .. interface_type) end

    local converted = convert(value)
    if not converted then
        return nil, "error: can't convert " .. value .. " to " .. interface_type
    end
    return converted    
end

return idl
