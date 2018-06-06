
-- define functions to call for different classes.
fs.primaryActions = {
    ["Hexenmeister"] = warlock.primaryAction,
    ["Warlock"] = warlock.primaryAction,
    ["Priester"] = priest.primaryAction,
    ["Priest"] = priest.primaryAction,
    ["None"] = function() fs.printError("ERROR: character class not found!"); end
}
fs.secondaryActions = {
    ["Hexenmeister"] = warlock.secondaryAction,
    ["Warlock"] = warlock.secondaryAction,
    ["Priester"] = priest.secondaryAction,
    ["Priest"] = priest.secondaryAction,
    ["None"] = function() fs.printError("ERROR: character class not found!"); end
}
fs.tertiaryActions = {
    ["Hexenmeister"] = warlock.tertiaryAction,
    ["Warlock"] = warlock.tertiaryAction,
    ["Priester"] = priest.tertiaryAction,
    ["Priest"] = priest.tertiaryAction,
    ["None"] = function() fs.printError("ERROR: character class not found!"); end
}

-- called on load
function fs.load()
	getglobal("ChatFrame1"):AddMessage("Loading Fernsteuerung");
    fs.characterClass = UnitClass("player");
    getglobal("ChatFrame1"):AddMessage(" -- Character Class: "..fs.characterClass);
end

-- bound to keys
function fs.primaryAction()
	fs.printDebug("fs.primaryAction");
    if fs.playerControlled == "None" then fs.playerControlled = playerControlled; end
    if fs.playerControlled == nil then fs.printError("ERROR: No Character set to support!"); end
    fs.primaryActions[fs.characterClass]();
end
function fs.secondaryAction()
    if fs.playerControlled == "None" then fs.playerControlled = playerControlled; end
    if fs.playerControlled == nil then fs.printError("ERROR: No Character set to support!"); end
    fs.printDebug("fs.secondaryAction");
    fs.secondaryActions[fs.characterClass]();
end
function fs.tertiaryAction()
    if fs.playerControlled == "None" then fs.playerControlled = playerControlled; end
    if fs.playerControlled == nil then fs.printError("ERROR: No Character set to support!"); end
    fs.printDebug("fs.tertiaryAction");
    fs.tertiaryActions[fs.characterClass]();
end
function fs.showMenu()
    fs.printDebug("fs.showMenu");
    if FSOptions then
        fs.printDebug("FSOptions exists");
        FSOptions:Show();
    end
end