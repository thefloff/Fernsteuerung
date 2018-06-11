-- bound to keys
function fs.primaryAction()
	fs.printDebug("fs.primaryAction");
    if fs.playerControlled == "None" then fs.playerControlled = playerControlled; end
    if fs.playerControlled == nil then fs.printError("ERROR: No Character set to support!"); end
    fs[fs.characterClass].primaryAction()
end
function fs.secondaryAction()
    if fs.playerControlled == "None" then fs.playerControlled = playerControlled; end
    if fs.playerControlled == nil then fs.printError("ERROR: No Character set to support!"); end
    fs.printDebug("fs.secondaryAction");
    fs[fs.characterClass].secondaryAction();
end
function fs.tertiaryAction()
    if fs.playerControlled == "None" then fs.playerControlled = playerControlled; end
    if fs.playerControlled == nil then fs.printError("ERROR: No Character set to support!"); end
    fs.printDebug("fs.tertiaryAction");
    fs[fs.characterClass].tertiaryAction();
end
function fs.showMenu()
    fs.printDebug("fs.showMenu");
    if FSOptions then
        fs.printDebug("FSOptions exists");
        FSOptions:Show();
    end
end

-- register combat log parser
function fs.registerCombatLogParser() 
	local parser = ParserLib:GetInstance("1.1");
	for _, event in pairs(fs.damageEventList) do
		parser:RegisterEvent(
			"Fernsteuerung",
			event,
			fs.damageEvent
		);
	end
end

function fs.damageEvent(event, info)
	local amount = info.amount;
	if info.type == "hit" then
		if info.victim == ParserLib_SELF then
			--fs.printDebug(event..":self:"..amount);
			SendAddonMessage( "Fernsteuerung", "DMG:"..UnitName('player')..":"..amount, "RAID");
		elseif info.victim == UnitName('pet') then
			--fs.printDebug(event..":pet:"..amount);
			SendAddonMessage( "Fernsteuerung", "DMG:"..UnitName('pet')..":"..amount, "RAID");
		end
	elseif info.type == "drain" and info.attribute == "Health" then
		if info.victim == ParserLib_SELF then
			--fs.printDebug(event..":self:"..amount);
			SendAddonMessage( "Fernsteuerung", "DMG:"..UnitName('player')..":"..amount, "RAID");
		elseif info.victim == UnitName('pet') then
			--fs.printDebug(event..":pet:"..amount);
			SendAddonMessage( "Fernsteuerung", "DMG:"..UnitName('pet')..":"..amount, "RAID");
		end
	end
end

-- called on load
function fs.load()
	getglobal("ChatFrame1"):AddMessage("Loading Fernsteuerung");
	fs.registerCombatLogParser();
	this:RegisterEvent("CHAT_MSG_ADDON");
    fs.characterClass = fs.getNormalizedClassName(UnitClass("player"));
    getglobal("ChatFrame1"):AddMessage(" -- Character Class: "..fs.characterClass);
end

function fs.chatMessageEvent() 
	if(event == "CHAT_MSG_ADDON" and arg1 == "Fernsteuerung") then
		local message = arg2;
		fs.printDebug("AddonChannelMessage="..message);
		local splitMessage = fs.split(message, ':');
		local messageType = splitMessage[1];
		if messageType == "DMG" then 
			local victim = splitMessage[2];
			local amount = splitMessage[3];
			local victimDamageTable = fs.playerDmg[victim];
			if victimDamageTable == nil then 
				fs.playerDmg[victim] = {};
				victimDamageTable = fs.playerDmg[victim];
			end
			victimDamageTable[GetTime()] = {amount=amount};
		elseif messageType == "COMMAND" then
			--todo
		elseif messageType == "HEAL" then
			--todo
		end
	end
end











































