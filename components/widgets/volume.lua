local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local naughty = require("naughty")
local Mediakeys = require("components.media_keys")

vol_bar = wibox.widget.progressbar()

vol_widget =
	wibox.widget {
    	max_value = 1,
    	forced_width = 100,
		shape = gears.shape.rounded_bar,
		bar_shape = gears.shape.rounded_bar,
		border_width = 0,
		widget = vol_bar,
		background_color = "#00000044",
		color = {
            type = "linear",
            from = { 0, 0 },
            to = { 100, 0 },
            stops = { {0, "#BF616A"}, {1, "#EBCB8B"}}
        },
	}

vol_widget:connect_signal("button::press", function(_, _, _, button)
	if button == 1 then
		awful.spawn.raise_or_spawn("pavucontrol")
    elseif button == 4 then
        Mediakeys:set_vol("-i 5 -u")
    elseif button == 5 then
        Mediakeys:set_vol("-d 5 -u")
    end
end)

awesome.connect_signal("daemon::vol", function(status)
	local volume = status:gsub("\n", "")
	if volume ~= "muted" then
		local vol = tonumber(volume:sub(1, -2))
		vol_bar:set_value(vol and (vol / 100) or 0)
	else
		vol_bar:set_value(0)
	end
end)

return vol_widget
