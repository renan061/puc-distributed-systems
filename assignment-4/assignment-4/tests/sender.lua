local mqtt = require("mqtt_library")

local author = "sender-" .. arg[3]

function callback(topic, message)
    if topic == "topic/2" then
        -- print(message)
        ;
    end
end

mqtt_client = mqtt.client.create(arg[1], arg[2], callback)
mqtt_client:connect(author)
mqtt_client:subscribe({
    "topic/1",
    "topic/2"
})

for i = 1, 100 do
    local message = "message-" .. i .. "-" .. author
    mqtt_client:publish("topic/1", message)
    print(author .. " done")
end

repeat 
    local err = mqtt_client:handler()
until err ~= nil
