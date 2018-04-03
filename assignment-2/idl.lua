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

-- converts an idl lua object to a stub
function idl.convert(interface_object, remote_call)
    local stub = {}

    -- fills the stub with methods
    for method_name, method_data in pairs(assert(interface_object.methods)) do
        -- returns
        validatetype(method_data.resulttype, true)
        local returns = {} -- stores all return values' types
        if method_data.resulttype ~= "void" then
            table.insert(returns, method_data.resulttype)
        end

        -- parameters
        local parameters = {} -- stores all parameters' types
        for _, param in pairs(assert(method_data.args)) do
            local direction = assert(param.direction)
            validatetype(assert(param.type), false)

            if direction == "in" then
                table.insert(parameters, param.type)
            elseif direction == "out" then
                table.insert(returns, param.type)
            elseif direction == "inout" then
                table.insert(parameters, param.type)
                table.insert(returns, param.type)
            else
                assert(nil, "invalid parameter type - " .. param.type)
            end
        end
        
        -- defines the method in the stub
        stub[method_name] = function(...)
            local arguments = {}
            for _, argument in ipairs{...} do
                table.insert(arguments, argument)
            end

            assert(#parameters >= #arguments, "too many arguments") -- ASK

            -- ASK: convert "2" to 2.0?
            -- checks the provided arguments
            for i = 1, #arguments do
                local p, a = parameters[i], type(arguments[i])
                if a == "number" and p ~= "double" or
                   a == "string" and p ~= "string" then
                    assert(nil, "got '" .. a .. "', expected '" .. p .. "'")
                end
            end

            -- gives zero values based on types for missing arguments
            for i = #arguments + 1, #parameters do
                local p = parameters[i]
                if p == "double" then
                    table.insert(arguments, 0.0)
                elseif p == "string" then
                    table.insert(arguments, "")
                else
                    assert(nil, "unreachable")
                end
            end

            return remote_call(method_name, arguments, returns)
        end
    end

    return stub
end

return idl