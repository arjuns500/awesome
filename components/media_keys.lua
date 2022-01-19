local naughty = require("naughty")
local awful = require("awful")

Mediakeys = {}

function Mediakeys:set_vol(change)
  awful.spawn("pamixer " .. change, false)

  awful.spawn.easy_async("pamixer --get-volume-human", function(volume) 
    if self.vol_notif then
      local vol = string.gsub(volume, "\n", "")
      naughty.replace_text(
        self.vol_notif, 
        nil, 
        "Volume: " .. vol
      )
    else
      local vol = string.gsub(volume, "\n", "")
      self.vol_notif = naughty.notify {
        text = "Volume: " .. vol,
        destroy = function (n)
          self.vol_notif = nil
        end
      }
    end
  end)
end
  
function Mediakeys:set_brightness(change)
  awful.spawn("light " .. change, false)

  awful.spawn.easy_async_with_shell("printf '%.0f\n' `light -G`", function(brightness) 
    if self.brightness_notif then
      naughty.replace_text(
        self.brightness_notif, 
        nil, 
        "Brightness: " .. string.format("%d", brightness) .. "%"
      )
    else
      self.brightness_notif = naughty.notify {
        text = "Brightness: " .. string.format("%d", brightness) .. "%",
        destroy = function (n)
          self.brightness_notif = nil
        end
      }
    end
  end)
end

return Mediakeys
