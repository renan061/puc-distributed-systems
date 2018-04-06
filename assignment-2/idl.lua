local idl = {}
idl.__index = idl

-- types
idl.type = {
    double = "double",
    string = "string"
}

-- directions
idl.direction = {
    in_ = "in",
    out = "out",
    inout = "inout"
}

-- parses an idl file to a lua object
function parse(file)
    local interface_object
    function interface(i) interface_object = i end
    dofile(file)
    return assert(interface_object)
end

-- validates an idl type
local function validate_type(t, canvoid)
    if t == "void" then assert(canvoid, "invalid type void for parameter")
    else assert(t == "double" or t == "string", "invalid type " .. t) end
end

-----------------------------------------------------
--
--  .new
--
-----------------------------------------------------

function idl.new(file)
    local t = {}

    local interface_object = parse(file)
    t.name = interface_object.name -- ASK: does nothing with the interface name?
    local methods = assert(interface_object.methods)

    for name, method in pairs(methods) do
        -- return types
        validate_type(method.resulttype, true)
        local return_types = {}
        if method.resulttype ~= "void" then
            table.insert(return_types, method.resulttype)
        end

        -- parameter types
        local parameter_types = {}
        for _, parameter in pairs(assert(method.args)) do
            local direction = assert(parameter.direction)
            validate_type(assert(parameter.type), false)

            if direction == idl.direction.in_ then
                table.insert(parameter_types, parameter.type)
            elseif direction == idl.direction.out then
                table.insert(return_types, parameter.type)
            elseif direction == idl.direction.inout then
                table.insert(parameter_types, parameter.type)
                table.insert(return_types, parameter.type)
            else
                error("invalid interface parameter type - " .. parameter.type)
            end
        end

        t[name] = {
            parameter_types = parameter_types,
            return_types = return_types
        }
    end

    setmetatable(t, idl)
    return t
end

-----------------------------------------------------
--
--  .convert_value
--
-----------------------------------------------------

function idl.convert_value(value, idl_type) -- returns value, error
    local convert
    if idl_type == idl.type.double then
        convert = tonumber
    elseif idl_type == idl.type.string then
        convert = tostring
    else
        error("invalid interface type - " .. idl_type)
    end

    local converted = convert(value)
    if not converted then
        return nil, string.format("can't convert '%s' to %s", value, idl_type)
    end

    return converted    
end

-----------------------------------------------------
--
--  :string
--
-----------------------------------------------------

function idl:string()
    local string = "interface {\n"

    for name, method in pairs(self) do
        string = string .. "\t" .. name .. " {\n"

        string = string .. "\t\treturn_types = {"
        for _, return_type in ipairs(method.return_types) do
            string = string .. tostring(return_type) .. " "
        end
        string = string .. "}\n"

        string = string .. "\t\tparameter_types = {"
        for _, parameter_type in ipairs(method.parameter_types) do
            string = string .. tostring(parameter_type) .. " "
        end
        string = string .. "}\n"

        string = string .. "\t}\n"
    end

    string = string .. "}"

    return string
end

return idl
