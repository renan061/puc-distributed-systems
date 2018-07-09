function serialize(t)
    local s = {"m = {"}

    for i, v in pairs(t) do
        s[#s + 1] = tostring(i)
        s[#s + 1] = '='
        if type(v) == 'string' then
            s[#s + 1] = '"' .. v .. '"'
        else
            s[#s + 1] = tostring(v)
        end
        s[#s + 1] = ','
    end

    s[#s] = "}"
    s = table.concat(s)
    return s
end
