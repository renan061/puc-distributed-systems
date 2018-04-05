local Interface = {}
Interface.__index = Interface

-- parses an interface file to a lua object
function parse(file)
    local interface_object
    function interface(i) interface_object = i end
    dofile(file)
    return assert(interface_object)
end

-- validates an interface type
local function validatetype(t, canvoid)
    if t == "void" then assert(canvoid, "invalid type void for parameter")
    else assert(t == "double" or t == "string", "invalid type " .. t) end
end

-----------------------------------------------------
--
--  .new
--
-----------------------------------------------------

function Interface.new(file)
    local t = {}

    local interface_object = parse(file)
    -- ASK: does nothing with the interface name?
    local methods = assert(interface_object.methods)

    for name, method in pairs(methods) do
        -- return types
        validatetype(method.resulttype, true)
        local return_types = {}
        if method.resulttype ~= "void" then
            table.insert(return_types, method.resulttype)
        end

        -- parameter types
        local parameter_types = {}
        for _, parameter in pairs(assert(method.args)) do
            local direction = assert(parameter.direction)
            validatetype(assert(parameter.type), false)

            if direction == "in" then
                table.insert(parameter_types, parameter.type)
            elseif direction == "out" then
                table.insert(return_types, parameter.type)
            elseif direction == "inout" then
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

    setmetatable(t, Interface)
    return t
end

-----------------------------------------------------
--
--  :string
--
-----------------------------------------------------

function Interface:string()
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

return Interface
