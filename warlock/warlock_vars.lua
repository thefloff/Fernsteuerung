warlock = {};

warlock.lastElemBuff = 0;

warlock.dot_fluchDerPein = "Interface\\Icons\\Spell_Shadow_CurseOfSargeras";
warlock.dot_verderbnis = "Interface\\Icons\\Spell_Shadow_AbominationExplosion";
warlock.dot_feuerbrand = "Interface\\Icons\\Spell_Fire_Immolation";
warlock.dot_lebensentzug = "Interface\\Icons\\Spell_Shadow_Requiem";
warlock.buff_daemonenruestung = "Interface\\Icons\\Spell_Shadow_RagingScream";
warlock.debuff_sheep = "Interface\\Icons\\Spell_Nature_Polymorph";
warlock.debuff_fde = "Interface\\Icons\\Spell_Shadow_ChillTouch";
warlock.debuff_fear = "Interface\\Icons\\Spell_Shadow_Possession";

warlock.fluchDerPein = "Fluch der Pein";
warlock.fluchVerstaerken = "Fluch verstärken";
warlock.verderbnis = "Verderbnis";
warlock.feuerbrand = "Feuerbrand";
warlock.lebensentzug = "Lebensentzug";
warlock.schattenblitz = "Schattenblitz";
warlock.furcht = "Furcht";
warlock.drainMana = "Mana entziehen";
warlock.seelendieb = "Seelendieb";
warlock.createHealthstone = "Gesundheitsstein herstellen";
warlock.blutsauger = "Blutsauger";
warlock.summonMount = "Teufelsross beschwören";
warlock.summonImp = "Wichtel beschwören";
warlock.daemonenruestung = "Dämonenrüstung";
warlock.todesmantel = "Todesmantel";
warlock.fluchDerElemente = "Fluch der Elemente";
warlock.schattenbrand = "Schattenbrand";
warlock.seelenfeuer = "Seelenfeuer";

warlock.slt_feuerbrand = 1;
warlock.slt_fluchVerstaerken = 5;
warlock.slt_zauberstab = 61;
warlock.slt_seelenfeuer = 64;
warlock.slt_schattenbrand = 65;
warlock.slt_todesmantel = 68;

warlock.ico_healthstone = "Interface\\Icons\\INV_Stone_04";
warlock.ico_seelensplitter = "Interface\\Icons\\INV_Misc_Gem_Amethyst_02";

warlock.isAllowed = {
    [fs.skull] = true,
    [fs.cross] = false,
    [fs.square] = false,
    [fs.moon] = false,
    [fs.triangle] = false,
    [fs.purple] = false,
    [fs.circle] = false,
    [fs.star] = false
}

warlock.forbiddenMarks = {fs.cross, fs.square, fs.moon, fs.triangle, fs.purple, fs.circle, fs.start};
