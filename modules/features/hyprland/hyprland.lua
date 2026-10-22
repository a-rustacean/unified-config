require("monitors")
require("autostart")
require("animations")
require("keybinds")

-----------------------
---- LOOK AND FEEL ----
-----------------------

-- Refer to https://wiki.hypr.land/Configuring/Basics/Variables/
hl.config({
  general = {
    gaps_in          = 5,
    gaps_out         = 10,
    border_size      = 2,

    col              = {
      active_border   = "rgb(cdd6f4)", -- Text
      inactive_border = "rgb(45475a)", -- Surface 1
      nogroup_border  = "rgb(45475a)", -- Surface 1
    },

    resize_on_border = false,
    allow_tearing    = false,
    layout           = "dwindle",
  },

  decoration = {
    rounding         = 12,
    rounding_power   = 2,
    active_opacity   = 1.0,
    inactive_opacity = 0.85,
    fullscreen_opacity = 1.0,

    shadow           = {
      enabled      = true,
      range        = 8,
      render_power = 3,
      color        = 0xee1a1a1a,
      color_inactive = 0x661a1a1a,
    },

    blur = {
      enabled = true;
      size = 14;
      passes = 3;
      ignore_opacity = true;
      new_optimizations = true;
      noise = 0.01;
      contrast = 0.8;
      brightness = 0.7;
      vibrancy = 0.4;
      vibrancy_darkness = 0.0;
      popups = true;
      xray = true;
    }
  },

  animations = {
    enabled = true,
  },

  dwindle = {
    preserve_split = true,
  },

  misc = {
    force_default_wallpaper = -1,
    disable_hyprland_logo   = true,
  },

  input = {
    kb_layout      = "us",
    kb_variant     = "",
    kb_model       = "",
    kb_options     = "",
    kb_rules       = "",

    follow_mouse   = 1,

    sensitivity    = 0, -- -1.0 - 1.0, 0 means no modification.
    natural_scroll = true,
    scroll_factor  = 0.3,
    accel_profile  = "flat",
  },
})

hl.gesture({
  fingers = 3,
  direction = "horizontal",
  action = "workspace"
})

--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- and https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

hl.window_rule({
  -- Ignore maximize requests from all apps. You'll probably like this.
  name           = "suppress-maximize-events",
  match          = { class = ".*" },

  suppress_event = "maximize",
})

hl.window_rule({
  -- Fix some dragging issues with XWayland
  name     = "fix-xwayland-drags",
  match    = {
    class      = "^$",
    title      = "^$",
    xwayland   = true,
    float      = true,
    fullscreen = false,
    pin        = false,
  },

  no_focus = true,
})

-- Hyprland-run windowrule
hl.window_rule({
  name  = "move-hyprland-run",
  match = { class = "hyprland-run" },

  move  = "20 monitor_h-120",
  float = true,
})

hl.window_rule({
  match        = { class = "(pinentry-)(.*)" },
  stay_focused = true,
})

hl.window_rule({
  match = {
    class = "vesktop|com.mitchellh.ghostty|zen-beta",
  },

  opacity = "0.8",
})
