-------------------
---- AUTOSTART ----
-------------------

local config = require("config")

hl.on("hyprland.start", function()
  hl.exec_cmd(config.programs.hyprpaper)
  hl.exec_cmd(config.programs.quickshell)
  hl.exec_cmd(config.programs.dunst)
  hl.exec_cmd("wl-paste --type text --watch cliphist store")
  hl.exec_cmd("wl-paste --type image --watch cliphist store")
  hl.exec_cmd("systemctl --user start xdg-desktop-portal-hyprland")
  hl.exec_cmd("systemctl --user start hyprpolkitagent")
  hl.exec_cmd("systemctl --user start hypridle")
  hl.exec_cmd("systemctl --user start hyprsunset")
end)
