local mqtt = require("mqtt_library")
local i = 0

local start = os.time()

function callback(topic, message)
    -- print(message)
    if topic == "topic/1" then
        mqtt_client:publish("topic/2", message)
        i = i + 1
    end
end

mqtt_client = mqtt.client.create(arg[1], arg[2], callback)
mqtt_client:connect("receiver")
mqtt_client:subscribe({
    "topic/1",
    "topic/2"
})

repeat 
    local err = mqtt_client:handler()
until err ~= nil or i == 10000

local finish = os.time()

print("Receiver is done... (" .. finish-start .. "s)")


