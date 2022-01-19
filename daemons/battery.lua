-- Emits a signal (daemon::battery)
--		- Plugged In
-- 		- Battery state

local awful = require("awful")
local gears = require("gears")

local function emit_bat_signal()
	awful.spawn.easy_async("cat /sys/class/power_supply/BAT0/capacity", function(capacity) 
		awful.spawn.easy_async("cat /sys/class/power_supply/BAT0/status", function(status) 
			awesome.emit_signal("daemon::battery", capacity, status)
		end) 
	end) 
end

emit_bat_signal()

gears.timer.start_new(61, function()
	emit_bat_signal()
	return true
end)