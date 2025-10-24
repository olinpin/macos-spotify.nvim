-- lua/macos-spotify/telescope.lua
-- Telescope integration for macos-spotify.nvim
-- Author: Oliver Hnat
-- License: MIT

local has_telescope, telescope = pcall(require, 'telescope')
if not has_telescope then
  error('This extension requires telescope.nvim (https://github.com/nvim-telescope/telescope.nvim)')
end

local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local conf = require('telescope.config').values
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')
local previewers = require('telescope.previewers')
local putils = require('telescope.previewers.utils')

local spotify = require('macos-spotify.spotify')
local utils = require('macos-spotify.utils')

local M = {}

--- Create a picker for playlists
-- @param opts table|nil Telescope options
function M.playlists(opts)
  opts = opts or {}
  
  -- Check if Spotify is running
  if not utils.is_macos() then
    utils.notify("This plugin only works on macOS", "warn")
    return
  end
  
  if not utils.is_spotify_running() then
    utils.notify("Spotify is not running", "warn")
    return
  end
  
  -- Get playlists
  local playlists = spotify.get_playlists()
  
  if not playlists or #playlists == 0 then
    utils.notify("No playlists found", "warn")
    return
  end
  
  pickers.new(opts, {
    prompt_title = '🎵 Spotify Playlists',
    finder = finders.new_table {
      results = playlists,
      entry_maker = function(entry)
        return {
          value = entry,
          display = string.format("%s (%d tracks)", entry.name, entry.track_count),
          ordinal = entry.name,
          uri = entry.uri,
        }
      end,
    },
    sorter = conf.generic_sorter(opts),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        
        if selection then
          -- Play the selected playlist
          spotify.play_playlist(selection.uri)
        end
      end)
      
      -- Add mapping to view tracks in playlist
      map('i', '<C-t>', function()
        local selection = action_state.get_selected_entry()
        if selection then
          actions.close(prompt_bufnr)
          M.playlist_tracks(selection.value, opts)
        end
      end)
      
      map('n', 't', function()
        local selection = action_state.get_selected_entry()
        if selection then
          actions.close(prompt_bufnr)
          M.playlist_tracks(selection.value, opts)
        end
      end)
      
      return true
    end,
  }):find()
end

--- Create a picker for tracks in a specific playlist
-- @param playlist table Playlist object {name, uri, track_count}
-- @param opts table|nil Telescope options
function M.playlist_tracks(playlist, opts)
  opts = opts or {}
  
  -- Get tracks from the playlist
  local tracks = spotify.get_playlist_tracks(playlist.uri)
  
  if not tracks or #tracks == 0 then
    utils.notify("No tracks found in playlist", "warn")
    return
  end
  
  pickers.new(opts, {
    prompt_title = string.format('🎵 %s (%d tracks)', playlist.name, playlist.track_count),
    finder = finders.new_table {
      results = tracks,
      entry_maker = function(entry)
        return {
          value = entry,
          display = entry.display,
          ordinal = entry.name .. " " .. entry.artist .. " " .. entry.album,
          uri = entry.uri,
        }
      end,
    },
    sorter = conf.generic_sorter(opts),
    previewer = previewers.new_buffer_previewer {
      title = "Track Info",
      define_preview = function(self, entry)
        local track = entry.value
        local lines = {
          "♫ " .. track.name,
          "",
          "👤 Artist: " .. track.artist,
          "💿 Album:  " .. track.album,
          "",
          "🔗 URI: " .. track.uri,
        }
        vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
        putils.highlighter(self.state.bufnr, 'markdown')
      end,
    },
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        
        if selection then
          -- Play the selected track
          spotify.play_track(selection.uri)
        end
      end)
      
      return true
    end,
  }):find()
end

--- Create a picker to search for tracks across all playlists
-- @param opts table|nil Telescope options
function M.search_tracks(opts)
  opts = opts or {}
  
  -- Check if Spotify is running
  if not utils.is_macos() then
    utils.notify("This plugin only works on macOS", "warn")
    return
  end
  
  if not utils.is_spotify_running() then
    utils.notify("Spotify is not running", "warn")
    return
  end
  
  pickers.new(opts, {
    prompt_title = '🔍 Search Spotify Tracks',
    finder = finders.new_dynamic {
      fn = function(prompt)
        if not prompt or prompt == "" then
          return {}
        end
        
        -- Search for tracks
        local results = spotify.search_tracks(prompt)
        return results or {}
      end,
      entry_maker = function(entry)
        return {
          value = entry,
          display = entry.display .. " • " .. entry.album,
          ordinal = entry.name .. " " .. entry.artist .. " " .. entry.album,
          uri = entry.uri,
        }
      end,
    },
    sorter = conf.generic_sorter(opts),
    previewer = previewers.new_buffer_previewer {
      title = "Track Info",
      define_preview = function(self, entry)
        local track = entry.value
        local lines = {
          "♫ " .. track.name,
          "",
          "👤 Artist: " .. track.artist,
          "💿 Album:  " .. track.album,
          "",
          "🔗 URI: " .. track.uri,
        }
        vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
        putils.highlighter(self.state.bufnr, 'markdown')
      end,
    },
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        
        if selection then
          -- Play the selected track
          spotify.play_track(selection.uri)
        end
      end)
      
      return true
    end,
  }):find()
end

--- Create a picker for all tracks across all playlists
-- @param opts table|nil Telescope options
function M.all_tracks(opts)
  opts = opts or {}
  
  -- Check if Spotify is running
  if not utils.is_macos() then
    utils.notify("This plugin only works on macOS", "warn")
    return
  end
  
  if not utils.is_spotify_running() then
    utils.notify("Spotify is not running", "warn")
    return
  end
  
  -- Notify user that we're loading tracks
  utils.notify("Loading all tracks from playlists...", "info")
  
  -- Get all playlists
  local playlists = spotify.get_playlists()
  
  if not playlists or #playlists == 0 then
    utils.notify("No playlists found", "warn")
    return
  end
  
  -- Collect all tracks from all playlists
  local all_tracks = {}
  local seen_uris = {}
  
  for _, playlist in ipairs(playlists) do
    local tracks = spotify.get_playlist_tracks(playlist.uri)
    if tracks then
      for _, track in ipairs(tracks) do
        if not seen_uris[track.uri] then
          table.insert(all_tracks, track)
          seen_uris[track.uri] = true
        end
      end
    end
  end
  
  if #all_tracks == 0 then
    utils.notify("No tracks found", "warn")
    return
  end
  
  pickers.new(opts, {
    prompt_title = string.format('🎵 All Tracks (%d songs)', #all_tracks),
    finder = finders.new_table {
      results = all_tracks,
      entry_maker = function(entry)
        return {
          value = entry,
          display = entry.display .. " • " .. entry.album,
          ordinal = entry.name .. " " .. entry.artist .. " " .. entry.album,
          uri = entry.uri,
        }
      end,
    },
    sorter = conf.generic_sorter(opts),
    previewer = previewers.new_buffer_previewer {
      title = "Track Info",
      define_preview = function(self, entry)
        local track = entry.value
        local lines = {
          "♫ " .. track.name,
          "",
          "👤 Artist: " .. track.artist,
          "💿 Album:  " .. track.album,
          "",
          "🔗 URI: " .. track.uri,
        }
        vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
        putils.highlighter(self.state.bufnr, 'markdown')
      end,
    },
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        
        if selection then
          -- Play the selected track
          spotify.play_track(selection.uri)
        end
      end)
      
      return true
    end,
  }):find()
end

return M
