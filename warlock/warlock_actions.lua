
function fs.warlock.checkHealthInCombat()
	local health = UnitHealth("player") / UnitHealthMax("player");
	local mana = UnitMana("player");
	if health < 0.3 then
		if fs.getRemainingSpellCooldown(fs.warlock.maxSpell(fs.warlock.todesmantel).id) == 0 and
			fs.getSpellManaCost(fs.warlock.maxSpell(fs.warlock.todesmantel)) <= mana then
			CastSpellByName(fs.warlock.todesmantel);
			return true;
		elseif fs.findItem(fs.warlock.ico_healthstone) then
			fs.useItem(fs.warlock.ico_healthstone);
			return true;
		elseif UnitCanAttack("player", "target") and
				UnitAffectingCombat("target") and
				IsActionInRange(fs.warlock.getSpellSlot(fs.warlock.blutsauger)) == 1 and
				fs.getSpellManaCost(fs.warlock.maxSpell(fs.warlock.blutsauger)) <= mana then
			CastSpellByName(fs.warlock.blutsauger);
			return true;
		else
			return true;
		end
	end
	return false;
end

function fs.warlock.elem_debuff()
	local mana = UnitMana("player");
	if mana < 500 then
		return false;
	end
	if not (fs.playerControlled == "Eulepides") then
		return false;
	end

	local now = GetTime();
	if now - fs.warlock.lastElemBuff < 5 then
		return false;
	else
		fs.warlock.lastElemBuff = now;
	end

	local result;
	
	AssistByName(fs.playerControlled);
	if not fs.targetHasDebuff(fs.warlock.debuff_fde) and
		not fs.targetHasDebuff(fs.warlock.debuff_sheep) then
		local mark = GetRaidTargetIndex("target");
		if mark and not fs.warlock.isAllowed[mark] then
			return false;
		end
		CastSpellByName(fs.warlock.fluchDerElemente);
		result = true;
	end
	result = false;

	return result;
end

function fs.warlock.cast_seelendieb()
	local mana = UnitMana("player");
	if mana < fs.getSpellManaCost(fs.warlock.maxSpell(fs.warlock.seelendieb)) then
		return false;
	end
	local enemyHealth = UnitHealth("target") / UnitHealthMax("target");
	if enemyHealth < 0.2 then
		fs.printDebug(" -- will cast Seelendieb");
		CastSpellByName(fs.warlock.seelendieb);
		return true;
	end
	return false;
end

function fs.warlock.instant_damage()
	local mana = UnitMana("player");
	local nrShards = fs.countItems(fs.warlock.ico_seelensplitter);
	if nrShards > 5 and
		fs.getRemainingSpellCooldown(fs.warlock.maxSpell(fs.warlock.schattenbrand).id) == 0 and
		fs.getSpellManaCost(fs.warlock.maxSpell(fs.warlock.schattenbrand)) <= mana then
		CastSpellByName(fs.warlock.schattenbrand);
		return true;
	end
	return false;
end

function fs.warlock.dots_relevant()
	local targetName = UnitName("target");
	local targetLevel = UnitLevel("target");
	local mobData = MI2_GetMobData(targetName, targetLevel, "target");
	local relativeHealth = UnitHealth("target") / UnitHealthMax("target");
	local maxHealth = mobData.healthMax;
	local currentHealth = maxHealth * relativeHealth;

	if currentHealth > 10000 then
		return true;
	else
		return false;
	end
end

function fs.warlock.dot_inst()
	local mana = UnitMana("player");
	if IsActionInRange(fs.warlock.getSpellSlot(fs.warlock.fluchDerPein)) == 1 then
		fs.printDebug(" -- am in range, will dot!");
		PetAttack();
		-- dot
		if not fs.targetHasDebuff(fs.warlock.dot_fluchDerPein)
			and not fs.targetHasDebuff(fs.warlock.debuff_fde) then
			fs.printDebug(" -- Fluch der Pein");
			if fs.getRemainingSpellCooldown(fs.warlock.maxSpell(fs.warlock.fluchVerstaerken).id) == 0 and
				fs.getSpellManaCost(fs.warlock.maxSpell(fs.warlock.fluchVerstaerken)) <= mana then
				fs.printDebug(" -- -- verstärken");
				CastSpellByName(fs.warlock.fluchVerstaerken);
				return true;
			elseif fs.getSpellManaCost(fs.warlock.maxSpell(fs.warlock.fluchDerPein)) <= mana then
				fs.printDebug(" -- -- casten");
				CastSpellByName(fs.warlock.fluchDerPein);
				return true;
			end
		elseif not fs.targetHasDebuff(fs.warlock.dot_verderbnis) and
			fs.getSpellManaCost(fs.warlock.maxSpell(fs.warlock.verderbnis)) <= mana then
			fs.printDebug(" -- Verderbnis");
			CastSpellByName(fs.warlock.verderbnis);
			return true;
		elseif mana > 2000 and not fs.targetHasDebuff(fs.warlock.dot_lebensentzug) then
			fs.printDebug(" -- Lebensentzug");
			CastSpellByName(fs.warlock.lebensentzug);
			return true;
		end
		fs.printDebug(" -- all dots applied");
		return false;
	else
		fs.printDebug(" -- not in range, will follow");
		return true;
	end
	return false;
end

function fs.warlock.dot_cast()
	local mana = UnitMana("player");
	if mana < 2000 then
		return false;
	end
	if IsActionInRange(fs.warlock.getSpellSlot(fs.warlock.feuerbrand)) == 1 then
		PetAttack();
		if not fs.targetHasDebuff(fs.warlock.dot_feuerbrand) and
			fs.getSpellManaCost(fs.warlock.maxSpell(fs.warlock.feuerbrand)) <= mana then
			CastSpellByName(fs.warlock.feuerbrand);
			return true;
		end
	else
		return true;
	end
	return false;
end

function fs.warlock.do_damage()
	if IsActionInRange(fs.warlock.getSpellSlot(fs.warlock.schattenblitz)) == 1 then
		PetAttack();
		local mana = UnitMana("player");
		local enemyMana = UnitMana("target");
		if mana > 1000 then
			local nrShards = fs.countItems(fs.warlock.seelensplitter);
			if nrShards > 5 and
				fs.getRemainingSpellCooldown(fs.warlock.maxSpell(fs.warlock.seelenfeuer).id) == 0 and
				fs.getSpellManaCost(fs.warlock.maxSpell(fs.warlock.seelenfeuer)) <= mana then
				CastSpellByName(fs.warlock.seelenfeuer);
				return true;
			elseif fs.getSpellManaCost(fs.warlock.maxSpell(fs.warlock.schattenblitz)) <= mana then
				CastSpellByName(fs.warlock.schattenblitz);
				return true;
			end
		elseif mana < 1000 and
			enemyMana > 0.0 and
			fs.getSpellManaCost(fs.warlock.maxSpell(fs.warlock.drainMana)) <= mana then
			UseAction(fs.warlock.drainMana);
			return true;
		elseif not IsAutoRepeatAction(fs.warlock.getSpellSlot(fs.warlock.shoot)) then
			CastSpellByName(fs.warlock.shoot);
			return true;
		end
	else
		return true;
	end
	return false;
end

function fs.warlock.select_target_not_forbidden()
	fs.printDebug("Selecting next not forbidden target");
	local mark = GetRaidTargetIndex("target");
	if not fs.targetHasDebuff(fs.warlock.debuff_sheep) and
			not fs.targetHasDebuff(fs.warlock.debuff_pig) and
			(not mark or fs.warlock.isAllowed[mark]) then
		fs.printDebug(" -- target is good");
		return false;
	end
	return fs.selectNextTargetWithout({fs.warlock.debuff_sheep}, fs.warlock.forbiddenMarks);
end
function fs.warlock.select_target_dot_inst()
	fs.printDebug("Selecting next target for instant dots");
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
				if fs.targetHasDebuff(fs.warlock.dot_verderbnis) then
					fs.printDebug(" -- verderbnis present");
					if fs.targetHasDebuff(fs.warlock.dot_fluchDerPein) then
						fs.printDebug(" -- verderbnis and fluchDerPein present")
						found = 0;
					end
					if fs.targetHasDebuff(fs.warlock.debuff_fde) then
						fs.printDebug(" -- verderbnis and fluchDerElemente present")
						found = 0;
					end
				end
				fs.printDebug(" -- nothing present");
			else
				tookToLong = true;
			end

			if fs.targetHasDebuff(fs.warlock.debuff_sheep) then
				fs.printDebug(" -- sheep present");
				found = 0;
			end

			local mark = GetRaidTargetIndex("target");
			if mark and not fs.warlock.isAllowed[mark] then
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
function fs.warlock.select_target_dot_cast()
	fs.printDebug("Selecting next target for cast dots");
	return fs.selectNextTargetWithout({fs.warlock.dot_feuerbrand, fs.warlock.debuff_sheep}, fs.warlock.forbiddenMarks)
end
function fs.warlock.select_target_damage()
	fs.printDebug("Selecting next target for cast damage");
	return fs.selectNextTargetWithout({fs.warlock.debuff_sheep}, fs.warlock.forbiddenMarks);
end





function fs.warlock.doPrimaryOOCAction()
	local drinks = fs.countItems(fs.ico_drink);
	local eats = fs.countItems(fs.ico_eat);
	if fs.playerControlled == "Eulepides" then
		if drinks < 5 then
			SendChatMessage("I only have "..drinks.." drinks left!", "WHISPER", nil, fs.playerControlled);
		end
		if eats < 5 then
			SendChatMessage("I only have "..eats.." meals left!", "WHISPER", nil, fs.playerControlled);
		end
	end

	local mana = UnitMana("player") / UnitManaMax("player");
	local health = UnitHealth("player") / UnitHealthMax("player");

	if fs.findItem(fs.warlock.ico_healthstone) == 0 and fs.findItem(fs.warlock.ico_seelensplitter) == 1 then
		fs.printDebug("create healthstone");
		CastSpellByName(fs.warlock.createHealthstone);
	elseif not fs.playerHasBuff(fs.warlock.buff_daemonenruestung) then
		fs.printDebug("daemonenrüstung");
		CastSpellByName(fs.warlock.daemonenruestung);
	elseif mana < 0.5 and health < 0.7 then
		if fs.countItems(fs.ico_drink) > 0 and fs.countItems(fs.ico_eat) > 0 then
			fs.useItem(fs.ico_drink);
			fs.useItem(fs.ico_eat);
		end
	elseif health < 0.7 then
		if fs.countItems(fs.ico_eat) > 0 then
			fs.useItem(fs.ico_eat);
		end
	elseif mana < 0.5 then
		if fs.countItems(fs.ico_drink) > 0 then
			fs.useItem(fs.ico_drink);
		end
	elseif fs.countItems(fs.warlock.seelensplitter) > 20 then
		fs.printDebug("drop splitter");
		fs.warlock.dropSplitter();
	else
		fs.printDebug("follow");
		FollowByName(fs.playerControlled);
	end
end

function fs.warlock.dropSplitter()
	if CursorHasItem() then
		DeleteCursorItem();
		return true;
	end

	local nrItems = {};
	nrItems[0] = GetContainerNumSlots(0);
	nrItems[1] = GetContainerNumSlots(1);
	nrItems[2] = GetContainerNumSlots(2);
	nrItems[3] = GetContainerNumSlots(3);
	nrItems[4] = GetContainerNumSlots(4);

	local counter = countItems(fs.warlock.ico_seelensplitter);

	if counter > 5 then
		for idx = 5,counter
		do
			for bag = 0,4
			do
				for slot = 1,nrItems[bag]
				do
					if GetContainerItemInfo(bag, slot) == fs.warlock.ico_seelensplitter then
						PickupContainerItem(bag, slot);
						return true;
					end
				end
			end
		end
	else
		return false;
	end
end


function fs.warlock.setAllowed()
	local mark = GetRaidTargetIndex("target");
	if mark then
		fs.warlock.isAllowed[mark] = true;
		getglobal("ChatFrame1"):AddMessage("Mark '"..fs.markerNames[mark].."' is now allowed");
	end

	fs.warlock.forbiddenMarks = {};
	for _,v in ipairs(fs.warlock.isAllowed) do
		if not fs.warlock.isAllowed[v] then
			table.insert(fs.warlock.forbiddenMarks, v);
		end
	end
end

function fs.warlock.setDisallowed()
	local mark = GetRaidTargetIndex("target");
	if mark then
		fs.warlock.isAllowed[mark] = false;
		getglobal("ChatFrame1"):AddMessage("Mark '"..fs.markerNames[mark].."' is now forbidden");
	end

	fs.warlock.forbiddenMarks = {};
	for _,v in ipairs(fs.warlock.isAllowed) do
		if not fs.warlock.isAllowed[v] then
			table.insert(fs.warlock.forbiddenMarks, v);
		end
	end
end