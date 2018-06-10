-- heal heuristic values
fs.timeFrameAvgDmg = 5.5; --timeframe with which the average DMG is calculated in seconds
fs.additionalAvgDmg = 30; --additional dmg/s that is added in any case as a buffer and to help the heal heuristic work when no DMG was taken shortly
fs.healBuffer = 500; -- static HP buffer value used in secondsToDie calculation
fs.healTargetBlackList = {} -- nerver heal these characters