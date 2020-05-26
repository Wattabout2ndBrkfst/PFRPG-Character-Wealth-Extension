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
	
	--Debug.console("Parameters = " .. sParams);
	
	local sFind = StringManager.trim(sParams);
	
	-- Check if string is not empty --
	if string.len(sFind) > 0 then
		for _, vChar in pairs(DB.getChildren("charsheet")) do	-- For each character --
			sChar = DB.getValue(vChar, "name", "");	-- Get the name of the character --
			if string.len(sChar) > 0 then	-- If the name is not empty --
				if string.lower(sFind) == string.lower(sChar) then	-- If the names match --
					nodeChar = vChar;	-- Save the node --
				end
			end
		end
		
		if not nodeChar then	-- If we did not find a matching character --
			ChatManager.SystemMessage("Unable to find character for calculating character wealth" .. " (" .. sParams .. ")");
			return;
		else	-- We found a matching character --
			--Debug.console("Found character: " .. sChar);
		end
	else	-- No character name given --
		ChatManager.SystemMessage("Error: No character name given\nUsage: charwealth [character name]");
		return;
	end
	
	calculateCharacterWealth(nodeChar);
	
	return;
end

function calculateCharacterWealth(nodeChar)
	local sCharName = DB.getValue(nodeChar, "name", "");	-- Get character name --
	local nodeInventoryItems = DB.getChildren(nodeChar, "inventorylist");	-- Get inventory list --
	local msg = {};
	msg.font = "systemfont";
	msg.text = "--------------------------------";
	Comm.addChatMessage(msg);	-- Print line to start --
	
	if nodeInventoryItems then	-- If the inventory list is not nil --
		local nRunningTotal = 0;
		
		for k, nodeItem in pairs(nodeInventoryItems) do	-- For every item in the inventory list --
			local sItemName = DB.getValue(nodeItem, "name", "");	-- Get name of item --
			local sItemCost = DB.getValue(nodeItem, "cost", "");	-- Get cost of item --
			if sItemCost ~= "" then
				local aCostData = StringManager.split(sItemCost, " ", true);
				local sFormattedItemCost = "";
				
				-- Check if string has a comma --
				if string.match(aCostData[1], ",") then
					--Debug.console("Cost has a comma");
					local aCommaCost = StringManager.split(aCostData[1], ",", true);
					
					-- Concatenate the tokens together to build new string without commas --
					for j, sToken in pairs(aCommaCost) do
						sFormattedItemCost = sFormattedItemCost .. sToken; 
					end
				else	-- String does not have a comma --
					sFormattedItemCost = aCostData[1];
				end
				
				local sCostUnits = aCostData[2];	-- Units of the cost --
				
				--Debug.console(sFormattedItemCost);
				--Debug.console(sCostUnits);
				local aCurrencies = CurrencyManager.getCurrencies();	-- Get list of currencies --
				
				-- If the string is a number and our units are not nil --
				if StringManager.isNumberString(sFormattedItemCost) and sCostUnits then
					for k, sCurrency in pairs(aCurrencies) do	-- For each currency --
						--Debug.console(k);
						--Debug.console(#aCurrencies);
						if sCostUnits:lower() == sCurrency:lower() then		-- Check if we have a currency match --
							local nItemQuantity = DB.getValue(nodeItem, "count", 0);	-- Get number of items --
							if sCostUnits:lower() == "pp" then	-- platinum = 10 gold --
								nRunningTotal = nRunningTotal + (tonumber(sFormattedItemCost) * 10 * nItemQuantity);
								break;
							elseif sCostUnits:lower() == "gp" then
								nRunningTotal = nRunningTotal + (tonumber(sFormattedItemCost) * 1 * nItemQuantity);
								break;
							elseif sCostUnits:lower() == "sp" then	-- silver = 0.1 gold --
								nRunningTotal = nRunningTotal + (tonumber(sFormattedItemCost) * 0.1 * nItemQuantity);
								break;
							elseif sCostUnits:lower() == "cp" then	-- copper = 0.01 gold --
								nRunningTotal = nRunningTotal + (tonumber(sFormattedItemCost) * 0.01 * nItemQuantity);
								break;
							else
								-- Currency is defined, but is not a standard currency --
								msg.text = "" .. sItemName .. ": Excluded. Non-standard currency used";
								Comm.addChatMessage(msg);
								break;
							end
						-- We've reached the end and haven't found a currency match --
						elseif k == #aCurrencies then
							msg.text = "" .. sItemName .. ": Excluded. Unknown currency used";
							Comm.addChatMessage(msg);
						end
					end
				else	-- String is not a number or are units are nil --
					msg.font = "systemfont";
					msg.text = "" .. sItemName .. " was not added to running total";
					Comm.addChatMessage(msg);
				end
			end
		end
		msg.text = "Total Wealth of " .. sCharName .. " is: " .. nRunningTotal .. " gp\n--------------------------------";
		Comm.addChatMessage(msg);
	end

	return;
end