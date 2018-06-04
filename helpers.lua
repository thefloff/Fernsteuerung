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

function fs.groupInCombat()
	if(UnitAffectingCombat("player") ~= nil) then
		return true;
	end
	for i=1,4 do
		if(UnitAffectingCombat("party"..i) ~= nil) then
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

function fs.setAllowed()
	local mark = GetRaidTargetIndex("target");
	if mark then
		fs.isAllowed[mark] = true;
		getglobal("ChatFrame1"):AddMessage("Mark '"..fs.markerNames[mark].."' is now allowed");
	end
end

function fs.setDisallowed()
	local mark = GetRaidTargetIndex("target");
	if mark then
		fs.isAllowed[mark] = false;
		getglobal("ChatFrame1"):AddMessage("Mark '"..fs.markerNames[mark].."' is now forbidden");
	end
end

function fs.selectNextTargetWithout(forbiddenBuffs)
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

			if fs.targetHasDebuff(fs.debuff_sheep) then
                fs.printDebug(" -- sheep present");
				found = 0;
			end

			local mark = GetRaidTargetIndex("target");
			if mark and not fs.isAllowed[mark] then
                fs.printDebug(" -- illegal mark present");
				found = 0;
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

function fs.printDebug(msg)
	if fs.debug then
		-- SendChatMessage(msg, "WHISPER", nil, fs.playerControlled);
        getglobal("ChatFrame1"):AddMessage(msg);
	end
end
