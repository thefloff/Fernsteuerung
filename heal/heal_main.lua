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
	-- todo
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
	fs.printDebug("AvgDmg on "..victim..": "..avgDmg);
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
	fs.printDebug("ExpectedHeal on "..player..": "..expectedHeal);
	return expectedHeal;
end



















