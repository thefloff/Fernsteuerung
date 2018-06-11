function warlock.checkHealthInCombat()
	local health = UnitHealth("player") / UnitHealthMax("player");
	if health < 0.3 then
		if GetActionCooldown(warlock.slt_todesmantel) == 0 then
			CastSpellByName(warlock.todesmantel);
			return true;
		elseif fs.findItem(warlock.ico_healthstone) then
			fs.useItem(warlock.ico_healthstone);
			return true;
		elseif UnitCanAttack("player", "target") and
				UnitAffectingCombat("target") and
				IsActionInRange(1) == 1 then
			CastSpellByName(warlock.blutsauger);
			return true;
		else
			FollowByName(fs.playerControlled);
			return true;
		end
	end
	return false;
end

function warlock.elem_debuff()
	local mana = UnitMana("player") / UnitManaMax("player");
	if mana < 0.1 then
		return false;
	end
	if not (fs.playerControlled == "Eulepides") then
		return false;
	end

	local now = GetTime();
	if now - warlock.lastElemBuff < 5 then
		return false;
	else
		warlock.lastElemBuff = now;
	end

	local result;
	
	AssistByName(fs.playerControlled);
	if not fs.targetHasDebuff(warlock.debuff_fde) and
		not fs.targetHasDebuff(warlock.debuff_sheep) then
		local mark = GetRaidTargetIndex("target");
		if mark and not warlock.isAllowed[mark] then
			return false;
		end
		CastSpellByName(warlock.fluchDerElemente);
		result = true;
	end
	result = false;

	return result;
end

function warlock.cast_seelendieb()
	local mana = UnitMana("player") / UnitManaMax("player");
	if mana < 0.1 then
		return false;
	end
	local enemyHealth = UnitHealth("target") / UnitHealthMax("target");
	if enemyHealth < 0.2 then
		fs.printDebug(" -- will cast Seelendieb");
		CastSpellByName(warlock.seelendieb);
		return true;
	end
	return false;
end

function warlock.instant_damage()
	local mana = UnitMana("player") / UnitManaMax("player");
	if mana < 0.1 then
		return false;
	end
	local nrShards = fs.countItems(warlock.ico_seelensplitter);
	if nrShards > 5 and GetActionCooldown(warlock.slt_schattenbrand) == 0 then
		CastSpellByName(warlock.schattenbrand);
		return true;
	end
	return false;
end

function warlock.dots_relevant()
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

function warlock.dot_inst()
	local mana = UnitMana("player") / UnitManaMax("player");
	if IsActionInRange(fs.slt_feuerbrand) == 1 then
		fs.printDebug(" -- am in range, will dot!");
		PetAttack();
		-- dot
		if not fs.targetHasDebuff(warlock.dot_fluchDerPein)
			and not fs.targetHasDebuff(warlock.debuff_fde) then
			fs.printDebug(" -- Fluch der Pein");
			if GetActionCooldown(warlock.slt_fluchVerstaerken) == 0 then
				fs.printDebug(" -- -- verstärken");
				CastSpellByName(warlock.fluchVerstaerken);
				return true;
			else
				fs.printDebug(" -- -- casten");
				CastSpellByName(warlock.fluchDerPein);
				return true;
			end
		elseif not fs.targetHasDebuff(warlock.dot_verderbnis) then
			fs.printDebug(" -- Verderbnis");
			CastSpellByName(warlock.verderbnis);
			return true;
		elseif mana > 0.5 and not fs.targetHasDebuff(warlock.dot_lebensentzug) then
			fs.printDebug(" -- Lebensentzug");
			CastSpellByName(warlock.lebensentzug);
			return true;
		end
		fs.printDebug(" -- all dots applied");
		return false;
	else
		fs.printDebug(" -- not in range, will follow");
		FollowByName(fs.playerControlled);
		return true;
	end
	return false;
end

function warlock.dot_cast()
	local mana = UnitMana("player") / UnitManaMax("player");
	if mana < 0.2 then
		return false;
	end
	if IsActionInRange(warlock.slt_feuerbrand) == 1 then
		PetAttack();
		if not fs.targetHasDebuff(warlock.dot_feuerbrand) then
			CastSpellByName(warlock.feuerbrand);
			return true;
		end
	else
		FollowByName(warlock.playerControlled);
		return true;
	end
	return false;
end

function warlock.do_damage()
	if IsActionInRange(1) == 1 then
		PetAttack();
		local mana = UnitMana("player") / UnitManaMax("player");
		local enemyMana = UnitMana("target");
		if mana > 0.2 then
			local nrShards = fs.countItems(warlock.seelensplitter);
			if nrShards > 5 and GetActionCooldown(warlock.slt_seelenfeuer) == 0 then
				CastSpellByName(warlock.seelenfeuer);
				return true;
			else
				CastSpellByName(warlock.schattenblitz);
				return true;
			end
		elseif mana < 0.1 and enemyMana > 0.0 then
			UseAction(warlock.drainMana);
			return true;
		elseif not IsAutoRepeatAction(13) then
			CastSpellByName("Schießen");
			return true;
		end
	else
		FollowByName(fs.playerControlled);
		return true;
	end
	return false;
end

function warlock.select_target_not_forbidden()
	fs.printDebug("Selecting next not forbidden target");
	local mark = GetRaidTargetIndex("target");
	if not fs.targetHasDebuff(warlock.debuff_sheep) and
			(not mark or warlock.isAllowed[mark]) then
		fs.printDebug(" -- target is good");
		return false;
	end
	return fs.selectNextTargetWithout({warlock.debuff_sheep}, warlock.forbiddenMarks);
end
function warlock.select_target_dot_inst()
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
				if fs.targetHasDebuff(warlock.dot_verderbnis) then
					fs.printDebug(" -- verderbnis present");
					if fs.targetHasDebuff(warlock.dot_fluchDerPein) then
						fs.printDebug(" -- verderbnis and fluchDerPein present")
						found = 0;
					end
					if fs.targetHasDebuff(warlock.debuff_fde) then
						fs.printDebug(" -- verderbnis and fluchDerElemente present")
						found = 0;
					end
				end
				fs.printDebug(" -- nothing present");
			else
				tookToLong = true;
			end

			if fs.targetHasDebuff(warlock.debuff_sheep) then
				fs.printDebug(" -- sheep present");
				found = 0;
			end

			local mark = GetRaidTargetIndex("target");
			if mark and not warlock.isAllowed[mark] then
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
function warlock.select_target_dot_cast()
	fs.printDebug("Selecting next target for cast dots");
	return fs.selectNextTargetWithout({warlock.dot_feuerbrand, warlock.debuff_sheep}, warlock.forbiddenMarks)
end
function warlock.select_target_damage()
	fs.printDebug("Selecting next target for cast damage");
	return fs.selectNextTargetWithout({warlock.debuff_sheep}, warlock.forbiddenMarks);
end





function warlock.doPrimaryOOCAction()
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

	if fs.findItem(warlock.ico_healthstone) == 0 and fs.findItem(warlock.ico_seelensplitter) == 1 then
		CastSpellByName(warlock.createHealthstone);
	elseif not fs.playerHasBuff(warlock.buff_daemonenruestung) then
		CastSpellByName(warlock.daemonenruestung);
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
	elseif fs.countItems(warlock.seelensplitter) > 20 then
		warlock.dropSplitter();
	else
		FollowByName(fs.playerControlled);
	end
end

function warlock.dropSplitter()
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

	local counter = countItems(warlock.ico_seelensplitter);

	if counter > 5 then
		for idx = 5,counter
		do
			for bag = 0,4
			do
				for slot = 1,nrItems[bag]
				do
					if GetContainerItemInfo(bag, slot) == warlock.ico_seelensplitter then
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


function warlock.setAllowed()
	local mark = GetRaidTargetIndex("target");
	if mark then
		warlock.isAllowed[mark] = true;
		getglobal("ChatFrame1"):AddMessage("Mark '"..fs.markerNames[mark].."' is now allowed");
	end

	warlock.forbiddenMarks = {};
	for i,v in ipairs(warlock.isAllowed) do
		if not warlock.isAllowed[v] then
			table.insert(warlock.forbiddenMarks, v);
		end
	end
end

function warlock.setDisallowed()
	local mark = GetRaidTargetIndex("target");
	if mark then
		warlock.isAllowed[mark] = false;
		getglobal("ChatFrame1"):AddMessage("Mark '"..fs.markerNames[mark].."' is now forbidden");
	end

	warlock.forbiddenMarks = {};
	for i,v in ipairs(warlock.isAllowed) do
		if not warlock.isAllowed[v] then
			table.insert(warlock.forbiddenMarks, v);
		end
	end
end
