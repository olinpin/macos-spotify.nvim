-- lua/macos-spotify/spotify.lua
-- Spotify control functions using AppleScript
-- Author: Oliver Hnat
-- License: MIT

local utils = require("macos-spotify.utils")
local M = {}

-- Internal configuration
M.config = {
  notifications = true,
  notification_style = "detailed",
  show_track_info = true,
}

--- Check if Spotify is available and running
-- @return boolean, string success status and error message if any
local function check_spotify()
  if not utils.is_macos() then
    return false, "This plugin only works on macOS"
  end
  
  if not utils.is_spotify_running() then
    return false, "Spotify is not running. Please start Spotify first."
  end
  
  return true, ""
end

--- Toggle play/pause state
-- @return boolean success status
function M.play_pause()
  local ok, err = check_spotify()
  if not ok then
    if M.config.notifications then
      utils.notify(err, "warn")
    end
    return false
  end
  
  local result = utils.execute_osascript('tell application "Spotify" to playpause')
  
  if result.success then
    if M.config.notifications and M.config.show_track_info then
      -- Get current state and track after toggling
      vim.defer_fn(function()
        local track = M.get_current_track()
        local state = M.get_player_state()
        if track and state then
          local status = state.playing and "▶ Playing" or "⏸ Paused"
          utils.notify(string.format("%s: %s", status, track.display), "info")
        end
      end, 100)
    end
    return true
  else
    if M.config.notifications then
      utils.notify("Failed to toggle play/pause: " .. result.error, "error")
    end
    return false
  end
end

--- Skip to the next track
-- @return boolean success status
function M.next_track()
  local ok, err = check_spotify()
  if not ok then
    if M.config.notifications then
      utils.notify(err, "warn")
    end
    return false
  end
  
  local result = utils.execute_osascript('tell application "Spotify" to next track')
  
  if result.success then
    if M.config.notifications and M.config.show_track_info then
      vim.defer_fn(function()
        local track = M.get_current_track()
        if track then
          utils.notify("⏭ Next: " .. track.display, "info")
        end
      end, 200)
    end
    return true
  else
    if M.config.notifications then
      utils.notify("Failed to skip to next track: " .. result.error, "error")
    end
    return false
  end
end

--- Go to the previous track
-- @return boolean success status
function M.previous_track()
  local ok, err = check_spotify()
  if not ok then
    if M.config.notifications then
      utils.notify(err, "warn")
    end
    return false
  end
  
  local result = utils.execute_osascript('tell application "Spotify" to previous track')
  
  if result.success then
    if M.config.notifications and M.config.show_track_info then
      vim.defer_fn(function()
        local track = M.get_current_track()
        if track then
          utils.notify("⏮ Previous: " .. track.display, "info")
        end
      end, 200)
    end
    return true
  else
    if M.config.notifications then
      utils.notify("Failed to go to previous track: " .. result.error, "error")
    end
    return false
  end
end

--- Get current track information
-- @return table|nil {name: string, artist: string, album: string, display: string}
function M.get_current_track()
  local ok, err = check_spotify()
  if not ok then
    return nil
  end
  
  local script = [[
    tell application "Spotify"
      set trackName to name of current track
      set trackArtist to artist of current track
      set trackAlbum to album of current track
      return trackName & "|" & trackArtist & "|" & trackAlbum
    end tell
  ]]
  
  local result = utils.execute_osascript(script)
  
  if result.success and result.output ~= "" then
    local parts = utils.split(result.output, "|")
    if #parts >= 3 then
      return {
        name = utils.trim(parts[1]),
        artist = utils.trim(parts[2]),
        album = utils.trim(parts[3]),
        display = string.format("%s - %s", utils.trim(parts[1]), utils.trim(parts[2]))
      }
    end
  end
  
  return nil
end

--- Get player state
-- @return table|nil {state: string, playing: boolean, paused: boolean}
function M.get_player_state()
  local ok, err = check_spotify()
  if not ok then
    return nil
  end
  
  local result = utils.execute_osascript('tell application "Spotify" to return player state as string')
  
  if result.success and result.output ~= "" then
    local state = utils.trim(result.output)
    return {
      state = state,
      playing = state == "playing",
      paused = state == "paused"
    }
  end
  
  return nil
end

--- Set volume level
-- @param level number Volume level (0-100)
-- @return boolean success status
function M.set_volume(level)
  local ok, err = check_spotify()
  if not ok then
    if M.config.notifications then
      utils.notify(err, "warn")
    end
    return false
  end
  
  -- Validate volume level
  level = tonumber(level)
  if not level or level < 0 or level > 100 then
    if M.config.notifications then
      utils.notify("Volume must be between 0 and 100", "error")
    end
    return false
  end
  
  local script = string.format('tell application "Spotify" to set sound volume to %d', level)
  local result = utils.execute_osascript(script)
  
  if result.success then
    if M.config.notifications then
      utils.notify(string.format("🔊 Volume set to %d%%", level), "info")
    end
    return true
  else
    if M.config.notifications then
      utils.notify("Failed to set volume: " .. result.error, "error")
    end
    return false
  end
end

--- Get current volume level
-- @return number|nil Volume level (0-100)
function M.get_volume()
  local ok, err = check_spotify()
  if not ok then
    return nil
  end
  
  local result = utils.execute_osascript('tell application "Spotify" to return sound volume')
  
  if result.success and result.output ~= "" then
    return tonumber(result.output)
  end
  
  return nil
end

--- Set playback position
-- @param seconds number Position in seconds
-- @return boolean success status
function M.set_position(seconds)
  local ok, err = check_spotify()
  if not ok then
    if M.config.notifications then
      utils.notify(err, "warn")
    end
    return false
  end
  
  seconds = tonumber(seconds)
  if not seconds or seconds < 0 then
    if M.config.notifications then
      utils.notify("Position must be a positive number", "error")
    end
    return false
  end
  
  local script = string.format('tell application "Spotify" to set player position to %d', seconds)
  local result = utils.execute_osascript(script)
  
  if result.success then
    if M.config.notifications then
      utils.notify(string.format("⏩ Position set to %d seconds", seconds), "info")
    end
    return true
  else
    if M.config.notifications then
      utils.notify("Failed to set position: " .. result.error, "error")
    end
    return false
  end
end

--- Get current playback position
-- @return number|nil Position in seconds
function M.get_position()
  local ok, err = check_spotify()
  if not ok then
    return nil
  end
  
  local result = utils.execute_osascript('tell application "Spotify" to return player position')
  
  if result.success and result.output ~= "" then
    return tonumber(result.output)
  end
  
  return nil
end

--- Get track duration
-- @return number|nil Duration in milliseconds
function M.get_duration()
  local ok, err = check_spotify()
  if not ok then
    return nil
  end
  
  local result = utils.execute_osascript('tell application "Spotify" to return duration of current track')
  
  if result.success and result.output ~= "" then
    return tonumber(result.output)
  end
  
  return nil
end

--- Format seconds to MM:SS
-- @param seconds number
-- @return string formatted time
local function format_time(seconds)
  local mins = math.floor(seconds / 60)
  local secs = math.floor(seconds % 60)
  return string.format("%02d:%02d", mins, secs)
end

--- Get comprehensive player status
-- @return table|nil Complete status information
function M.get_status()
  local ok, err = check_spotify()
  if not ok then
    return nil
  end
  
  local track = M.get_current_track()
  local state = M.get_player_state()
  local volume = M.get_volume()
  local position = M.get_position()
  local duration = M.get_duration()
  
  if not track or not state then
    return nil
  end
  
  local status = {
    track = track,
    state = state,
    volume = volume,
    position = position,
    duration = duration,
  }
  
  -- Add formatted position if available
  if position and duration then
    status.position_formatted = format_time(position)
    status.duration_formatted = format_time(duration / 1000) -- duration is in ms
    status.progress_percentage = (position / (duration / 1000)) * 100
  end
  
  return status
end

return M
