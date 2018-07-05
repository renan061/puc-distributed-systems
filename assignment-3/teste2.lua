local tossam = require("tossam") 

local exit = false
while not(exit) do
    local mote = tossam.connect {
      protocol = "sf",
      host     = "localhost",
      port     = 9002,
      nodeid   = 1
    }
    
	if not(mote) then
	    print("Connection error!");
	    return(1);
    end

	mote:register [[ 
	  nx_struct msg_serial [145] { 
		nx_uint16_t type;
		nx_uint16_t source;
		nx_uint16_t target;
		nx_uint16_t v1;
		nx_uint16_t v2;
		nx_uint16_t v3;
	  }; 
	]]

	while (mote) do

		local stat, msg, emsg = pcall(function() return mote:receive() end) 
		--print(stat, msg, emsg)
		if stat then
			-- if msg and msg.type == 1280 then
			if msg then
				print("------------------------------") 
				print("msgID: "..msg.type, "Source: ".. msg.source, "Target: ".. msg.target) 
				print("v1:", msg.v1)
				print("v2:", msg.v2)
				print("v2:", msg.v3)
			else
				if emsg == "closed" then
					print("\nConnection closed!")
					exit = true
					break 
				end
			end
		else
			print("\nreceive() got an error:"..msg)
			exit = true
			break
		end
	end

	print("Done...")
	mote:unregister()
	mote:close() 

end

