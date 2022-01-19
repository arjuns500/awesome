-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")

awful.screen.set_auto_dpi_enabled(true)

local xresources = beautiful.xresources
local dpi = xresources.apply_dpi

-- Load beautiful here.
beautiful.init("~/.config/awesome/themes/default/theme.lua")

-- Daemons
require("daemons")

-- load keyboard shortcuts
require("keys")


local vol_widget = require("components.widgets.volume")
local bat_widget = require("components.widgets.battery")

-- {{{ Error handling
-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Error",
                         text = tostring(err) })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions

-- This is used later as the default terminal and editor to run.
terminal = "wezterm"
editor = os.getenv("EDITOR") or "code"
editor_cmd = editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    awful.layout.suit.spiral.dwindle,
    -- awful.layout.suit.corner.ne,
    -- awful.layout.suit.corner.sw,
    -- awful.layout.suit.corner.se,
}
-- }}}

-- {{{ Menu
mypowermenu = wibox.widget{
	widget = wibox.container.background,
	shape = function(cr, w, h, r)
		return gears.shape.partially_rounded_rect(cr, w, h, true, false, false, true, r)
	end,
	bg = "#bf616a",
	{
		{
			text = "",
			font = "Material-Design-Iconic-Font 12",
			widget = wibox.widget.textbox
		},
		left = dpi(20),
		right = dpi(20),
		widget = wibox.container.margin,
	}
}


mypowermenu:connect_signal("button::press", function(c, _, _, button) 
	if button == 1 then
		awful.spawn.with_shell("~/.config/rofi/scripts/power-menu.sh")
	end
end)

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()

-- {{{ Wibar
-- Create a textclock widget
mytextclock = {
	{
		{
			format = "%a %b %d, %l:%M %p",
			widget = wibox.widget.textclock,
		},
		widget = wibox.container.margin,
		margins = dpi(10),
	},
	widget = wibox.container.background,
	shape = gears.shape.rounded_rect,
	bg = "#434c5e",
}

-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
awful.button({ }, 1, function(t) t:view_only() end),
awful.button({ modkey }, 1, function(t)
	if client.focus then
		client.focus:move_to_tag(t)
	end
end),
awful.button({ }, 3, awful.tag.viewtoggle),
awful.button({ modkey }, 3, function(t)
	if client.focus then
		client.focus:toggle_tag(t)
	end
end),
awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
)

local tasklist_buttons = gears.table.join(
awful.button({ }, 1, function (c)
	if c == client.focus then
		c.minimized = true
	else
		c:emit_signal(
		"request::activate",
		"tasklist",
		{raise = true}
		)
	end
end),
awful.button({ }, 3, function()
	awful.menu.client_list({ theme = { width = 250 } })
end),
awful.button({ }, 4, function ()
	awful.client.focus.byidx(1)
end),
awful.button({ }, 5, function ()
	awful.client.focus.byidx(-1)
end))

local function set_wallpaper(s)
	-- Wallpaper
	if beautiful.wallpaper then
		local wallpaper = beautiful.wallpaper
		-- If wallpaper is a function, call it with the screen
		if type(wallpaper) == "function" then
			wallpaper = wallpaper(s)
		end
		gears.wallpaper.maximized(wallpaper, s, true)
	end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)


-- Needed for taglist
function tablecontains(table, element)
	for _, value in pairs(table) do
		if value == element then
			return true
		end
	end
	return false
end

awful.screen.connect_for_each_screen(function(s)
	-- Wallpaper
	set_wallpaper(s)

	-- Each screen has its own tag table.
	awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.layouts[1])

	-- Create an imagebox widget which will contain an icon indicating which layout we're using.
	-- We need one layoutbox per screen.
	s.mylayoutbox = awful.widget.layoutbox(s)
	s.mylayoutbox:buttons(gears.table.join(
	awful.button({ }, 1, function () awful.layout.inc( 1) end),
	awful.button({ }, 3, function () awful.layout.inc(-1) end),
	awful.button({ }, 4, function () awful.layout.inc( 1) end),
	awful.button({ }, 5, function () awful.layout.inc(-1) end)))

	-- Create a taglist widget
	s.mytaglist = awful.widget.taglist {
		screen  = s,
		filter  = awful.widget.taglist.filter.all,
		buttons = taglist_buttons,
		widget_template = {
			{
				{
					{
						{
							{
								id     = 'index_role',
								visible = false,
								widget = wibox.widget.textbox,
							},
							margins = 13,
							widget  = wibox.container.margin,
						},
						bg     = '#5e81ac',
						shape  = gears.shape.circle,
						id     = "circle_bg",
						widget = wibox.container.background,
					},
					top = 10,
					bottom = 10,
					widget  = wibox.container.margin,
				},
				widget = wibox.container.margin
			},
			widget = wibox.container.background,
			-- Add support for hover colors and an index label
			create_callback = function(self, c3, index, objects) --luacheck: no unused args
				local sel_tags = awful.screen.focused().selected_tags
				if tablecontains(sel_tags, c3) then
					self:get_children_by_id('circle_bg')[1].bg = "#88c0d0"
				elseif #c3:clients() > 0 then
					self:get_children_by_id('circle_bg')[1].bg = "#ebcb8b"
				end
			end,
			update_callback = function(self, c3, index, objects) --luacheck: no unused args
				local sel_tags = awful.screen.focused().selected_tags
				if tablecontains(sel_tags, c3) then
					self:get_children_by_id('circle_bg')[1].bg = "#88c0d0"
				elseif #c3:clients() > 0 then
					self:get_children_by_id('circle_bg')[1].bg = "#ebcb8b"
				else
					self:get_children_by_id('circle_bg')[1].bg = "#5e81ac"
				end
			end
		},
	}

	-- Create a tasklist widget
	s.mytasklist = awful.widget.tasklist {
		screen  = s,
		filter  = awful.widget.tasklist.filter.currenttags,
		buttons = tasklist_buttons
	}

	-- Create the wibox
	s.mywibox = awful.wibar({ position = "bottom", screen = s, height = dpi(50) })
	s.systray = wibox.widget.systray()

	-- Add widgets to the wibox
	s.mywibox:setup {
		layout = wibox.container.margin,
		left = dpi(8),
		right = dpi(8),
		bottom = dpi(8),
		{
			layout = wibox.container.background,
			shape = gears.shape.rounded_rect,
			bg = "#2e3440",
			{
				layout = wibox.layout.align.horizontal,
				{ -- Left widgets
				layout = wibox.layout.fixed.horizontal,
				mypowermenu,
				s.mypromptbox,
			},
			wibox.layout.margin(s.mytaglist, 15, 15, 3, 3),
			{ -- Right widgets
			layout = wibox.layout.fixed.horizontal,
			wibox.widget.textbox(" "),
			wibox.layout.margin(vol_widget, 10, 10, 13, 13),
			wibox.widget.textbox(" "),
			wibox.layout.margin(bat_widget, 10, 15, 13, 13),
			mytextclock,
			wibox.layout.margin(wibox.widget.systray(), 15, 15, 11, 11),
		},
	}
}
	}

end)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
	-- All clients will match this rule.
	{ rule = { },
	properties = { border_width = beautiful.border_width,
	border_color = beautiful.border_normal,
	focus = awful.client.focus.filter,
	raise = true,
	keys = clientkeys,
	buttons = clientbuttons,
	screen = awful.screen.preferred,
	maximized = false,
	maximized_fullscreen = false,
	placement = awful.placement.no_offscreen,
}
	},

	-- Floating clients.
	{ rule_any = {
		instance = {
			"DTA",  -- Firefox addon DownThemAll.
			"copyq",  -- Includes session name in class.
			"pinentry",
		},
		class = {
			"Gpick",
			"Kruler",
			"MessageWin",  -- kalarm.
			"Sxiv",
			"Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
			"Wpa_gui",
			"veromix",
			"xtightvncviewer",
		},

		-- Note that the name property shown in xprop might be set slightly after creation of the client
		-- and the name shown there might not match defined rules here.
		name = {
			"Event Tester",  -- xev.
		},
		role = {
			"AlarmWindow",  -- Thunderbird's calendar.
			"ConfigManager",  -- Thunderbird's about:config.
			"pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
		}
	}, properties = {
		floating = true,
		ontop = true,
	}},

	-- Center and float dialogs
	{ rule_any = 
	{ type = { "dialog" }, class = { "Blueman-adapters" } }, 
	properties = { 
		titlebars_enabled = false,
		placement = awful.placement.centered,
		floating = true,
		ontop = true,
	},
},


{ rule_any = 
{ class = "xfce4-notifyd" },
properties = {
	ontop = true,
}
	},
	-- Set Firefox to always map on the tag named "2" on screen 1.
	-- { rule = { class = "Firefox" },
	--   properties = { screen = 1, tag = "2" } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
	-- Set the windows at the slave,
	-- i.e. put it at the end of others instead of setting it master.
	-- if not awesome.startup then awful.client.setslave(c) end

	if awesome.startup
		and not c.size_hints.user_position
		and not c.size_hints.program_position then
		-- Prevent clients from being unreachable after screen count changes.
		awful.placement.no_offscreen(c)
	end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
	-- buttons for the titlebar
	local buttons = gears.table.join(
	awful.button({ }, 1, function()
		c:emit_signal("request::activate", "titlebar", {raise = true})
		awful.mouse.client.move(c)
	end),
	awful.button({ }, 3, function()
		c:emit_signal("request::activate", "titlebar", {raise = true})
		awful.mouse.client.resize(c)
	end)
	)

	awful.titlebar(c):setup {
		{ -- Left
		awful.titlebar.widget.iconwidget(c),
		buttons = buttons,
		layout  = wibox.layout.fixed.horizontal
	},
	{ -- Middle
	{ -- Title
	align  = "center",
	widget = awful.titlebar.widget.titlewidget(c)
},
buttons = buttons,
layout  = wibox.layout.flex.horizontal
		},
		{ -- Right
		awful.titlebar.widget.maximizedbutton(c),
		awful.titlebar.widget.closebutton    (c),
		layout = wibox.layout.fixed.horizontal()
	},
	layout = wibox.layout.align.horizontal
}
end)
-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
	c:emit_signal("request::activate", "mouse_enter", {raise = false})
end)

client.connect_signal("request::activate", function(c)
	c.first_tag:view_only()
	c.minimized = false
	client.focus = c
end)

-- }}}
