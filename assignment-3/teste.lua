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
		nx_uint16_t ushort_01;
		nx_uint16_t ushort_02;
		nx_uint16_t ushort_03;
	  }; 
	]]

	while (mote) do

		local stat, msg, emsg = pcall(function() return mote:receive() end) 
		--print(stat, msg, emsg)
		if stat then
			if msg and msg.type == 1280 then
				print("------------------------------") 
				print("msgID: "..msg.type, "Source: ".. msg.source, "Target: ".. msg.target) 
				print("n:", msg.ushort_01)
				print("t:", msg.ushort_02)
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

	mote:unregister()
	mote:close() 

end

