hyper = {"cmd", "alt", "ctrl", "shift"}
hotkey = hs.hotkey.bind
alert = hs.alert.show
keystroke = hs.eventtap.keyStroke
aw = hs.application.watcher
wf = hs.window.filter
app = hs.application
applescript = hs.osascript.applescript
uriScheme = hs.urlevent.bind
pw = hs.pathwatcher.new
I = hs.inspect -- to inspect tables in the console

--------------------------------------------------------------------------------

home = os.getenv("HOME")

---trims whitespace from string
---@param str string
---@return string
function trim(str)
	if not(str) then return "" end
	return (str:gsub("^%s*(.-)%s*$", "%1"))
end

--------------------------------------------------------------------------------

---Repeat a Function multiple times
---@param delaySecs number|table<number>
---@param func function function to repeat
function runWithDelays(delaySecs, func)
	if type(delaySecs) == "number" then delaySecs = {delaySecs} end
	for _, delay in pairs(delaySecs) do
		hs.timer.doAfter(delay, func)
	end
end

---@return boolean
function isProjector()
	local mainDisplayName = hs.screen.primaryScreen():name()
	local projectorHelmholtz = mainDisplayName == "ViewSonic PJ"
	local tvLeuthinger = mainDisplayName == "TV_MONITOR"
	return projectorHelmholtz or tvLeuthinger
end

---@return boolean
function isAtOffice()
	local mainDisplayName = hs.screen.primaryScreen():name()
	local screenOne = mainDisplayName == "HP E223"
	local screenTwo = mainDisplayName == "Acer CB241HY"
	return screenOne or screenTwo
end

---@return boolean
function screenIsUnlocked()
	local _, success = hs.execute('[[ "$(/usr/libexec/PlistBuddy -c "print :IOConsoleUsers:0:CGSSessionScreenIsLocked" /dev/stdin 2>/dev/null <<< "$(ioreg -n Root -d1 -a)")" != "true" ]] && exit 0 || exit 1')
	return success ---@diagnostic disable-line: return-type-mismatch
end

---@return string
function deviceName()
	-- similar to `scutil --get ComputerName`, only native to hammerspoon and therefore a bit more reliable
	local name, _ = hs.host.localizedName():gsub(".- ", "", 1)
	return name
end

---@return boolean
function isAtMother()
	if deviceName():find("Mother") then
		return true
	end
	return false
end

---@return boolean
function isIMacAtHome()
	if deviceName():find("iMac") and deviceName():find("Home") then
		return true
	end
	return false
end

---Send Notification
---@param text string
function notify(text)
	if text then
		text = trim(text)
	else
		text = "empty string"
	end
	hs.notify.new {title = "Hammerspoon", informativeText = text}:send()
	print("notify: " .. text) -- for the console
end

---Whether the current time is between start & end
---@param startHour integer 13.5 = 13:30
---@param endHour integer
---@return boolean
function betweenTime(startHour, endHour)
	local currentHour = hs.timer.localTime() / 60 / 60
	return currentHour > startHour and currentHour < endHour
end

---name of frontapp
---@return string
function frontAppName()
	return hs.application.frontmostApplication():name() ---@diagnostic disable-line: return-type-mismatch
end

---Check whether app is running
---@param appName string
---@return boolean
function appIsRunning(appName)
	-- can't use ":isRunning()", since the application object is nil when it
	-- wasn't running before
	local runs = hs.application.get(appName)
	if runs then return true end
	return false
end

---Open App
---@param appName string
function openIfNotRunning(appName)
	local runs = hs.application.get(appName)
	if runs then return end
	hs.application.open(appName)
end

---@param appName string
function killIfRunning(appName)
	local runs = hs.application.get(appName)
	if runs then runs:kill() end
	hs.timer.doAfter(1, function()
		runs = hs.application.get(appName)
		if runs then runs:kill9() end
	end)
end

-- won't work with Chromium browsers due to bug
---@param url string
function openLinkInBackground(url)
	hs.execute('open -g "' .. url .. '"')
end
