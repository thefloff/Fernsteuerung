
function fs.warlock.primaryAction()
    fs.printDebug("warlock.primaryAction");

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
        if fs.warlock.checkHealthInCombat() then
            return;
        end

        fs.printDebug("Will apply elemental debuff");

        -- apply element debuff to mage target
        if fs.warlock.elem_debuff() then
            return;
        end

        fs.printDebug("Will check if target forbidden");

        -- avoid forbidden marks
        if fs.warlock.select_target_not_forbidden() then
            return;
        end

        fs.printDebug("Will check Seelendieb");

        -- low health target -> cast seelendieb
        if fs.warlock.cast_seelendieb() then
            return;
        end

        fs.printDebug("Will do instant damage");

        -- instant damage
        if fs.warlock.instant_damage() then
            return;
        end

        fs.printDebug("Will cast instant dots");

        -- apply instant dots
        if fs.warlock.dots_relevant() then
            if fs.warlock.dot_inst() or fs.warlock.select_target_dot_inst() then
                return;
            end
        else
            fs.printDebug(" -- target has too little health for dots");
        end

        fs.printDebug("Will cast longer dots");

        -- apply cast dots
        if fs.warlock.dot_cast() or fs.warlock.select_target_dot_cast() then
            return;
        end

        fs.printDebug("Will do damage");

        -- do damage
        if fs.warlock.do_damage() or fs.warlock.select_target_damage() then
            return;
        end

        fs.printDebug("Will do nothing");

    else
        -- if not active in combat, look at player target
        AssistByName(fs.playerControlled);
        -- if selected enemy
        if UnitCanAttack("player", "target") then
            fs.warlock.do_damage();
        else
            -- else do peaceful action
            fs.warlock.doPrimaryOOCAction();
        end
    end
end

function fs.warlock.secondaryAction()
    fs.printDebug("warlock.secondaryAction");

    -- in combat fear
    if fs.groupInCombat() then
        AssistByName(fs.playerControlled);
        if IsActionInRange(fs.warlock.slt_feuerbrand) == 1 then
            CastSpellByName(fs.warlock.furcht);
        else
            FollowByName(fs.playerControlled);
        end
    else
        -- out of combat fear target or mount up/down
        ClearTarget();
        AssistByName(fs.playerControlled);
        if UnitCanAttack("player", "target") then
            if IsActionInRange(fs.warlock.slt_feuerbrand) == 1 then
                CastSpellByName(fs.warlock.furcht);
            end
        else
            CastSpellByName(fs.warlock.summonMount);
        end
    end

end

function fs.warlock.tertiaryAction()
    fs.printDebug("warlock.tertiaryAction");

end