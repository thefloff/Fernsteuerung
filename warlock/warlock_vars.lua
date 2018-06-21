fs.warlock = {};

fs.warlock.lastElemBuff = 0;
fs.warlock.spellListLoaded = false;

fs.warlock.spellList = {};

function fs.warlock.maxSpell(name)
    return fs.maxSpell(fs.warlock.spellList, name);
end

function fs.warlock.getSpellSlot(name)
    return fs.getSpellSlot(fs.warlock.spellList, name);
end

fs.warlock.dot_fluchDerPein = "Interface\\Icons\\Spell_Shadow_CurseOfSargeras";
fs.warlock.dot_verderbnis = "Interface\\Icons\\Spell_Shadow_AbominationExplosion";
fs.warlock.dot_feuerbrand = "Interface\\Icons\\Spell_Fire_Immolation";
fs.warlock.dot_lebensentzug = "Interface\\Icons\\Spell_Shadow_Requiem";
fs.warlock.buff_daemonenruestung = "Interface\\Icons\\Spell_Shadow_RagingScream";
fs.warlock.debuff_sheep = "Interface\\Icons\\Spell_Nature_Polymorph";
fs.warlock.debuff_fde = "Interface\\Icons\\Spell_Shadow_ChillTouch";
fs.warlock.debuff_fear = "Interface\\Icons\\Spell_Shadow_Possession";

fs.warlock.fluchDerPein = "Fluch der Pein";
fs.warlock.fluchVerstaerken = "Fluch verstärken";
fs.warlock.verderbnis = "Verderbnis";
fs.warlock.feuerbrand = "Feuerbrand";
fs.warlock.lebensentzug = "Lebensentzug";
fs.warlock.schattenblitz = "Schattenblitz";
fs.warlock.furcht = "Furcht";
fs.warlock.drainMana = "Mana entziehen";
fs.warlock.seelendieb = "Seelendieb";
fs.warlock.createHealthstone = "Gesundheitsstein herstellen";
fs.warlock.blutsauger = "Blutsauger";
fs.warlock.summonMount = "Teufelsross beschwören";
fs.warlock.summonImp = "Wichtel beschwören";
fs.warlock.daemonenruestung = "Dämonenrüstung";
fs.warlock.todesmantel = "Todesmantel";
fs.warlock.fluchDerElemente = "Fluch der Elemente";
fs.warlock.schattenbrand = "Schattenbrand";
fs.warlock.seelenfeuer = "Seelenfeuer";
fs.warlock.shoot = "Schießen";

fs.warlock.ico_healthstone = "Interface\\Icons\\INV_Stone_04";
fs.warlock.ico_seelensplitter = "Interface\\Icons\\INV_Misc_Gem_Amethyst_02";

fs.warlock.isAllowed = {
    [fs.skull] = true,
    [fs.cross] = false,
    [fs.square] = false,
    [fs.moon] = false,
    [fs.triangle] = false,
    [fs.purple] = false,
    [fs.circle] = false,
    [fs.star] = false
}

fs.warlock.forbiddenMarks = {fs.cross, fs.square, fs.moon, fs.triangle, fs.purple, fs.circle, fs.start};
