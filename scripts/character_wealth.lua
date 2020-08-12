-- V1.0.0 Initial version
-- V1.1.0 Added -all and -party support - 8/12/2020

-- Initialization --
function onInit()
	if User.isHost() then
		Comm.registerSlashHandler("charwealth", processCharacterWealth);
	end
	
	local msg = {sender = "", font = "emotefont"};
	msg.text = "CharacterWealth v1.1.0 Extension for FG 3.3+ rulesets: PFRPG and 3.5e, by Wattabout2ndBrkfst";
	ChatManager.registerLaunchMessage(msg);
end

function processCharacterWealth(sCommand, sParams)
	local nodeChar = nil;
	local sChar = nil;
	local nRunningAllCharacterTotal = 0;
	local nRunningPartyTotal = 0;
	local boolAllWealth = false;
	local boolPartyWealth = false;
	local sChatMessage = nil;
	
	--Debug.console("Parameters = " .. sParams);
	
	local sFind = StringManager.trim(sParams);

	printDashedLine();
	
	-- Check if string is not empty --
	if string.len(sFind) > 0 then

		-- check if we want to calculate every character's wealth --
		-- and total party wealth --
		if sFind == "-all" then
			boolAllWealth = true;
		elseif sFind == "-party" then
			boolPartyWealth = true;
		end

		for _, vChar in pairs(DB.getChildren("charsheet")) do	-- For each character --
			sChar = DB.getValue(vChar, "name", "");	-- Get the name of the character --
			if string.len(sChar) > 0 then	-- If the name is not empty --
				if boolAllWealth then	-- If we want every character's wealth --
					-- Add character wealth to running party total and print character wealth if wealth is greater than 0 --
					nRunningAllCharacterTotal = nRunningAllCharacterTotal + calculateCharacterWealth(vChar);
				elseif boolPartyWealth then
					-- Check if character is in party --
					if isCharacterPartyMember(sChar) then
						nRunningPartyTotal = nRunningPartyTotal + calculateCharacterWealth(vChar);
					else
						-- Do nothing --
					end
				elseif string.lower(sFind) == string.lower(sChar) then	-- If the names match and we are not doing every character --
					nodeChar = vChar;	-- Save the node --
					calculateCharacterWealth(nodeChar);	-- print character wealth if wealth is greater than 0 --
					break;	-- Stop searching if we found a match --
				end
			end
		end
		
		if not nodeChar and not boolAllWealth and not boolPartyWealth then	-- If we did not find a matching character while getting a single character's wealth --
			sChatMessage = "Unable to find character for calculating character wealth" .. " (" .. sParams .. ")";
			printSystemMessage(sChatMessage);
			printUsageMessage();
			printDashedLine();
			return;
		else	-- We found a matching character OR we are retrieving all characters' wealth--
			--Debug.console("Found character: " .. sChar);
		end

		-- If we are outputting all characters' wealth and party wealth --
		if boolAllWealth then
			sChatMessage = "Total Wealth of All Characters is: " .. nRunningAllCharacterTotal .. " gp";
			printChatMessage(sChatMessage);
		elseif boolPartyWealth then
			sChatMessage = "Total Wealth of the Party is: " .. nRunningPartyTotal .. " gp";
			printChatMessage(sChatMessage);
		end
	else	-- No character name given --
		sChatMessage = "Error: No character name, -all, or -party given";
		printSystemMessage(sChatMessage);
		printUsageMessage();
		printDashedLine();
		return;
	end

	printDashedLine();
	
	return;
end

function calculateCharacterWealth(nodeChar)
	local sCharName = DB.getValue(nodeChar, "name", "");	-- Get character name --
	local nodeInventoryItems = DB.getChildren(nodeChar, "inventorylist");	-- Get inventory list --
	local sChatMessage = nil;
	local nRunningTotal = 0;
	
	if nodeInventoryItems then	-- If the inventory list is not nil --		
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
								sChatMessage = "" .. sItemName .. ": Excluded. Non-standard currency used";
								printChatMessage(sChatMessage);
								break;
							end
						-- We've reached the end and haven't found a currency match --
						elseif k == #aCurrencies then
							sChatMessage = "" .. sItemName .. ": Excluded. Unknown currency used";
							printChatMessage(sChatMessage);
						end
					end
				else	-- String is not a number or are units are nil --
					sChatMessage = "" .. sItemName .. " was not added to character running total";
					printChatMessage(sChatMessage);
				end
			end
		end

		-- Only print out total wealth of character if it is greater than 0 --
		if( nRunningTotal > 0 ) then
			sChatMessage = "Total Wealth of " .. sCharName .. " is: " .. nRunningTotal .. " gp";
			printChatMessage(sChatMessage);
		end
	end

	return nRunningTotal;
end

function printDashedLine()
	local msg = {};

	msg.font = "systemfont";
	msg.text = "--------------------------------";
	Comm.addChatMessage(msg);

	return;
end

function printChatMessage(sMessage)
	local msg = {};

	msg.font = "systemfont";
	msg.text = sMessage;
	Comm.addChatMessage(msg);	-- Print message to chat --

	return;
end

function printSystemMessage(sMessage)
	ChatManager.SystemMessage(sMessage);

	return;
end

function printUsageMessage()
	local sUsageMessage = "Usage: charwealth [character name]\nUsage: charwealth -all\nUsage: charwealth -party"

end

-- Check if given string is the name of a character in the party sheet --
function isCharacterPartyMember(sCharacterName)
	-- For each node of the party sheet --
	for _,v in pairs(DB.getChildren("partysheet.partyinformation")) do
		local sClass, sRecord = DB.getValue(v, "link");
		-- If it is a charsheet class --
		if sClass == "charsheet" and sRecord then
			--Debug.console("Class is charsheet and record");
			local nodePC = DB.findNode(sRecord);
			--Debug.console("nodePC node found");
			if nodePC then
				local sName = DB.getValue(v, "name", "");
				--Debug.console("Name is " .. sName);
				-- Are the names equal? --
				if sCharacterName == sName then
					return true;
				end
			end
		end
	end

	-- Could not find name among party sheet --
	return false;
end