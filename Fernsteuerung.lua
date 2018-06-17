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
	this:RegisterEvent("PLAYER_TARGET_CHANGED");
    fs.characterClass = fs.getNormalizedClassName(UnitClass("player"));
    getglobal("ChatFrame1"):AddMessage(" -- Character Class: "..fs.characterClass);
end

function fs.onEvent() 
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
			local player = splitMessage[2];
			local amount = splitMessage[3];
			local t = splitMessage[4];
			local playerHealTable = fs.playerIncomingHeal[player];
			if playerHealTable == nil then 
				fs.playerIncomingHeal[player] = {};
				playerHealTable = fs.playerIncomingHeal[player];
			end
			playerHealTable[t] = {amount=amount};
			--fs.printDebug("playerHealTable["..t.."]="..amount);
		end
	elseif event == "PLAYER_TARGET_CHANGED" then  -- use the first target change for initializing the heal lists. It cant be done on load, cause the TheoryCraft addon is not yet ready at this point.
		if(fs[fs.characterClass] ~= nil and not fs.isHealListInit) then
			fs.printDebug("fs: fillSpellListAttributes");
			fs.fillSpellListAttributes(fs[fs.characterClass].healSpells);
			fs.isHealListInit = true;
		end		
	end
end

function fs.fillSpellListAttributes(spellList) 
	if(spellList == nil) then
		return;
	end
	-- fill spellID, expectedHeal and healPerMana
	for i=1,300 do
		local name, rank = GetSpellName(i, BOOKTYPE_SPELL);
		if name == nil then break end;
		for key, spell in pairs(spellList) do
			if name == spell.name and rank == "Rang "..spell.rank then
				if spell.spellID == nil then
					spell.spellID = i;
				end
				if spell.expectedHeal == nil then
					spell.expectedHeal = TheoryCraft_GetSpellDataByName(spell.name, spell.rank).averagehealnocrit;
				end
				if spell.expectedHotHeal == nil then
					spell.expectedHotHeal = TheoryCraft_GetSpellDataByName(spell.name, spell.rank).hotheal;
				end
				if spell.healPerMana == nil then
					if TheoryCraft_GetSpellDataByName(spell.name, spell.rank).withhothpm then
						spell.healPerMana = TheoryCraft_GetSpellDataByName(spell.name, spell.rank).withhothpm;
					elseif TheoryCraft_GetSpellDataByName(spell.name, spell.rank).hpm then
						spell.healPerMana = TheoryCraft_GetSpellDataByName(spell.name, spell.rank).hpm;
					else 
						spell.healPerMana = (spell.expectedHeal + spell.expectedHotHeal) / TheoryCraft_GetSpellDataByName(spell.name, spell.rank).manacost;
					end
				end
			end
		end
	end
	
	-- calc normalizedManaEfficency, normalizedCastTime
	local bestManaEfficency = 0;
	for key, spell in pairs(spellList) do
		spell.normalizedCastTime = 1 - min(spell.casttime / 3, 1);
		if spell.healPerMana > bestManaEfficency then
			bestManaEfficency = spell.healPerMana;
		end
	end
	for key, spell in pairs(spellList) do 
		spell.normalizedManaEfficency = max(((spell.healPerMana - bestManaEfficency * 1 / 3) / (bestManaEfficency * 2 / 3)), 0);
		fs.printDebug("Normalized <casttime> | <manaefficency>: "..key.." to "..spell.normalizedCastTime.." | "..spell.normalizedManaEfficency);
	end
end









































