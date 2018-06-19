fs.heal = {}
-- heal heuristic values
fs.heal.timeFrameAvgDmg = 5.5; --timeframe with which the average DMG is calculated in seconds
fs.heal.additionalAvgDmg = 30; --additional dmg/s that is added in any case as a buffer and to help the heal heuristic work when no DMG was taken shortly
fs.heal.buffer = 500; -- static HP buffer value used in secondsToDie calculation

-- never heal characters with this names
fs.heal.targetBlackList = {} -- todo: fill this from settings

-- - list of effects able to decurse:
--     - icon (to identify)
--     - type (curse, magic, poison)
--     - priority
--         - high   - do it before anything else
--         - medium - do it when nobody is going to die in the next 5 seconds
--         - low    - do when nothing else is to do
fs.heal.decurseWhiteList = {
	["DummyDecurse"] = {
		["icon"] = "iconPath",
		["type"] = "curse", -- possible values "curse", "magic", "poison"
		["priority"] = "low", -- possible values "low", "medium", "high"
	}
}

-- actuall spell cast, set when a spell cast begins. Data used to send a HEAL, STOPHEAL or DELAYHEAL addon message
fs.heal.actSpellCast = nil;