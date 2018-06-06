
function fs_menu.warlock.onLoad()
end

function fs_menu.warlock.onShow()
    fs.printDebug("fs_menu.warlock.onShow");
    this.onShow = 1;
    local name = this:GetName();
    this.onShow = nil;
end
