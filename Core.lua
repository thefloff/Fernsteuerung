
function Fernsteuerung()
	getglobal("ChatFrame1"):AddMessage("Loaded Fernsteuerung");
end

function fs.setPlayerName(name)
	fs.playerControlled = name;
	getglobal("ChatFrame1"):AddMessage("Player: "..name);
end

function fs.primaryAction()
	fs.printDebug("fs.primaryAction");

	local enemyHealth = UnitHealth("target") / UnitHealthMax("target");
	if (enemyHealth == 0.0) then
		fs.printDebug("Target dead, clearing target");
		ClearTarget();
	end
	
	-- if already active in combat
	if UnitCanAttack("player", "target") and
		UnitAffectingCombat("target") then

		fs.printDebug("Will check health");

		-- heal if necessary
		if fs.checkHealthInCombat() then
			return;
		end

		fs.printDebug("Will apply elemental debuff");
		
		-- apply element debuff to mage target
		if fs.elem_debuff() then
			return;
		end

		fs.printDebug("Will check if target forbidden");

		-- avoid forbidden marks
		if fs.select_target_not_forbidden() then
			return;
		end

		fs.printDebug("Will check Seelendieb");

		-- low health target -> cast seelendieb
		if fs.cast_seelendieb() then
			return;
		end

		fs.printDebug("Will do instant damage");

		-- instant damage
		if fs.instant_damage() then
			return;
		end

		fs.printDebug("Will cast instant dots");
		
		-- apply instant dots
		if fs.dots_relevant() then
			if fs.dot_inst() or fs.select_target_dot_inst() then
				return;
			end
		else
			fs.printDebug(" -- target has too little health for dots");
		end

		fs.printDebug("Will cast longer dots");
		
		-- apply cast dots
		if fs.dot_cast() or fs.select_target_dot_cast() then
			return;
		end

		fs.printDebug("Will do damage");

		-- do damage
		if fs.do_damage() or fs.select_target_damage() then
			return;
		end

		fs.printDebug("Will do nothing");
	
	else
	-- if not active in combat, look at player target
		AssistByName(fs.playerControlled);
		-- if selected enemy
		if UnitCanAttack("player", "target") then
			fs.do_damage();
		else
			-- else do peaceful action
			fs.doPrimaryOOCAction();
		end
	end
end


function fs.secondaryAction()
	-- in combat fear
	if fs.groupInCombat() then
		AssistByName(fs.playerControlled);
		if IsActionInRange(fs.slt_feuerbrand) == 1 then
			CastSpellByName(fs.furcht);
		else
			FollowByName(fs.playerControlled);
		end
	else
		-- out of combat fear target or mount up/down
		ClearTarget();	
		AssistByName(fs.playerControlled);
		if UnitCanAttack("player", "target") then
			if IsActionInRange(fs.slt_feuerbrand) == 1 then
				CastSpellByName(fs.furcht);
			end
		else
			CastSpellByName(fs.summonMount);
		end
	end
end
