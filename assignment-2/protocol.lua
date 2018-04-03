local protocol = {}

protocol.ERROR = "___ERRORPC: "

-- "function_name\n[{argument\n}]"
function protocol.parse(function_name, arguments)
    local str = function_name .. "\n"
    for _, arg in ipairs(arguments) do str = str .. tostring(arg) .. "\n" end
    return str
end

-- interface { name = "someinterface",
--     methods = {
--         foo = {
--             resulttype = "string",
--             args = {{
--                 direction = "inout",
--                 type = "double"
--             }, {
--                 direction = "in",
--                 type = "string"
--             }}
--         }
--     }
-- }

-- exemplo de chamada:
-- "foo\n24.5\nsomestring\n"

-- exemplo de resposta (sem erro):
-- "anotherstring\n0.87\n"

-- exemplo de resposta (com erro):
-- "___ERRORPC: \nfunção inexistente\n"

return protocol
