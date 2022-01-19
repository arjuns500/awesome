-- Emits a signal (daemon::vol)
--	- Volume (either in string with percent or string "muted")

local awful = require("awful")
local gears = require("gears")
local naughty = require("naughty")

-- Emit signal whenever we detect change in vol
local old_vol = ""
local function emit_vol()
    awful.spawn.easy_async("pamixer --get-volume-human", function(out) 
        if (old_vol ~= out) then
            awesome.emit_signal("daemon::vol", out)
            old_vol = out
        end
    end)
end

emit_vol()

--- All code past this is from https://github.com/elenapan/dotfiles/blob/master/config/awesome/evil/volume.lua
-- Sleeps until pactl detects an event (volume up/down/toggle mute)
local volume_script = [[
    bash -c "
    LANG=C pactl subscribe 2> /dev/null | grep --line-buffered \"Event 'change' on sink #\"
    "]]


-- Kill old pactl subscribe processes
awful.spawn.easy_async({"pkill", "--full", "--uid", os.getenv("USER"), "^pactl subscribe"}, function ()
    -- Run emit_volume_info() with each line printed
    awful.spawn.with_line_callback(volume_script, {
        stdout = function(line)
            emit_vol()
        end
    })
end)
