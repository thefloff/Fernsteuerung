-- change player to support
function fs.setPlayerName(name)
    fs.printDebug("setPlayerName("..name..")");
	fs.playerControlled = name;
	playerControlled = name;
end

-- use item in bag
function fs.useItem(name)
	local nrItems = {};
	nrItems[0] = GetContainerNumSlots(0);
	nrItems[1] = GetContainerNumSlots(1);
	nrItems[2] = GetContainerNumSlots(2);
	nrItems[3] = GetContainerNumSlots(3);
	nrItems[4] = GetContainerNumSlots(4);
	for bag = 0,4
	do
		for slot = 1,nrItems[bag]
		do
			if GetContainerItemInfo(bag, slot) == name then
				UseContainerItem(bag, slot);
				return;
			end
		end
	end
end

-- check if item in bag
function fs.findItem(name)
	local nrItems = {};
	nrItems[0] = GetContainerNumSlots(0);
	nrItems[1] = GetContainerNumSlots(1);
	nrItems[2] = GetContainerNumSlots(2);
	nrItems[3] = GetContainerNumSlots(3);
	nrItems[4] = GetContainerNumSlots(4);
	for bag = 0,4
	do
		for slot = 1,nrItems[bag]
		do
			if GetContainerItemInfo(bag, slot) == name then
				return 1;
			end
		end
	end
	return 0;
end

-- count items in bag
function fs.countItems(name)
	local nrItems = {};
	nrItems[0] = GetContainerNumSlots(0);
	nrItems[1] = GetContainerNumSlots(1);
	nrItems[2] = GetContainerNumSlots(2);
	nrItems[3] = GetContainerNumSlots(3);
	nrItems[4] = GetContainerNumSlots(4);
	local counter = 0;
	for bag = 0,4
	do
		for slot = 1,nrItems[bag]
		do
			local texture, itemCount = GetContainerItemInfo(bag, slot);
			if texture == name then
				if not (itemCount == nil) then
					counter = counter + itemCount;
				end
			end
		end
	end
	return counter;
end

-- for finding icon names ingame
function fs.getItemNames()
	local nrItems = {};
	nrItems[0] = GetContainerNumSlots(0);
	nrItems[1] = GetContainerNumSlots(1);
	nrItems[2] = GetContainerNumSlots(2);
	nrItems[3] = GetContainerNumSlots(3);
	nrItems[4] = GetContainerNumSlots(4);
	for bag = 0,4
	do
		getglobal("ChatFrame1"):AddMessage("Bag "..bag);
		for slot = 1,nrItems[bag]
		do
			if GetContainerItemInfo(bag, slot) ~= nil then
				getglobal("ChatFrame1"):AddMessage(GetContainerItemInfo(bag, slot));
			end
		end
	end
end

-- return true if at least on of party/raid is in combat
function fs.groupInCombat()
	if(UnitAffectingCombat("player") ~= nil) then
		return true;
	end
	for i=1,4 do
		if(UnitAffectingCombat("party"..i) ~= nil) then
			return true;
		end
	end
	for i=1,40 do
		if(UnitAffectingCombat("raid"..i) ~= nil) then
			return true;
		end
	end
	return false;
end

function fs.playerHasBuff(buffname)
	for i=1,40 do
		local name = UnitBuff("player", i);
		if(name == buffname) then
			return true;
		end
	end
	return false;
end

function fs.targetHasDebuff(debuffname)
	for i=1,40 do
		local name = UnitDebuff("target", i);
		if(name == debuffname) then
			return true;
		end
	end
	return false;
end

function fs.unitHasBuff(buffname, unit)
	for i=1,40 do
		local name = UnitBuff(unit, i);
		if(name == buffname) then
			return true;
		end
	end
	return false;
end

function fs.unitHasDebuff(debuffname, unit)
	for i=1,40 do
		local name = UnitDebuff(unit, i);
		fs.printDebug(name);
		if(name == debuffname) then
			return true;
		end
	end
	return false;
end

-- usefull for finding debuff names for decurse list
function fs.printTargetDebuffs()
	for i=1,40 do
		local name = UnitDebuff("target", i);
		getglobal("ChatFrame1"):AddMessage(name);
	end
end

-- search for a target without any buff in the array
function fs.selectNextTargetWithout(forbiddenBuffs, forbiddenMarks)
	local found = 0;
	local counter = 1;
    local tookToLong = false;
	while found == 0 do
		if counter > 20 then
            fs.printDebug(" -- no target found, clearing target");
            ClearTarget();
			return true;
		end
		RunBinding(GetBindingAction("tab"));
		if UnitCanAttack("player", "target") and
				UnitAffectingCombat("target") then

			found = 1;

			if counter < 15 then
				if not (forbiddenBuffs == nil) then
					for i,v in ipairs(forbiddenBuffs) do
                        fs.printDebug(" -- checking forbidden debuff: " .. v);
						if fs.targetHasDebuff(v) then
                            fs.printDebug(" -- debuff is present");
							found = 0;
						end
					end
				end
            else
                tookToLong = true;
			end

			local mark = GetRaidTargetIndex("target");
			if not (forbiddenMarks == nil) and mark then
				for i,v in ipairs(forbiddenBuffs) do
					fs.printDebug(" -- checking forbidden mark: " .. v);
					if mark == v then
						fs.printDebug(" -- mark is present");
						found = 0;
					end
				end
			end

		end
		counter = counter+1;
	end

    if not tookToLong then
        fs.printDebug(" -- primary target found");
        return true;
    else
        fs.printDebug(" -- secundary target found");
        return false;
    end
end

-- print message to chat if fs.debug is set to true
function fs.printDebug(msg)
    fs.debug = debug;
	if fs.debug then
        getglobal("ChatFrame1"):AddMessage(msg);
	end
end

-- print error message to chat
function fs.printError(msg)
	getglobal("ChatFrame1"):AddMessage("\124cffFF0000"..msg);
end

function fs.split(str, delim, maxNb)
   -- Eliminate bad cases...
   if string.find(str, delim) == nil then
      return { str }
   end
   if maxNb == nil or maxNb < 1 then
      maxNb = 0    -- No limit
   end
   local result = {}
   local pat = "(.-)" .. delim .. "()"
   local nb = 0
   local lastPos
   for part, pos in string.gfind(str, pat) do
      nb = nb + 1
      result[nb] = part
      lastPos = pos
      if nb == maxNb then
         break
      end
   end
   -- Handle the last field
   if nb ~= maxNb then
      result[nb + 1] = string.sub(str, lastPos)
   end
   return result
end

function fs.getTableSize(t)
	if t == nil then return 0; end;
	return table.getn(t);
end

function fs.getNormalizedClassName(className) 
	if(className == "Hexenmeister" or className == "Warlock") then
		return "warlock";
	elseif(className == "Priester" or className == "Priest") then
		return "priest";
	elseif(className == "Jäger" or className == "Hunter") then
		return "hunter";
	elseif(className == "Paladin") then
		return "paladin";
	elseif(className == "Druide" or className == "Druid") then
		return "druid";
	elseif(className == "Schurke" or className == "Rogue") then
		return "rogue";		
	elseif(className == "Krieger" or className == "Warrior") then
		return "warrior";	
	elseif(className == "Schamane" or className == "Shaman") then
		return "shaman";			
	elseif(className == "Magier" or className == "Mage") then
		return "mage";
	end
end

function fs.boolToString(bool) 
	if bool then
		return "true";
	else 
		return "false";
	end
end	

function fs.containsValue(tab, val)
	if val == nil then
		return false
	end
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

function fs.getRemainingSpellCooldown(spellId)
	local start, duration = GetSpellCooldown(spellId, BOOKTYPE_SPELL);
	if (start > 0 and duration > 0) then
		return start + duration - GetTime();
	else
		return 0;
	end
end

function fs.getSpellManaCosts(spell)
	if spell.manacosts ~= nil then
		return spell.manacosts;
	else 
		return TheoryCraft_GetSpellDataByName(spell.name, spell.rank).basemanacost;
	end
end

-- collects some data of all spells
function fs.getSpellList(list)
	fs.printDebug("fs.getSpellList()");
	for i=1,300 do
		local name, rank = GetSpellName(i, BOOKTYPE_SPELL);
		if name == nil then break end;

		if string.find(rank, "Rang") or string.find(rank, "Rank") then
			rank = string.sub(rank, -1);
		else
			rank = "0";
		end

		local data = TheoryCraft_GetSpellDataByName(name, rank);

		local spell = {};

		if data then
			spell.manaCost = data.basemanacost;
		end

		spell.id = i;
		spell.name = name;
		spell.rank = rank;

		if not list[name] then
			list[name] = {};
			list[name].maxRank = 0;
		end
		list[name][rank] = spell;
		if tonumber(rank) > tonumber(list[name].maxRank) then
			list[name].maxRank = rank;
		end
	end
end












