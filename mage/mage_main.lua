function fs.mage.primaryAction()
    fs.printDebug("mage.primaryAction");

    if not fs.mage.spellListLoaded then
        fs.printDebug("süelllist not loaded");
        fs.getSpellList(fs.mage.spellList);
        fs.mage.spellListLoaded = true;
    end

    AssistByName(fs.playerControlled);
    if UnitCanAttack("player", "target") then
        CastSpellByName(fs.mage.frostbolt);
    else
        FollowByName(fs.playerControlled);
    end
end

function fs.mage.secondaryAction()
    fs.printDebug("mage.secondaryAction");

    if not fs.mage.spellListLoaded then
        fs.printDebug("süelllist not loaded");
        fs.getSpellList(fs.mage.spellList);
        fs.mage.spellListLoaded = true;
    end

    if fs.groupInCombat() then
        AssistByName(fs.playerControlled);
        CastSpellByName(fs.mage.frostnova);
    else
        ClearTarget();
        fs.useItem(fs.mage.summonMount);
    end
end

function fs.mage.tertiaryAction()
    fs.printDebug("mage.tertiaryAction");
end