local config = {
  programs = {
    ghostty = os.getenv("HYPRLAND_PROGRAM_GHOSTTY") or "ghostty",
    hyprlauncher = os.getenv("HYPRLAND_PROGRAM_HYPRLAUNCHER") or "hyprlauncher",
    hyprpaper = os.getenv("HYPRLAND_PROGRAM_HYPRPAPER") or "hyprpaper",
    hyprlock = os.getenv("HYPRLAND_PROGRAM_HYPRLOCK") or "hyprlock",
    hyprshutdown = os.getenv("HYPRLAND_PROGRAM_HYPRSHUTDOWN") or "hyprshutdown",
    hyprpicker = os.getenv("HYPRLAND_PROGRAM_HYPRPICKER") or "hyprpicker",
    quickshell = os.getenv("HYPRLAND_PROGRAM_QUICKSHELL") or "qs",
    dunst = os.getenv("HYPRLAND_PROGRAM_DUNST") or "dunst",
  },
}

return config
