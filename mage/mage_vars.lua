fs.mage = {};

fs.mage.spellListLoaded = false;
fs.mage.spellList = {};

function fs.mage.maxSpell(name)
    return fs.maxSpell(fs.mage.spellList, name);
end

function fs.mage.getSpellSlot(name)
    return fs.getSpellSlot(fs.mage.spellList, name);
end

fs.mage.frostbolt = "Frostblitz"
fs.mage.frostnova = "Frostnova"

fs.mage.summonMount = "Interface\\Icons\\Ability_Mount_MechaStrider";
