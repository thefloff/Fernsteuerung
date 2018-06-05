fs = {};

-- vars for keybindings;
BINDING_HEADER_FS_HEADER = "Fernsteuerung";
BINDING_NAME_FS_PRIMARY = "Do Primary Action";
BINDING_NAME_FS_SECONDARY = "Do Secondary Action";
BINDING_NAME_FS_TERTIARY = "Do Tertiary Action";
BINDING_NAME_FS_MENU = "Show Menu";

-- Icons relevant for all classes --
fs.ico_drink = "Interface\\Icons\\INV_Drink_18";
fs.ico_eat = "Interface\\Icons\\INV_Misc_Food_33";

-- Characters --
fs.playerControlled = "Insert Player Character Name here!";
fs.characterClass = "None";

-- Raid Targets --
fs.skull = 8;
fs.cross = 7;
fs.square = 6;
fs.moon = 5;
fs.triangle = 4;
fs.purple = 3;
fs.circle = 2;
fs.star = 1;

fs.markerNames = {
	[fs.skull] = "Skull",
	[fs.cross] = "Cross",
	[fs.square] = "Square",
	[fs.moon] = "Moon",
	[fs.triangle] = "Triangle",
	[fs.purple] = "Purple",
	[fs.circle] = "Circle",
	[fs.star] = "Star"
}

-- Other --
fs.debug = true;
