
function fs.paladin.primaryAction()
    fs.printDebug("paladin.primaryAction()");
end

function fs.paladin.secondaryAction()
    fs.printDebug("paladin.secondaryAction()");
end

function fs.paladin.tertiaryAction()
    fs.printDebug("paladin.tertiaryAction()");
end

function fs.paladin.isHealSpellPossible(spell, unit)
	return true;
end

function fs.paladin.combatHealHookLowPriority() 
	return false;
end

function fs.paladin.combatHealHookHighPriority() 
	local bubble = fs.paladin.healSpells["Gottesschild(Rang 2)"];
	-- use bubble?
	if UnitHealth("player") / UnitHealthMax("player") < 0.3 
	  and fs.getRemainingSpellCooldown(bubble.spellID) == 0
	  and not fs.unitHasDebuff(fs.paladin.vorahnungDebuff, "player") 
	  and fs.getSpellManaCost(bubble) < UnitMana("player") then
		CastSpellByName("Gottesschild(Rang 2)");
		fs.printDebug("cast Gottesschild(Rang 2)");
		return true;
	end

	return false;
end

function fs.paladin.combatHealHookWithTargetSelected(unit, unitName, secondsToDie) 
	if secondsToDie < 2.5 and UnitHealth(unit) / UnitHealthMax(unit) < 0.3 then
		local sds = fs.paladin.healSpells["Segen des Schutzes(Rang 3)"];
		local loh = fs.paladin.healSpells["Handauflegung(Rang 3)"];
		-- use sds?
		if fs.heal.isHealSpellPossible(sds, unit) 
		  and not fs.unitHasDebuff(fs.paladin.vorahnungDebuff, unit) 
		  and fs.getNormalizedClassName(UnitClass(unit)) ~= "warrior" then
			TargetUnit(unit);
			CastSpellByName("Segen des Schutzes(Rang 3)");
			fs.printDebug("cast Segen des Schutzes(Rang 3)");
			return true;
		end 
		-- use lay on hands?
		if fs.heal.isHealSpellPossible(loh, unit) and UnitMana("player") < 250 then 
			TargetUnit(unit);
			CastSpellByName("Handauflegung(Rang 3)");
			fs.printDebug("cast Handauflegung(Rang 3)");
			return true;
		end
	end
	-- use divine favor?
	local dv = fs.paladin.healSpells["Göttliche Gunst"];
	local hl8 = fs.paladin.healSpells["Heiliges Licht(Rang 8)"];
	local lostHP = fs.heal.calcLostHPUntil(unit, unitName, 3);
	if hl8.expectedHeal * 1.3 < lostHP and secondsToDie > 3 
	  and fs.getRemainingSpellCooldown(dv.spellID) == 0
	  and fs.getSpellManaCost(hl8) + fs.getSpellManaCost(dv) < UnitMana("player") then
		CastSpellByName("Göttliche Gunst");
		fs.printDebug("cast Göttliche Gunst");
		fs.heal.sendHealAddonMessage(unitName, hl8.expectedHeal*1.5, hl8.casttime, 0, 0);
		fs.sendCastCommand(UnitName("player"), "Heiliges Licht(Rang 8)", unitName);
		return true;
	end
	return false;
end


















