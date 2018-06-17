-- this method should be called by a binded key 
function fs.heal.autoCastHeal() 
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
--    - select group heal and use it
--    - do a "low" prioritized decurse
-- - interrupt a currently casting spell
-- - do nothing
-- SendAddonMessage( "Fernsteuerung", "HEAL:"..targetName..":"..expectedHeal..":"..GetTime()+casttime, "RAID");
function fs.heal.autoCastHealCombat() 
	-- todo: - when already casting a spell it would generate more than 40% overheal and the target has SecondsToDie > 3 without it when finished based on expectedDPS and expectedHealAmount then cancel the spell
	-- todo: call fs[fs.characterClass].combatHealHookHighPriority();  and return when returned true
	if fs.heal.doDecurse("high") then
		return;
	end
	local selectedUnit, lowPriorityDecurse, mediumPriorityDecurse, shouldGroupHeal = fs.heal.selectTarget();
	if mediumPriorityDecurse then
		if fs.heal.doDecurse("medium") then
			return;
		end
	end
	if not lowPriorityDecurse then
			if shouldGroupHeal then
			-- todo: groupHeals
		else
			-- todo: call fs[fs.characterClass].combatHealHookWithTargetSelected();  and return when returned true
	-- 		- kick out all impossible spells (cd, mana, range, already set hots)
	-- 		- calculate a value p for each spell
	-- 			- secondsToDieFactor = min(max(SecondsToDie, 0) / 7), 1)  -- from 1 (plenty of time) to 0 (nearly dead)
	-- 			- p = normalizedManaEfficency * secondsToDieFactor
	-- 			- p += normalizedCastTime * (1 - secondsToDieFactor)
	-- 			- p += normalizedHealAmmountOnPoint
	--        	- use spell with highest p
		end 	
	else 
		-- todo: call fs[fs.characterClass].combatHealHookLowPriority();  and return when returned true
		if fs.heal.doDecurse("low") then
			return;
		end
	end
end

function fs.heal.doDecurse(priority)
	-- todo: check for decurse and return true if done
	return false;
end

-- returns the unit with lowest secondsTodDie, lowPriorityDecurse, mediumPriorityDecurse, shouldGroupHeal
function fs.heal.selectTarget() 
	local lowPriorityDecurse = true;
	local mediumPriorityDecurse = true;
	local groupHeal = true;
	local selectedUnit = "player";
	local lowestSecondsToDie = fs.heal.calcSecondsToDie("player");
	fs.printDebug("Seconds to die for "..UnitName("player").."="..lowestSecondsToDie);
	ClearTarget();
	CastSpellByName(fs[fs.characterClass].rangeCheckSpell);
	lowestSecondsToDie, selectedUnit, lowPriorityDecurse, mediumPriorityDecurse, groupHeal = fs.heal.selectTargetIterator("party", 4, lowestSecondsToDie, selectedUnit, lowPriorityDecurse, mediumPriorityDecurse, groupHeal);
	lowestSecondsToDie, selectedUnit, lowPriorityDecurse, mediumPriorityDecurse, groupHeal = fs.heal.selectTargetIterator("partypet", 4, lowestSecondsToDie, selectedUnit, lowPriorityDecurse, mediumPriorityDecurse, groupHeal);
	lowestSecondsToDie, selectedUnit, lowPriorityDecurse, mediumPriorityDecurse, groupHeal = fs.heal.selectTargetIterator("raid", 40, lowestSecondsToDie, selectedUnit, lowPriorityDecurse, mediumPriorityDecurse, groupHeal); 
	lowestSecondsToDie, selectedUnit, lowPriorityDecurse, mediumPriorityDecurse, groupHeal = fs.heal.selectTargetIterator("raidpet", 40, lowestSecondsToDie, selectedUnit, lowPriorityDecurse, mediumPriorityDecurse, groupHeal);
	SpellStopTargeting();
	fs.printDebug("selectedUnit="..UnitName(selectedUnit).."  lowPriorityDecurse="..fs.boolToString(lowPriorityDecurse).."  mediumPriorityDecurse="..fs.boolToString(mediumPriorityDecurse).."  shouldGroupHeal="..fs.boolToString(shouldGroupHeal));
	return selectedUnit, lowPriorityDecurse, mediumPriorityDecurse, shouldGroupHeal;
end

function fs.heal.selectTargetIterator(unitGroup, range, lowestSecondsToDie, selectedUnit, lowPriorityDecurse, mediumPriorityDecurse, groupHeal) 
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
				-- check groupHeal
				-- todo
				-- check selected target
				if lowestSecondsToDie > secondsToDie then
					lowestSecondsToDie = secondsToDie;
					selectedUnit = unit;
				end
			end
		end
	end
	return lowestSecondsToDie, selectedUnit, lowPriorityDecurse, mediumPriorityDecurse, groupHeal;
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
	local expectedHealInTime = fs.heal.getExpectedHealUntilTime(unitName, secondsToDie);
	while expectedHealInTime > lastExpectedHealInTime do
		secondsToDie = (hp + expectedHealInTime) / avgDmg;
		lastExpectedHealInTime = expectedHealInTime;
		expectedHealInTime = fs.heal.getExpectedHealUntilTime(unitName, secondsToDie);
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



















