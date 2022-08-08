-- https://www.hammerspoon.org/go/

--------------------------------------------------------------------------------

hs.window.animationDuration = 0

--------------------------------------------------------------------------------
-- Hammerspoon itself & Helper Utilities
require("meta")
require("utils")

--------------------------------------------------------------------------------

-- Base
require("scroll-and-cursor")
require("menubar")
require("system-and-cron")
require("window-management")
require("filesystem-watchers")
require("hot-corner-action")
require("usb-watchers")

-- app-specific
require("app-watchers")
require("discord")
require("twitterrific-iina")

--------------------------------------------------------------------------------
-- System Startup
gitDotfileSync("wake")
reloadAllMenubarItems()
killIfRunning("Finder") -- fewer items in the app switcher when Marta is used anyway

notify("Config reloaded")

--------------------------------------------------------------------------------


