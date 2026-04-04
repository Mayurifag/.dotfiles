local wezterm = require 'wezterm'
local act    = wezterm.action
local mux    = wezterm.mux

-- Single-window enforcement: focus existing window instead of spawning a second one
wezterm.on('gui-startup', function(cmd)
  local wins = wezterm.gui.gui_windows()
  if #wins > 0 then
    wins[1]:focus()
    return
  end
  mux.spawn_window(cmd or {})
end)

local config = wezterm.config_builder()

-- Shell
config.default_prog = { 'pwsh.exe', '-NoLogo' }

-- Pseudo-quake: top of screen, full width, ~40% height
-- Toggled globally via AHK on Alt+`
config.initial_cols        = 220
config.initial_rows        = 32
config.window_decorations  = 'INTEGRATED_BUTTONS|RESIZE'

-- Use EGL to avoid both the WGL probing window and the wgpu device-class window
config.front_end  = 'OpenGL'
config.prefer_egl = true

-- Appearance
config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false
config.font = wezterm.font { family = 'JetBrainsMonoNL Nerd Font Mono', weight = 'Medium' }
config.font_size = 13.0
config.color_scheme = 'Dracula (Official)'
config.window_background_opacity = 0.96
config.win32_system_backdrop = 'Acrylic'
config.enable_scroll_bar = true
config.window_padding = { left = '0.5cell', right = '0.5cell', top = '0.5cell', bottom = '0.5cell' }
config.default_cursor_style = 'BlinkingBar'
config.scrollback_lines = 9001

-- Russian keyboard layout support
config.key_map_preference = 'Mapped'

-- Keybindings
config.keys = {
  -- Tabs (new tab inherits CWD via OSC 7)
  { key = 't', mods = 'CTRL', action = wezterm.action_callback(function(window, pane)
      local cwd_uri = pane:get_current_working_dir()
      local cwd = nil
      if cwd_uri then
        cwd = cwd_uri.file_path
        -- WezTerm returns /C:/path on Windows; strip leading slash
        if cwd and cwd:sub(1, 1) == '/' then cwd = cwd:sub(2) end
      end
      window:perform_action(act.SpawnCommandInNewTab { cwd = cwd }, pane)
    end)
  },
  { key = 'w',          mods = 'CTRL',       action = act.CloseCurrentPane { confirm = false } },
  { key = '[',          mods = 'CTRL|SHIFT', action = act.ActivateTabRelative(-1) },
  { key = ']',          mods = 'CTRL|SHIFT', action = act.ActivateTabRelative(1) },
  -- Switch to tab by index
  { key = '1', mods = 'CTRL', action = act.ActivateTab(0) },
  { key = '2', mods = 'CTRL', action = act.ActivateTab(1) },
  { key = '3', mods = 'CTRL', action = act.ActivateTab(2) },
  { key = '4', mods = 'CTRL', action = act.ActivateTab(3) },
  { key = '5', mods = 'CTRL', action = act.ActivateTab(4) },
  { key = '6', mods = 'CTRL', action = act.ActivateTab(5) },
  { key = '7', mods = 'CTRL', action = act.ActivateTab(6) },
  { key = '8', mods = 'CTRL', action = act.ActivateTab(7) },
  { key = '9', mods = 'CTRL', action = act.ActivateTab(8) },
  -- Splits
  { key = '\\',         mods = 'CTRL',       action = act.SplitPane { direction = 'Right' } },
  { key = '-',          mods = 'CTRL',       action = act.SplitPane { direction = 'Down'  } },
  { key = 'z',          mods = 'CTRL|SHIFT', action = act.TogglePaneZoomState },
  -- Pane navigation
  { key = 'LeftArrow',  mods = 'CTRL|SHIFT', action = act.ActivatePaneDirection 'Left'  },
  { key = 'RightArrow', mods = 'CTRL|SHIFT', action = act.ActivatePaneDirection 'Right' },
  { key = 'UpArrow',    mods = 'CTRL|SHIFT', action = act.ActivatePaneDirection 'Up'    },
  { key = 'DownArrow',  mods = 'CTRL|SHIFT', action = act.ActivatePaneDirection 'Down'  },
}

-- Copy on select
config.mouse_bindings = {
  {
    event  = { Up = { streak = 1, button = 'Left' } },
    mods   = 'NONE',
    action = act.CompleteSelectionOrOpenLinkAtMouseCursor 'Clipboard',
  },
}

return config
