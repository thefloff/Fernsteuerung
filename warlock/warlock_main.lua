
function warlock.primaryAction()
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
        if warlock.checkHealthInCombat() then
            return;
        end

        fs.printDebug("Will apply elemental debuff");

        -- apply element debuff to mage target
        if warlock.elem_debuff() then
            return;
        end

        fs.printDebug("Will check if target forbidden");

        -- avoid forbidden marks
        if warlock.select_target_not_forbidden() then
            return;
        end

        fs.printDebug("Will check Seelendieb");

        -- low health target -> cast seelendieb
        if warlock.cast_seelendieb() then
            return;
        end

        fs.printDebug("Will do instant damage");

        -- instant damage
        if warlock.instant_damage() then
            return;
        end

        fs.printDebug("Will cast instant dots");

        -- apply instant dots
        if warlock.dots_relevant() then
            if warlock.dot_inst() or warlock.select_target_dot_inst() then
                return;
            end
        else
            fs.printDebug(" -- target has too little health for dots");
        end

        fs.printDebug("Will cast longer dots");

        -- apply cast dots
        if warlock.dot_cast() or warlock.select_target_dot_cast() then
            return;
        end

        fs.printDebug("Will do damage");

        -- do damage
        if warlock.do_damage() or warlock.select_target_damage() then
            return;
        end

        fs.printDebug("Will do nothing");

    else
        -- if not active in combat, look at player target
        AssistByName(fs.playerControlled);
        -- if selected enemy
        if UnitCanAttack("player", "target") then
            warlock.do_damage();
        else
            -- else do peaceful action
            warlock.doPrimaryOOCAction();
        end
    end
end

function warlock.secondaryAction()
    fs.printDebug("warlock.secondaryAction");

    -- in combat fear
    if fs.groupInCombat() then
        AssistByName(fs.playerControlled);
        if IsActionInRange(warlock.slt_feuerbrand) == 1 then
            CastSpellByName(warlock.furcht);
        else
            FollowByName(fs.playerControlled);
        end
    else
        -- out of combat fear target or mount up/down
        ClearTarget();
        AssistByName(fs.playerControlled);
        if UnitCanAttack("player", "target") then
            if IsActionInRange(warlock.slt_feuerbrand) == 1 then
                CastSpellByName(warlock.furcht);
            end
        else
            CastSpellByName(warlock.summonMount);
        end
    end

end

function warlock.tertiaryAction()
    fs.printDebug("warlock.tertiaryAction");

end