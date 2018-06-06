
function fs_menu.priest.onLoad()
end

function fs_menu.priest.onShow()
    fs.printDebug("fs_menu.priest.onShow");
    this.onShow = 1;
    local name = this:GetName();
    this.onShow = nil;
end
