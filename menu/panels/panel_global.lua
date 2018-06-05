
function fs_menu.global.onLoad()
end

function fs_menu.global.onShow()
    fs.printDebug("fs_menu.global.onShow");
    this.onShow = 1;
    local name = this:GetName();
    getglobal(name .. "Debug"):Show();
    getglobal(name .. "Debug"):SetChecked(fs.debug);
    this.onShow = nil;
end

function fs_menu.global.playerNameChanged(name)
    fs.printDebug("fs_emnu.global.playerNameChanges("..name..")");
    fs.setPlayerName(name);
end

function fs_menu.global.setDebugMode(newSetting)
    fs.debug = newSetting;
    debug = newSetting;
end