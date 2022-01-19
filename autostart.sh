#!/bin/bash

pkill mpris-proxy

nm-applet &
blueman-tray &

picom --experimental-backends &

# Start kde-polkit-agent
/usr/lib/polkit-kde-authentication-agent-1 &

# Start mpris-proxy
mpris-proxy &
