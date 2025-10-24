-- lua/macos-spotify/init.lua
-- Main module for macos-spotify.nvim
-- Author: Oliver Hnat
-- License: MIT

local spotify = require("macos-spotify.spotify")
local utils = require("macos-spotify.utils")

local M = {}

-- Default configuration
local default_config = {
  notifications = true,
  notification_style = "detailed", -- "minimal" or "detailed"
  show_track_info = true,
}

--- Setup the plugin with user configuration
-- @param opts table|nil User configuration options
function M.setup(opts)
  opts = opts or {}
  
  -- Merge user config with defaults
  local config = vim.tbl_deep_extend("force", default_config, opts)
  
  -- Update spotify module config
  spotify.config = config
  
  -- Check if running on macOS
  if not utils.is_macos() then
    utils.notify("macos-spotify.nvim only works on macOS", "warn")
  end
end

--- Toggle play/pause with current track info
function M.toggle_with_info()
  local state_before = spotify.get_player_state()
  local success = spotify.play_pause()
  
  if success and state_before then
    -- The notification is handled in spotify.play_pause()
    return true
  end
  
  return success
end

--- Show current track information
function M.show_current_track()
  if not utils.is_macos() then
    utils.notify("This plugin only works on macOS", "warn")
    return
  end
  
  if not utils.is_spotify_running() then
    utils.notify("Spotify is not running", "warn")
    return
  end
  
  local track = spotify.get_current_track()
  local state = spotify.get_player_state()
  
  if not track then
    utils.notify("No track information available", "warn")
    return
  end
  
  local status_icon = "⏸"
  if state and state.playing then
    status_icon = "▶"
  end
  
  -- Create detailed message
  local lines = {
    string.format("%s Now Playing", status_icon),
    "",
    string.format("♫ %s", track.name),
    string.format("👤 %s", track.artist),
    string.format("💿 %s", track.album),
  }
  
  -- Add position/duration if available
  local position = spotify.get_position()
  local duration = spotify.get_duration()
  if position and duration then
    local pos_mins = math.floor(position / 60)
    local pos_secs = math.floor(position % 60)
    local dur_mins = math.floor((duration / 1000) / 60)
    local dur_secs = math.floor((duration / 1000) % 60)
    table.insert(lines, "")
    table.insert(lines, string.format("⏱  %02d:%02d / %02d:%02d", pos_mins, pos_secs, dur_mins, dur_secs))
  end
  
  -- Show in a floating window for better formatting
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  
  -- Set buffer options
  vim.api.nvim_buf_set_option(buf, 'modifiable', false)
  vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
  
  -- Calculate window size
  local width = 50
  local height = #lines
  
  -- Get editor dimensions
  local ui = vim.api.nvim_list_uis()[1]
  local win_width = ui.width
  local win_height = ui.height
  
  -- Calculate center position
  local row = math.floor((win_height - height) / 2)
  local col = math.floor((win_width - width) / 2)
  
  -- Create floating window
  local opts = {
    relative = 'editor',
    row = row,
    col = col,
    width = width,
    height = height,
    style = 'minimal',
    border = 'rounded',
    title = ' Spotify ',
    title_pos = 'center',
  }
  
  local win = vim.api.nvim_open_win(buf, false, opts)
  
  -- Set window options
  vim.api.nvim_win_set_option(win, 'winhl', 'Normal:Normal,FloatBorder:FloatBorder')
  
  -- Auto-close window after 3 seconds or on any key press
  vim.defer_fn(function()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end, 3000)
  
  -- Close on any key press
  vim.api.nvim_buf_set_keymap(buf, 'n', '<Esc>', '', {
    callback = function()
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
      end
    end,
    noremap = true,
    silent = true,
  })
  
  -- Also close on any other key
  vim.api.nvim_buf_set_keymap(buf, 'n', '<CR>', '', {
    callback = function()
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
      end
    end,
    noremap = true,
    silent = true,
  })
end

--- Show player status with all information
function M.show_status()
  if not utils.is_macos() then
    utils.notify("This plugin only works on macOS", "warn")
    return
  end
  
  if not utils.is_spotify_running() then
    utils.notify("Spotify is not running", "warn")
    return
  end
  
  local status = spotify.get_status()
  
  if not status then
    utils.notify("Failed to get player status", "error")
    return
  end
  
  local lines = {
    "🎵 Spotify Status",
    "",
    string.format("Track: %s", status.track.name),
    string.format("Artist: %s", status.track.artist),
    string.format("Album: %s", status.track.album),
    "",
    string.format("State: %s", status.state.state),
  }
  
  if status.volume then
    table.insert(lines, string.format("Volume: %d%%", status.volume))
  end
  
  if status.position_formatted and status.duration_formatted then
    table.insert(lines, "")
    table.insert(lines, string.format("Position: %s / %s (%.1f%%)", 
      status.position_formatted, 
      status.duration_formatted, 
      status.progress_percentage))
  end
  
  utils.notify(table.concat(lines, "\n"), "info")
end

--- Volume control with optional argument
-- @param level number|nil Volume level (0-100), nil to show current volume
function M.volume(level)
  if level then
    spotify.set_volume(level)
  else
    local vol = spotify.get_volume()
    if vol then
      utils.notify(string.format("Current volume: %d%%", vol), "info")
    else
      utils.notify("Failed to get volume", "error")
    end
  end
end

-- Export all spotify functions
M.play_pause = spotify.play_pause
M.next_track = spotify.next_track
M.previous_track = spotify.previous_track
M.get_current_track = spotify.get_current_track
M.get_player_state = spotify.get_player_state
M.set_volume = spotify.set_volume
M.get_volume = spotify.get_volume
M.set_position = spotify.set_position
M.get_position = spotify.get_position
M.get_duration = spotify.get_duration
M.get_status = spotify.get_status

return M
