-- returns the expected avg dmg/s for a player in group/raid
function fs.getAvgDmgOnTarget(victim) 
	local avgDmg = fs.additionalAvgDmg;
	local victimDamageTable = fs.playerDmg[victim];
	if victimDamageTable ~= nil then
		for timestamp in victimDamageTable do
			if GetTime()-timestamp > fs.timeFrameAvgDmg then 
				victimDamageTable[timestamp] = nil;
			else 
				avgDmg = avgDmg + victimDamageTable[timestamp].amount / fs.timeFrameAvgDmg;
			end
		end
	end
	--fs.printDebug("AvgDmg on "..victim..": "..avgDmg);
	return avgDmg;
end