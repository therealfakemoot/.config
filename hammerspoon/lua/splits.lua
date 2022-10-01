require("lua.utils")
require("lua.window-management")
--------------------------------------------------------------------------------

-- gets the Windows on the main screen, in order of the stack
function mainScreenWindows()
	local wins = hs.window.orderedWindows()
	local out = {}
	local j = 1
	local mainScreen
	-- safety net, since sometimes the projector is still regarded as mainscreen even though disconnected
	if isIMacAtHome() then mainScreen = iMacDisplay
	else mainScreen = hs.screen.mainScreen() end

	for i = 1, #wins do
		if wins[i]:screen() == mainScreen and wins[i]:isStandard() and wins[i]:isVisible() then
			out[j] = wins[i]
			j = j+1
		end
	end
	return out
end

-- if one of the two is activated, also activate the other
-- unsplit if one of the two windows has been closed
function pairedActivation(mode)
	if mode == "start" then
		local app1 = SPLIT_LEFT:application():name()
		local app2 = SPLIT_RIGHT:application():name()
		wf_pairedActivation = wf.new{app1, app2}
		wf_pairedActivation:subscribe(wf.windowFocused, function(focusedWin)
			-- not using :focus(), since that would cause infinite recursion
			-- raising needs small delay, so that focused window is already at front
			if focusedWin:id() == SPLIT_RIGHT:id() then
				runDelayed (0.02, function ()	SPLIT_LEFT:raise() end)
			elseif focusedWin:id() == SPLIT_LEFT:id() then
				runDelayed (0.02, function ()	SPLIT_RIGHT:raise() end)
			end
		end)
		wf_pairedActivation:subscribe(wf.windowDestroyed, function(closedWin)
			if not(SPLIT_LEFT) or not(SPLIT_RIGHT) or (SPLIT_RIGHT:id() == closedWin:id()) or (SPLIT_LEFT:id() == closedWin:id()) then
				vsplit("unsplit")
			end
		end)
	elseif mode == "stop" then
		if wf_pairedActivation then wf_pairedActivation:unsubscribeAll() end
		wf_pairedActivation = nil
		notify("Split terminated")
	end
end

function vsplit (mode)
	local noSplitActive
	if SPLIT_RIGHT and SPLIT_LEFT then
		noSplitActive = false
	else
		noSplitActive = true
	end

	if noSplitActive and (mode == "switch" or mode == "unsplit") then
		return
	end

	if mode == "split" and noSplitActive then
		local wins = mainScreenWindows()	-- to not split windows on second screen
		SPLIT_RIGHT = wins[1] -- save in global variables, so they are not garbage-collected
		SPLIT_LEFT = wins[2]
	end

	if (SPLIT_RIGHT:frame().x > SPLIT_LEFT:frame().x) then -- ensure that WIN_RIGHT is really the right
		local temp = SPLIT_RIGHT
		SPLIT_RIGHT = SPLIT_LEFT
		SPLIT_LEFT = temp
	end
	local f1 = SPLIT_RIGHT:frame()
	local f2 = SPLIT_LEFT:frame()

	if mode == "split" then
		pairedActivation("start")
		local max = hs.screen.mainScreen():frame()
		if (f1.w ~= f2.w or f1.w > 0.7*max.w) then
			f1 = hs.layout.left50
			f2 = hs.layout.right50
		else
			f1 = hs.layout.left70
			f2 = hs.layout.right30
		end
	elseif mode == "unsplit" then
		f1 = baseLayout
		f2 = baseLayout
		pairedActivation("stop")
	elseif mode == "switch" then
		if (f1.w == f2.w) then
			f1 = hs.layout.right50
			f2 = hs.layout.left50
		else
			f1 = hs.layout.right30
			f2 = hs.layout.left70
		end
	end

	moveResize(SPLIT_RIGHT, f1)
	moveResize(SPLIT_LEFT, f2)
	SPLIT_RIGHT:raise()
	SPLIT_LEFT:raise()
	runDelayed(0.2, function ()
		if SPLIT_RIGHT:application() then
			if SPLIT_RIGHT:application():name() == "Drafts" then toggleDraftsSidebar(SPLIT_RIGHT)
			elseif SPLIT_RIGHT:application():name() == "Obsidian" then toggleObsidianSidebar(SPLIT_RIGHT)
			elseif SPLIT_RIGHT:application():name() == "Highlights" then toggleHighlightsSidebar(SPLIT_RIGHT)
			end
		end
		if SPLIT_LEFT:application() then
			if SPLIT_LEFT:application():name() == "Drafts" then toggleDraftsSidebar(SPLIT_LEFT)
			elseif SPLIT_LEFT:application():name() == "Obsidian" then toggleObsidianSidebar(SPLIT_LEFT)
			elseif SPLIT_LEFT:application():name() == "Highlights" then toggleHighlightsSidebar(SPLIT_LEFT)
			end
		end
	end)

	if mode == "unsplit" then
		SPLIT_RIGHT = nil
		SPLIT_LEFT = nil
	end
end

--------------------------------------------------------------------------------
-- HOTKEYS
hotkey(hyper, "X", function() vsplit("switch") end)
hotkey(hyper, "C", function() vsplit("unsplit") end)
hotkey(hyper, "V", function() vsplit("split") end)
