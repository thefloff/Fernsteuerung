-- this method should be called by a binded key 
function fs.heal.autoCastHeal() 
	if fs.command ~= nil then
		fs.doCommand();
	end
	if fs.groupInCombat() then
		fs.heal.autoCastHealCombat();
	else 
		fs.heal.autoCastHealNonCombat();
	end
end

-- non-combat options tree:
-- - drink+eat
-- - heal up/decurse team
-- - rebuff
-- - follow
-- - do nothing
function fs.heal.autoCastHealNonCombat() 
	-- todo
end

-- combat options tree:
-- - cast a spell
-- 	  - do a "high" prioritized decurse
--    - select a target
-- 		 - do a "medium" prioritized decurse if nobody dies in the next 5 seconds
--       - select a spell (and a rank) and use it
--    - do a "low" prioritized decurse
-- - interrupt a currently casting spell
-- - do nothing
function fs.heal.autoCastHealCombat() 
	-- todo: - when already casting a spell it would generate more than 40% overheal and the target has SecondsToDie > 3 without it when finished based on expectedDPS and expectedHealAmount then cancel the spell
	if fs[fs.characterClass].combatHealHookHighPriority() then return; end
	if fs.heal.doDecurse("high") then
		return;
	end
	local selectedUnit, secondsToDie, lowPriorityDecurse, mediumPriorityDecurse = fs.heal.selectTarget();
	local selectedUnitName = UnitName(selectedUnit);
	if mediumPriorityDecurse then
		if fs.heal.doDecurse("medium") then
			return;
		end
	end
	if not lowPriorityDecurse then
		if fs[fs.characterClass].combatHealHookWithTargetSelected(selectedUnit, selectedUnitName, secondsToDie) then return; end
		local highestP = 0;
		local selectedSpell = nil;
		local selectedSpellName = nil;
		local spellList = fs[fs.characterClass].healSpells;
		for fullSpellName, spell in pairs(spellList) do
			if not spell.onlyCustomUse and fs.heal.isHealSpellPossible(spell, selectedUnit) then -- kick out all impossible spells (cd, mana, range, already set hots)
				secondsToDieFactor = min(max(secondsToDie, 0) / 7, 1);  -- from 1 (7 or more seconds time) to 0 (nearly dead)
				local p = spell.normalizedManaEfficency * secondsToDieFactor;
				p = p + (spell.normalizedCastTime * (1 - secondsToDieFactor));
				p = p + fs.heal.calcNormalizedHealAmmountOnPoint(spell, selectedUnit, selectedUnitName);
				if p > highestP then 
					highestP = p;
					selectedSpellName = fullSpellName;
					selectedSpell = spell;
					--fs.printDebug("Higher p ("..p.."), new selectedSpell = "..selectedSpellName);
				end
			end
		end
		-- use selected spell
		if selectedSpellName ~= nil then
			fs.printDebug("selectedSpell = "..selectedSpellName);
			TargetUnit(selectedUnit);
			fs.heal.sendHealAddonMessage(selectedUnitName, selectedSpell.expectedHeal, selectedSpell.casttime, selectedSpell.expectedHotHeal, selectedSpell.hottime);
			CastSpellByName(selectedSpellName);
			return;
		end 	
	else 
		if fs[fs.characterClass].combatHealHookLowPriority() then return; end
		if fs.heal.doDecurse("low") then
			return;
		end
	end
end

function fs.heal.doDecurse(priority)
	-- todo: check for decurse and return true if done
	return false;
end

function fs.heal.sendHealAddonMessage(unitName, expectedHeal, casttime, expectedHotHeal, hottime) 
	fs.heal.actSpellCast = {unitName=unitName, expectedHeal=expectedHeal, casttime=casttime, expectedHotHeal=expectedHotHeal, hottime=hottime, t=nil};
end

function fs.heal.calcNormalizedHealAmmountOnPoint(spell, unit, unitName) 
	local hpLost = UnitHealthMax(unit) - UnitHealth(unit);
	-- add dmg expected
	local expectedDmgPerSecond = fs.heal.getAvgDmgOnTarget(unitName);
	hpLost = hpLost + expectedDmgPerSecond * spell.casttime;
	-- subtract heal expected
	local expectedHealUntilCastFinished = fs.heal.getExpectedHealUntilTime(unitName, GetTime() + spell.casttime);
	hpLost = hpLost - expectedHealUntilCastFinished;
	local expectedHeal = spell.expectedHeal;
	local expectedHealWithHots =  expectedHeal + spell.expectedHotHeal;
	if hpLost > expectedHeal then 
		local p = expectedHeal / hpLost;
		if spell.hottime > 0 then
			local expectedHotOverheal = expectedHealWithHots - hpLost;
			expectedHotOverheal = expectedHotOverheal - expectedDmgPerSecond * spell.hottime;
			expectedHotOverheal = expectedHotOverheal - expectedHealUntilCastFinished + fs.heal.getExpectedHealUntilTime(unitName, GetTime() + spell.hottime);
			return fs.heal.calcOverhealValue(expectedHealWithHots, expectedHotOverheal);
		else
			return p;
		end
	else
		local expectedOverheal = expectedHeal - hpLost;
		if spell.hottime > 0 then
			expectedOverheal = expectedHealWithHots - hpLost;
			expectedOverheal = expectedOverheal - expectedDmgPerSecond * spell.hottime;
			expectedOverheal = expectedOverheal - expectedHealUntilCastFinished + fs.heal.getExpectedHealUntilTime(unitName, GetTime() + spell.hottime);
		end
		return fs.heal.calcOverhealValue(expectedHealWithHots, expectedOverheal);
	end
end

function fs.heal.calcLostHPUntil(unit, unitName, t)
	local hpLost = UnitHealthMax(unit) - UnitHealth(unit);
	-- add dmg expected
	local expectedDmgPerSecond = fs.heal.getAvgDmgOnTarget(unitName);
	hpLost = hpLost + expectedDmgPerSecond * t;
	-- subtract heal expected
	local expectedHealUntilCastFinished = fs.heal.getExpectedHealUntilTime(unitName, GetTime() + t);
	hpLost = hpLost - expectedHealUntilCastFinished;
	return hpLost;
end

function fs.heal.calcOverhealValue(heal, overheal)
	return min(((heal * 0.15) - overheal) / (heal * 0.15), 0);
end

function fs.heal.isHealSpellPossible(spell, targetUnit)
	-- cd check
	if fs.getRemainingSpellCooldown(spell.spellID, spell.cooldown) > 0 then
		return false;
	end
	-- mana check
	local mana = UnitMana("player");
	if fs.getSpellManaCosts(spell) > mana then
		return false;
	end
	-- range check 
	ClearTarget();
	CastSpellByName(spell.name);
	if not SpellCanTargetUnit(targetUnit) then
		return false;
	end
	SpellStopTargeting();
	-- hot already set check
	if spell.hotIconName ~= nil and fs.unitHasBuff(pell.hotIconName, targetUnit) then
		return false;
	end
	-- check for custom condition
	if not fs[fs.characterClass].isHealSpellPossible(spell, targetUnit) then
		return false;
	end
	return true;
end

-- returns the unit with lowest secondsTodDie, secondsToDie, lowPriorityDecurse, mediumPriorityDecurse, shouldGroupHeal
function fs.heal.selectTarget() 
	local lowPriorityDecurse = true;
	local mediumPriorityDecurse = true;
	local selectedUnit = "player";
	local lowestSecondsToDie = fs.heal.calcSecondsToDie("player");
	fs.printDebug("Seconds to die for "..UnitName("player").."="..lowestSecondsToDie);
	ClearTarget();
	CastSpellByName(fs[fs.characterClass].rangeCheckSpell);
	lowestSecondsToDie, selectedUnit, lowPriorityDecurse, mediumPriorityDecurse = fs.heal.selectTargetIterator("party", 4, lowestSecondsToDie, selectedUnit, lowPriorityDecurse, mediumPriorityDecurse);
	lowestSecondsToDie, selectedUnit, lowPriorityDecurse, mediumPriorityDecurse = fs.heal.selectTargetIterator("partypet", 4, lowestSecondsToDie, selectedUnit, lowPriorityDecurse, mediumPriorityDecurse);
	lowestSecondsToDie, selectedUnit, lowPriorityDecurse, mediumPriorityDecurse = fs.heal.selectTargetIterator("raid", 40, lowestSecondsToDie, selectedUnit, lowPriorityDecurse, mediumPriorityDecurse); 
	lowestSecondsToDie, selectedUnit, lowPriorityDecurse, mediumPriorityDecurse = fs.heal.selectTargetIterator("raidpet", 40, lowestSecondsToDie, selectedUnit, lowPriorityDecurse, mediumPriorityDecurse);
	SpellStopTargeting();
	fs.printDebug("selectedUnit="..UnitName(selectedUnit).."  lowPriorityDecurse="..fs.boolToString(lowPriorityDecurse).."  mediumPriorityDecurse="..fs.boolToString(mediumPriorityDecurse).."  shouldGroupHeal="..fs.boolToString(shouldGroupHeal));
	return selectedUnit, lowestSecondsToDie, lowPriorityDecurse, mediumPriorityDecurse, shouldGroupHeal;
end

function fs.heal.selectTargetIterator(unitGroup, range, lowestSecondsToDie, selectedUnit, lowPriorityDecurse, mediumPriorityDecurse) 
	for i=1,range do
		local unit = unitGroup..i;
		if(SpellCanTargetUnit(unit)) then
			local unitName = UnitName(unit);
			if not fs.containsValue(fs.heal.targetBlackList, unitName) then
				local secondsToDie = fs.heal.calcSecondsToDie(unit);
				fs.printDebug("Seconds to die for "..unitName.."="..secondsToDie);
				-- check lowPriorityDecurse
				if lowPriorityDecurse and (secondsToDie < 30 or fs.heal.calcHPPercentWithExpectedHeal(unit, unitName) < 0.9) then
					lowPriorityDecurse = false;
				end
				-- check mediumPriorityDecurse
				if mediumPriorityDecurse and secondsToDie < 5 then
					mediumPriorityDecurse = false;
				end
				-- check selected target
				if lowestSecondsToDie > secondsToDie then
					lowestSecondsToDie = secondsToDie;
					selectedUnit = unit;
				end
			end
		end
	end
	return lowestSecondsToDie, selectedUnit, lowPriorityDecurse, mediumPriorityDecurse;
end

function fs.heal.calcHPPercentWithExpectedHeal(unit, name) 
	local hp = UnitHealth(unit) + fs.heal.getExpectedHealUntilTime(name, GetTime()+60);
	return hp / UnitHealthMax(unit);
end

function fs.heal.calcSecondsToDie(unit)
	local unitName = UnitName(unit);
	local hp = UnitHealth(unit) - fs.heal.buffer;
	local avgDmg = fs.heal.getAvgDmgOnTarget(unitName);
	local secondsToDie = hp / avgDmg;
	local lastExpectedHealInTime = 0;
	local expectedHealInTime = fs.heal.getExpectedHealUntilTime(unitName, GetTime() + secondsToDie);
	while expectedHealInTime > lastExpectedHealInTime do
		secondsToDie = (hp + expectedHealInTime) / avgDmg;
		lastExpectedHealInTime = expectedHealInTime;
		expectedHealInTime = fs.heal.getExpectedHealUntilTime(unitName, GetTime() + secondsToDie);
	end
	return secondsToDie;
end

-- returns the expected avg dmg/s for a player in group/raid
function fs.heal.getAvgDmgOnTarget(victim) 
	local avgDmg = fs.heal.additionalAvgDmg;
	local victimDamageTable = fs.playerDmg[victim];
	if victimDamageTable ~= nil then
		for timestamp in victimDamageTable do
			if GetTime()-timestamp > fs.heal.timeFrameAvgDmg then 
				victimDamageTable[timestamp] = nil;
			else 
				avgDmg = avgDmg + victimDamageTable[timestamp].amount / fs.heal.timeFrameAvgDmg;
			end
		end
	end
	--fs.printDebug("AvgDmg on "..victim..": "..avgDmg);
	return avgDmg;
end

-- returns the expected heal for a player until a given time
function fs.heal.getExpectedHealUntilTime(player, t) 
	local expectedHeal = 0;
	local playerHealTable = fs.playerIncomingHeal[player];
	if playerHealTable ~= nil then
		for timestamp in playerHealTable do
			if 0+timestamp < GetTime() then 
				playerHealTable[timestamp] = nil;
			elseif 0+timestamp < t then
				expectedHeal = expectedHeal + playerHealTable[timestamp].amount;
			end
		end
	end
	--fs.printDebug("ExpectedHeal on "..player..": "..expectedHeal);
	return expectedHeal;
end


















