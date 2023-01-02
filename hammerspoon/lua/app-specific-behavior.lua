require("lua.utils")
require("lua.window-management")
require("lua.system-and-cron")
--------------------------------------------------------------------------------

local function unHideAll()
	local wins = hs.window.allWindows() -- using `allWindows`, since `orderedWindows` only lists visible windows
	for _, win in pairs(wins) do
		local app = win:application()
		if app and app:isHidden() then app:unhide() end
	end
end

transBgAppWatcher = aw.new(function(appName, eventType, appObject)
	local appsWithTransparency = {
		"neovide",
		"Neovide",
		"Obsidian",
		"alacritty",
		"Alacritty",
	}
	if not tableContains(appsWithTransparency, appName) then return end

	if eventType == aw.activated or eventType == aw.launched then
		-- some apps like neovide do not set a "launched" signal, so the delayed
		-- hiding is used for it activation as well
		runWithDelays({ 0, 0.1 }, function()
			local win = appObject:mainWindow()
			if checkSize(win, pseudoMaximized) or checkSize(win, maximized) then
				appObject:selectMenuItem("Hide Others")
			end
		end)
	elseif eventType == aw.terminated then
		unHideAll()
	end
end):start()

---automatically apply per-app auto-tiling of the windows of the app
---@param windowSource hs.window.filter|string windowFilter OR string representing app name
local function autoTile(windowSource)
	---necessary b/c windowfilter is null when not triggered via
	---windowfilter-subscription-event. This check allows for using app names,
	---which enables using the autotile-function e.g. within app watchers
	---@param _windowSource hs.window.filter|string windowFilter OR string representing app name
	---@return hs.window[]
	local function getWins(_windowSource)
		if type(_windowSource) == "string" then
			return app(_windowSource):allWindows()
		else
			return _windowSource:getWindows()
		end
	end
	local wins = getWins(windowSource)

	if #wins == 0 and frontAppName() == "Finder" then
		-- prevent quitting when window is created imminently
		runWithDelays(0.2, function()
			-- INFO: quitting Finder requires `defaults write com.apple.finder QuitMenuItem -bool true`
			-- getWins() again to check if window count has changed in the meantime
			if #getWins(windowSource) == 0 then app("Finder"):kill() end
		end)
	elseif #wins == 1 then
		if isProjector() then
			moveResize(wins[1], maximized)
		elseif frontAppName() == "Finder" then
			moveResize(wins[1], centered)
		else
			moveResize(wins[1], baseLayout)
		end
	elseif #wins == 2 then
		moveResize(wins[1], leftHalf)
		moveResize(wins[2], rightHalf)
	elseif #wins == 3 then
		moveResize(wins[1], { h = 1, w = 0.33, x = 0, y = 0 })
		moveResize(wins[2], { h = 1, w = 0.34, x = 0.33, y = 0 })
		moveResize(wins[3], { h = 1, w = 0.33, x = 0.67, y = 0 })
	elseif #wins == 4 then
		moveResize(wins[1], { h = 0.5, w = 0.5, x = 0, y = 0 })
		moveResize(wins[2], { h = 0.5, w = 0.5, x = 0, y = 0.5 })
		moveResize(wins[3], { h = 0.5, w = 0.5, x = 0.5, y = 0 })
		moveResize(wins[4], { h = 0.5, w = 0.5, x = 0.5, y = 0.5 })
	elseif #wins == 5 then
		moveResize(wins[1], { h = 0.5, w = 0.5, x = 0, y = 0 })
		moveResize(wins[2], { h = 0.5, w = 0.5, x = 0, y = 0.5 })
		moveResize(wins[3], { h = 0.5, w = 0.5, x = 0.5, y = 0 })
		moveResize(wins[4], { h = 0.5, w = 0.5, x = 0.5, y = 0.5 })
		moveResize(wins[5], { h = 0.5, w = 0.5, x = 0.25, y = 0.25 })
	elseif #wins == 6 then
		moveResize(wins[1], { h = 0.5, w = 0.33, x = 0, y = 0 })
		moveResize(wins[2], { h = 0.5, w = 0.33, x = 0, y = 0.5 })
		moveResize(wins[3], { h = 0.5, w = 0.34, x = 0.33, y = 0 })
		moveResize(wins[4], { h = 0.5, w = 0.34, x = 0.33, y = 0.5 })
		moveResize(wins[5], { h = 0.5, w = 0.33, x = 0.67, y = 0 })
		moveResize(wins[6], { h = 0.5, w = 0.33, x = 0.67, y = 0.5 })
	end
end

local function bringAllToFront() app.frontmostApplication():selectMenuItem { "Window", "Bring All to Front" } end

--------------------------------------------------------------------------------

-- PIXELMATOR
pixelmatorWatcher = aw.new(function(appName, eventType, appObj)
	if appName == "Pixelmator" and eventType == aw.launched then
		runWithDelays(0.3, function() moveResize(appObj, maximized) end)
	end
end):start()

--------------------------------------------------------------------------------

-- SPOTIFY
---play/pause spotify with spotifyTUI
---@param toStatus string pause|play
local function spotifyTUI(toStatus)
	local currentStatus = hs.execute(
		"export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH ; spt playback --status --format=%s"
	)
	currentStatus = trim(currentStatus) ---@diagnostic disable-line: param-type-mismatch
	if
		(currentStatus == "▶️" and toStatus == "pause") or (currentStatus == "⏸" and toStatus == "play")
	then
		local stdout = hs.execute(
			"export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH ; spt playback --toggle"
		)
		if toStatus == "play" then notify(stdout) end ---@diagnostic disable-line: param-type-mismatch
	end
end

-- auto-pause Spotify on launch of apps w/ sound
-- auto-resume Spotify on quit of apps w/ sound
spotifyAppWatcher = aw.new(function(appName, eventType)
	if isProjector() then return end -- never start music when on projector
	local appsWithSound = { "YouTube", "zoom.us", "FaceTime", "Twitch", "Netflix" }
	if tableContains(appsWithSound, appName) then
		if eventType == aw.launched then
			spotifyTUI("pause")
		elseif eventType == aw.terminated then
			spotifyTUI("play")
		end
	end
end):start()

--------------------------------------------------------------------------------

-- BRAVE BROWSER
-- split when second window is opened
-- change sizing back, when back to one window
wf_browser = wf.new("Brave Browser")
	:setOverrideFilter({
		rejectTitles = { " %(Private%)$", "^Picture in Picture$", "^Task Manager$" },
		allowRoles = "AXStandardWindow",
		hasTitlebar = true,
	})
	:subscribe(wf.windowCreated, function() autoTile(wf_browser) end)
	:subscribe(wf.windowDestroyed, function() autoTile(wf_browser) end)
	:subscribe(wf.windowFocused, bringAllToFront)

-- Automatically hide Browser has when no window
-- requires wider window-filter to not hide PiP windows etc
wf_browser_all = wf.new("Brave Browser")
	:setOverrideFilter({ allowRoles = "AXStandardWindow" })
	:subscribe(wf.windowDestroyed, function()
		if #wf_browser_all:getWindows() == 0 then app("Brave Browser"):hide() end
	end)

--------------------------------------------------------------------------------

-- MIMESTREAM
-- split when second window is opened
-- change sizing back, when back to one window
wf_mimestream = wf.new("Mimestream")
	:setOverrideFilter({
		allowRoles = "AXStandardWindow",
		rejectTitles = {
			"General",
			"Accounts",
			"Sidebar & List",
			"Viewing",
			"Composing",
			"Templates",
			"Signatures",
			"Labs",
			"Updating Mimestream",
			"Software Update",
		},
	})
	:subscribe(wf.windowCreated, function() autoTile(wf_mimestream) end)
	:subscribe(wf.windowDestroyed, function() autoTile(wf_mimestream) end)
	:subscribe(wf.windowFocused, bringAllToFront)

--------------------------------------------------------------------------------

-- IINA: Full Screen when on projector
iinaAppLauncher = aw.new(function(appName, eventType, appObject)
	if eventType == aw.launched and appName == "IINA" and isProjector() then
		-- going full screen needs a small delay
		runWithDelays({ 0.05, 0.2 }, function() appObject:selectMenuItem { "Video", "Enter Full Screen" } end)
	end
end):start()

--------------------------------------------------------------------------------
-- TWITTERRIFIC

-- keep visible, when active window is pseudomaximized
-- scroll up on launch
twitterificVisible = aw.new(function(appName, eventType)
	if appName == "Twitterrific" and eventType == aw.launched then
		runWithDelays(1, function() twitterrificAction("scrollup") end)
	elseif appIsRunning("Twitterrific") and (eventType == aw.activated or eventType == aw.launching) then
		local currentWin = hs.window.focusedWindow()
		if checkSize(currentWin, pseudoMaximized) then app("Twitterrific"):mainWindow():raise() end
	end
end):start()

--------------------------------------------------------------------------------

-- NEOVIM / NEOVIDE
wf_neovim = wf
	.new({ "neovide", "Neovide" })
	-- required, since window size saving is sometimes ignored by Neovide :/
	:subscribe(
		wf.windowCreated,
		function(newWin)
			runWithDelays({ 0.2, 0.4, 0.6 }, function()
				local size = isProjector() and maximized or baseLayout
				moveResize(newWin, size)
			end)
		end
	)
	-- HACK bugfix for: https://github.com/neovide/neovide/issues/1595
	:subscribe(
		wf.windowDestroyed,
		function()
			if #wf_neovim:getWindows() == 0 then
				runWithDelays(5, function() hs.execute("pgrep neovide || killall nvim") end)
			end
		end
	)

--------------------------------------------------------------------------------

-- ALACRITTY
-- pseudomaximized window
wf_alacritty = wf.new({ "alacritty", "Alacritty" }):subscribe(wf.windowCreated, function(newWin)
	if isProjector() then return end -- has it's own layouting already
	moveResize(newWin, baseLayout)
end)

-- Man leader hotkey (for Karabiner)
-- work around necessary, cause alacritty creates multiple instances, i.e.
-- multiple applications all with the name "alacritty", preventing conventional
-- methods for focussing a window via AppleScript or `open`
uriScheme("focus-help", function()
	local win = hs.window.find("man:")
	if win then
		win:focus()
	else
		notify("None open.")
	end
end)

-- btop leader hotkey (for Karabiner and Alfred)
-- work around necessary, cause alacritty creates multiple instances, i.e.
-- multiple applications all with the name "alacritty", preventing conventional
-- methods for focussing a window via AppleScript or `open`
uriScheme("focus-btop", function()
	local win = hs.window.find("btop")
	if win then
		win:focus()
	else
		-- starting with smaller font be able to read all processes
		local out, success = hs.execute([[
			export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH
			if ! command -v btop &>/dev/null; then exit 1 ; fi
			alacritty --option="font.size=20" --option="colors.primary.background='#000000'" --title="btop" --command btop
		]])
		if not success then notify("⚠️ btop not installed") end
	end
end)

--------------------------------------------------------------------------------

-- FINDER
wf_finder = wf.new("Finder")
	:setOverrideFilter({
		rejectTitles = { "^Move$", "^Bin$", "^Copy$", "^Finder Settings$", " Info$", "^$" }, -- "^$" excludes the Desktop, which has no window title
		allowRoles = "AXStandardWindow",
		hasTitlebar = true,
	})
	:subscribe(wf.windowCreated, function() autoTile(wf_finder) end)
	:subscribe(wf.windowDestroyed, function() autoTile(wf_finder) end)

finderAppWatcher = aw.new(function(appName, eventType, finderAppObj)
	if not (appName == "Finder") then return end

	if eventType == aw.activated then
		autoTile("Finder") -- also triggered via app-watcher, since windows created in the bg do not always trigger window filters
		bringAllToFront()
		finderAppObj:selectMenuItem { "View", "Hide Sidebar" }

	-- quit Finder if it was started as a helper (e.g., JXA), but has no window
	elseif eventType == aw.launched then
		-- INFO delay shouldn't be lower than 2-3s, otherwise other scripts cannot
		-- properly utilize Finder
		runWithDelays({ 3, 5, 10 }, function()
			if finderAppObj and not (finderAppObj:mainWindow()) then finderAppObj:kill() end
		end)
	end
end):start()

--------------------------------------------------------------------------------

-- ZOOM
-- close first window, when second is open
-- don't leave browser tab behind when opening zoom
wf_zoom = wf.new("zoom.us"):subscribe(wf.windowCreated, function()
	applescript([[
			tell application "Brave Browser"
				set window_list to every window
				repeat with the_window in window_list
					set tab_list to every tab in the_window
					repeat with the_tab in tab_list
						set the_url to the url of the_tab
						if the_url contains ("zoom.us") then close the_tab
					end repeat
				end repeat
			end tell
		]])
	local numberOfZoomWindows = #wf_zoom:getWindows()
	if numberOfZoomWindows == 2 then
		runWithDelays({ 1, 2 }, function() app("zoom.us"):findWindow("^Zoom$"):close() end)
	end
end)

--------------------------------------------------------------------------------

-- HIGHLIGHTS
-- - Sync Dark & Light Mode
-- - Start with Highlight as Selection
highlightsAppWatcher = aw.new(function(appName, eventType, appObject)
	if not (eventType == aw.launched and appName == "Highlights") then return end

	local targetView = "Default"
	if isDarkMode() then targetView = "Night" end
	appObject:selectMenuItem { "View", "PDF Appearance", targetView }

	-- pre-select yellow highlight tool & hide toolbar
	appObject:selectMenuItem { "Tools", "Highlight" }
	appObject:selectMenuItem { "Tools", "Color", "Yellow" }
	appObject:selectMenuItem { "View", "Hide Toolbar" }

	moveResize(appObject:mainWindow(), baseLayout)
end):start()

--------------------------------------------------------------------------------

-- DRAFTS
-- - Hide Toolbar
-- - set workspace
draftsWatcher = aw.new(function(appName, eventType, appObject)
	if not (appName == "Drafts") then return end

	if eventType == aw.launching or eventType == aw.activated then
		local workspace = isAtOffice() and "Office" or "Home"
		runWithDelays({ 0.2 }, function()
			local name = appObject:focusedWindow():title()
			local isTaskList = name:find("Supermarkt$") or name:find("Drogerie$")
			if not isTaskList then appObject:selectMenuItem { "Workspaces", workspace } end
			appObject:selectMenuItem { "View", "Hide Toolbar" }
		end)
	end
end):start()

--------------------------------------------------------------------------------
-- SCRIPT EDITOR
-- - auto-paste and lint content
-- - skip new file creaton dialog
wf_script_editor = wf.new("Script Editor"):subscribe(wf.windowCreated, function(newWin)
	if newWin:title() == "Open" then
		keystroke({ "cmd" }, "n")
		runWithDelays(0.2, function()
			keystroke({ "cmd" }, "v")
			local win = app("Script Editor"):mainWindow() -- cannot use newWin, since it's the open dialog
			moveResize(win, centered)
		end)
		runWithDelays(0.4, function() keystroke({ "cmd" }, "k") end)
	end
end)

--------------------------------------------------------------------------------

-- DISCORD
discordAppWatcher = aw.new(function(appName, eventType)
	if appName ~= "Discord" then return end

	-- on launch, open OMG Server instead of friends (who needs friends if you have Obsidian?)
	if eventType == aw.launched then
		openLinkInBackground("discord://discord.com/channels/686053708261228577/700466324840775831")
	end

	-- when focused, enclose URL in clipboard with <>
	-- when unfocused, removes <> from URL in clipboard
	local clipb = hs.pasteboard.getContents()
	if not clipb then return end

	if eventType == aw.activated then
		local hasURL = clipb:match("^https?:%S+$")
		local hasObsidianURL = clipb:match("^obsidian:%S+$")
		local isTweet = clipb:match("^https?://twitter%.com") -- for tweets, the previews are actually useful
		if (hasURL or hasObsidianURL) and not isTweet then hs.pasteboard.setContents("<" .. clipb .. ">") end
	elseif eventType == aw.deactivated then
		local hasEnclosedURL = clipb:match("^<https?:%S+>$")
		local hasEnclosedObsidianURL = clipb:match("^<obsidian:%S+>$")
		if hasEnclosedURL or hasEnclosedObsidianURL then
			clipb = clipb:sub(2, -2) -- remove first & last character
			hs.pasteboard.setContents(clipb)
		end
	end
end):start()

--------------------------------------------------------------------------------

-- SHOTTR
-- Auto-select Arrow-Tool on start
wf_shottr = wf.new("Shottr"):subscribe(wf.windowCreated, function(newWindow)
	if newWindow:title() == "Preferences" then return end
	runWithDelays(0.1, function() keystroke({}, "a") end)
end)

--------------------------------------------------------------------------------

-- WARP
-- since window size saving & session saving is not separated
warpWatcher = aw.new(function(appName, eventType)
	if appName == "Warp" and eventType == aw.launched then
		keystroke({ "cmd" }, "k") -- clear
	end
end):start()
