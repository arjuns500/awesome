local awful = require"awful"
local wibox = require"wibox"
local gears = require"gears"
local naughty = require"naughty"

bat_bar = wibox.widget.progressbar()

bat_widget =
	wibox.widget {
    	max_value = 1,
    	forced_width = 100,
		shape = gears.shape.rounded_bar,
		bar_shape = gears.shape.rounded_bar,
		border_width = 0,
		widget = bat_bar,
		background_color = "#00000044",
		color = {
            type = "linear",
            from = { 0, 0 },
            to = { 100, 0 },
            stops = { {0, "#A3BE8C"}, {0.35, "#88C0D0"}, {1, "#B48EAD"}}
        }
    }

batwidget_t = awful.tooltip {}
batwidget_t:add_to_object(bat_widget)

bat_widget:connect_signal('mouse::enter', function()
		awful.spawn.easy_async("acpi", function(stdout)
				batwidget_t.text = string.gsub(stdout, "\n", "")
		end)
		return 'Loading...'
end)

awesome.connect_signal("daemon::battery", function(capacity, _)
	bat_widget:set_value(tonumber(capacity) / 100)
end)

return bat_widget
