
local currentFrameName = "Global";

function fs_menu.onLoad()
	getglobal("FSOptions"):Hide();
end

function fs_menu.onShow()
	fs.printDebug("fs_menu.onShow");
	local currentFrame = getglobal("FSOptionsPanel" .. currentFrameName);
	if not currentFrame:IsShown() then
		fs.printDebug("FSOptionsPanel<active> not shown");
		currentFrame:Show()
		getglobal("FSOptionsMenu" .. currentFrameName):LockHighlight();
	end
end

function fs_menu.switchTab(newFrameName)
	fs.printDebug("switchTab("..newFrameName..")");
	if newFrameName ~= currentFrameName and getglobal("FSOptionsPanel" .. newFrameName) then
		this:LockHighlight();
		getglobal("FSOptionsMenu" .. currentFrameName):UnlockHighlight();
		getglobal("FSOptionsPanel" .. currentFrameName):Hide();
		getglobal("FSOptionsPanel" .. newFrameName):Show();
		currentFrameName = newFrameName;
	end
end