-- V1.0 Initial version

-- Initialization --
function onInit()
	if User.isHost() then
		Comm.registerSlashHandler("characterwealth", processCharacterWealth);
	end
	
	local msg = {sender = "", font = "emotefont"};
	msg.text = "CharacterWealth v1.0 Extension for FG 3.1+ rulesets: PFRPG, by Wattabout2ndBrkfst";
	ChatManager.registerLaunchMessage(msg);
end

function processCharacterWealth()
	local msg = {};
	msg.font = "systemfont";
	msg.text = "This works!";
	Comm.addChatMessage(msg)
end