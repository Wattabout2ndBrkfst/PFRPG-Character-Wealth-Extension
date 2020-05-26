-- V1.0 Initial version

-- Initialization --
function onInit()
	if User.isHost() then
		Comm.registerSlashHandler("charwealth", processCharacterWealth);
	end
	
	local msg = {sender = "", font = "emotefont"};
	msg.text = "CharacterWealth v1.0 Extension for FG 3.3+ rulesets: PFRPG, by Wattabout2ndBrkfst";
	ChatManager.registerLaunchMessage(msg);
end

function processCharacterWealth(sCommand, sParams)
	local nodeChar = nil;
	local sChar = nil;
	
	Debug.console("Parameters = " .. sParams);
	
	local sFind = StringManager.trim(sParams);
	if string.len(sFind) > 0 then
		for _, vChar in pairs(DB.getChildren("charsheet")) do
			sChar = DB.getValue(vChar, "name", "");
			if string.len(sChar) > 0 then
				if string.lower(sFind) == string.lower(string.sub(sChar, 1, string.len(sFind))) then
					nodeChar = vChar;
				end
			end
		end
		
		if not nodeChar then
			ChatManager.SystemMessage("Unable to find character for calculating character wealth" .. " (" .. sParams .. ")");
			return;
		else
			Debug.console("Found character: " .. sChar);
		end
	end
	
	calculateCharacterWealth(nodeChar);
end

function calculateCharacterWealth(nodeChar)
	local nodeInventoryItems = DB.getChildren(nodeChar, "inventorylist");
	local msg = {};
	msg.font = "systemfont";
	msg.text = "\n";
	Comm.addChatMessage(msg);	-- Print newline to start --
	
	if nodeInventoryItems then
		local nRunningTotal = 0;
		
		for k, nodeItem in pairs(nodeInventoryItems) do
			local sItemName = DB.getValue(nodeItem, "name", "");
			local sItemCost = DB.getValue(nodeItem, "cost", "");
			if sItemCost ~= "" then
				local aCostData = StringManager.split(sItemCost, " ", true);
				local sFormattedItemCost = "";
				
				-- Check if string has a comma --
				if string.match(aCostData[1], ",") then
					Debug.console("Cost has a comma");
					local aCommaCost = StringManager.split(aCostData[1], ",", true);
					
					for j, sToken in pairs(aCommaCost) do
						sFormattedItemCost = sFormattedItemCost .. sToken;
					end
				else
					sFormattedItemCost = aCostData[1];
				end
				
				local sCostUnits = aCostData[2];
				
				--Debug.console(sFormattedItemCost);
				--Debug.console(sCostUnits);
				
				if StringManager.isNumberString(sFormattedItemCost) and sCostUnits then
					for k, sCurrency in pairs(GameSystem.currencies) do
						--Debug.console(k);
						--Debug.console(#GameSystem.currencies);
						if sCostUnits:lower() == sCurrency:lower() then
							local nItemQuantity = DB.getValue(nodeItem, "count", 0);
							if sCostUnits:lower() == "pp" then
								nRunningTotal = nRunningTotal + (tonumber(sFormattedItemCost) * 10 * nItemQuantity);
								break;
							elseif sCostUnits:lower() == "gp" then
								nRunningTotal = nRunningTotal + (tonumber(sFormattedItemCost) * 1 * nItemQuantity);
								break;
							elseif sCostUnits:lower() == "sp" then
								nRunningTotal = nRunningTotal + (tonumber(sFormattedItemCost) * 0.1 * nItemQuantity);
								break;
							elseif sCostUnits:lower() == "cp" then
								nRunningTotal = nRunningTotal + (tonumber(sFormattedItemCost) * 0.01 * nItemQuantity);
								break;
							else
								-- Unknown currency type --
							end
						-- We've reached the end and haven't found a currency match --
						elseif k == #GameSystem.currencies then
							msg.text = "" .. sItemName .. ": Unknown currency used";
							Comm.addChatMessage(msg);
						end
						
					end
				else
					msg.font = "systemfont";
					msg.text = "" .. sItemName .. " was not added to running total";
					Comm.addChatMessage(msg);
				end
			end
		end
		msg.text = "--------------------------------\nTotal Wealth of Character is: " .. tonumber(nRunningTotal) .. " gp";
		Comm.addChatMessage(msg);
	end

end