spawn(
	function()
		while true do
			local i = rconsoleinput()
			if i == 'q' then break end
			spawn(function() loadstring(i)() end)
		end
	end)
