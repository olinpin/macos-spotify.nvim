# 🎵 macos-spotify.nvim

A Neovim plugin for controlling Spotify on macOS directly from your editor. Control playback, view track information, and manage your Spotify experience without leaving Neovim.

![Neovim](https://img.shields.io/badge/NeoVim-0.7+-brightgreen.svg?style=flat-square)
![macOS](https://img.shields.io/badge/macOS-only-blue.svg?style=flat-square)
![License](https://img.shields.io/badge/license-MIT-orange.svg?style=flat-square)

## ✨ Features

- 🎮 **Playback Control**: Play, pause, next, previous track
- 📊 **Track Information**: Display current track with artist and album
- 🔊 **Volume Control**: Get and set Spotify volume
- ⏱️ **Playback Position**: Seek to specific positions in tracks
- 🪟 **Beautiful UI**: Floating windows with formatted track information
- 🔔 **Smart Notifications**: Configurable notifications for all actions
- 🔭 **Telescope Integration**: Browse playlists, search tracks, and play songs with Telescope.nvim
- ⚡ **Fast & Lightweight**: Uses native AppleScript for instant response
- 🛠️ **Easy Configuration**: Simple Lua-based setup

## 📋 Requirements

- **macOS**: This plugin uses AppleScript and only works on macOS
- **Neovim 0.7+**: Requires modern Neovim with Lua support
- **Spotify**: The Spotify application must be installed and running
- **Telescope.nvim** (optional): Required for browsing playlists and searching tracks

## 📦 Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  'olinpin/macos-spotify.nvim',
  dependencies = {
    'nvim-telescope/telescope.nvim', -- Optional, for browsing playlists and searching
  },
  config = function()
    require('macos-spotify').setup({
      notifications = true,
      notification_style = 'detailed',
      show_track_info = true,
    })
  end,
  keys = {
    -- Playback controls
    { '<leader>sp', '<cmd>SpotifyPlayPause<cr>', desc = 'Spotify: Play/Pause' },
    { '<leader>sn', '<cmd>SpotifyNext<cr>', desc = 'Spotify: Next Track' },
    { '<leader>sb', '<cmd>SpotifyPrevious<cr>', desc = 'Spotify: Previous Track' },
    { '<leader>ss', '<cmd>SpotifyShowTrack<cr>', desc = 'Spotify: Show Track' },
    { '<leader>st', '<cmd>SpotifyStatus<cr>', desc = 'Spotify: Status' },
    
    -- Telescope integration
    { '<leader>sP', '<cmd>SpotifyPlaylists<cr>', desc = 'Spotify: Browse Playlists' },
    { '<leader>sf', '<cmd>SpotifySearch<cr>', desc = 'Spotify: Search Tracks' },
    { '<leader>sT', '<cmd>SpotifyTracks<cr>', desc = 'Spotify: Browse All Tracks' },
  },
}
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  'olinpin/macos-spotify.nvim',
  config = function()
    require('macos-spotify').setup()
  end
}
```

### Using [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'olinpin/macos-spotify.nvim'
```

Then add to your `init.lua`:

```lua
require('macos-spotify').setup()
```

## ⚙️ Configuration

The plugin works out of the box with sensible defaults, but you can customize it:

```lua
require('macos-spotify').setup({
  -- Enable/disable notifications (default: true)
  notifications = true,
  
  -- Notification style: 'minimal' or 'detailed' (default: 'detailed')
  -- 'detailed' shows icons and rich formatting
  -- 'minimal' shows simple text messages
  notification_style = 'detailed',
  
  -- Show track info after play/pause/next/previous (default: true)
  show_track_info = true,
})
```

### Configuration Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `notifications` | `boolean` | `true` | Enable/disable all notifications |
| `notification_style` | `string` | `'detailed'` | Notification style: `'minimal'` or `'detailed'` |
| `show_track_info` | `boolean` | `true` | Show track info after playback actions |

## 🎮 Commands

| Command | Description |
|---------|-------------|
| `:SpotifyPlayPause` | Toggle play/pause |
| `:SpotifyNext` | Skip to next track |
| `:SpotifyPrevious` | Go to previous track |
| `:SpotifyShowTrack` | Display current track in floating window |
| `:SpotifyStatus` | Show comprehensive player status |
| `:SpotifyVolume [level]` | Get/set volume (0-100) |
| `:SpotifySeek {seconds}` | Jump to position in seconds |
| `:SpotifyToggle` | Play/pause with track info |

### Telescope Commands

**Requires [Telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)**

| Command | Description | Keybindings |
|---------|-------------|-------------|
| `:SpotifyPlaylists` | Browse and play playlists | `<C-t>` or `t` in insert/normal mode to view tracks |
| `:SpotifySearch` | Search for tracks across all playlists | Type to search dynamically |
| `:SpotifyTracks` | Browse all tracks from all playlists | Fuzzy search through all songs |

**Telescope Picker Features:**
- **Preview**: See track details (name, artist, album, URI) in preview window
- **Play on Select**: Press `<CR>` to play the selected track or playlist
- **Navigation**: Use standard Telescope navigation (`<C-n>`, `<C-p>`, etc.)
- **Playlist Tracks**: From playlists picker, press `<C-t>` to view tracks in that playlist

### Command Examples

```vim
" Show current volume
:SpotifyVolume

" Set volume to 50%
:SpotifyVolume 50

" Jump to 30 seconds into the track
:SpotifySeek 30
```

## ⌨️ Keybindings

The plugin doesn't set default keybindings to avoid conflicts. Here are some suggested mappings:

### Basic Setup

```lua
local opts = { noremap = true, silent = true }

vim.keymap.set('n', '<leader>sp', ':SpotifyPlayPause<CR>', 
  vim.tbl_extend('force', opts, { desc = 'Spotify: Play/Pause' }))

vim.keymap.set('n', '<leader>sn', ':SpotifyNext<CR>', 
  vim.tbl_extend('force', opts, { desc = 'Spotify: Next Track' }))

vim.keymap.set('n', '<leader>sb', ':SpotifyPrevious<CR>', 
  vim.tbl_extend('force', opts, { desc = 'Spotify: Previous Track' }))

vim.keymap.set('n', '<leader>ss', ':SpotifyShowTrack<CR>', 
  vim.tbl_extend('force', opts, { desc = 'Spotify: Show Track' }))

vim.keymap.set('n', '<leader>st', ':SpotifyStatus<CR>', 
  vim.tbl_extend('force', opts, { desc = 'Spotify: Show Status' }))
```

### Using Lua Functions Directly

```lua
vim.keymap.set('n', '<leader>sp', function()
  require('macos-spotify').play_pause()
end, { desc = 'Spotify: Play/Pause' })

vim.keymap.set('n', '<leader>sn', function()
  require('macos-spotify').next_track()
end, { desc = 'Spotify: Next Track' })

vim.keymap.set('n', '<leader>sb', function()
  require('macos-spotify').previous_track()
end, { desc = 'Spotify: Previous Track' })

vim.keymap.set('n', '<leader>ss', function()
  require('macos-spotify').show_current_track()
end, { desc = 'Spotify: Show Track' })
```

### Telescope Integration Keybindings

```lua
-- Telescope integration (requires telescope.nvim)
vim.keymap.set('n', '<leader>sP', ':SpotifyPlaylists<CR>', 
  { desc = 'Spotify: Browse Playlists' })

vim.keymap.set('n', '<leader>sf', ':SpotifySearch<CR>', 
  { desc = 'Spotify: Search Tracks' })

vim.keymap.set('n', '<leader>sT', ':SpotifyTracks<CR>', 
  { desc = 'Spotify: Browse All Tracks' })

-- Or using Lua functions directly
vim.keymap.set('n', '<leader>sP', function()
  require('macos-spotify').telescope_playlists()
end, { desc = 'Spotify: Browse Playlists' })

vim.keymap.set('n', '<leader>sf', function()
  require('macos-spotify').telescope_search()
end, { desc = 'Spotify: Search Tracks' })
```

## 🔧 Lua API

All functionality is available through the Lua API:

### Setup

```lua
require('macos-spotify').setup(opts)
```

Initialize the plugin with configuration options.

### Playback Control

```lua
-- Toggle play/pause
require('macos-spotify').play_pause()

-- Next track
require('macos-spotify').next_track()

-- Previous track  
require('macos-spotify').previous_track()
```

### Information Display

```lua
-- Show current track in floating window
require('macos-spotify').show_current_track()

-- Show comprehensive status
require('macos-spotify').show_status()
```

### Volume Control

```lua
-- Get current volume
local volume = require('macos-spotify').get_volume()

-- Set volume to 75%
require('macos-spotify').set_volume(75)

-- Get or set volume (command style)
require('macos-spotify').volume(50)  -- Set to 50%
require('macos-spotify').volume()     -- Show current
```

### Track Information

```lua
-- Get current track info
local track = require('macos-spotify').get_current_track()
if track then
  print(track.name)     -- Track name
  print(track.artist)   -- Artist name
  print(track.album)    -- Album name
  print(track.display)  -- Formatted "Track - Artist"
end

-- Get player state
local state = require('macos-spotify').get_player_state()
if state then
  print(state.state)    -- "playing" or "paused"
  print(state.playing)  -- boolean
  print(state.paused)   -- boolean
end

-- Get comprehensive status
local status = require('macos-spotify').get_status()
if status then
  print(status.track.name)
  print(status.state.state)
  print(status.volume)
  print(status.position_formatted)  -- "02:45"
  print(status.duration_formatted)  -- "03:30"
  print(status.progress_percentage) -- 78.5
end
```

### Playback Position

```lua
-- Get current position (in seconds)
local position = require('macos-spotify').get_position()

-- Set position to 30 seconds
require('macos-spotify').set_position(30)

-- Get track duration (in milliseconds)
local duration = require('macos-spotify').get_duration()
```

### Telescope Integration

**Requires Telescope.nvim**

```lua
-- Browse playlists with Telescope
require('macos-spotify').telescope_playlists()

-- Search for tracks across all playlists
require('macos-spotify').telescope_search()

-- Browse all tracks from all playlists
require('macos-spotify').telescope_tracks()

-- Get playlists programmatically
local playlists = require('macos-spotify').get_playlists()
if playlists then
  for _, playlist in ipairs(playlists) do
    print(playlist.name)      -- Playlist name
    print(playlist.uri)       -- Spotify URI
    print(playlist.track_count) -- Number of tracks
  end
end

-- Get tracks from a specific playlist
local tracks = require('macos-spotify').get_playlist_tracks(playlist_uri)
if tracks then
  for _, track in ipairs(tracks) do
    print(track.name)    -- Track name
    print(track.artist)  -- Artist name
    print(track.album)   -- Album name
    print(track.uri)     -- Spotify URI
    print(track.display) -- Formatted "Track - Artist"
  end
end

-- Play a specific track by URI
require('macos-spotify').play_track('spotify:track:...')

-- Play a specific playlist by URI
require('macos-spotify').play_playlist('spotify:playlist:...')

-- Search for tracks
local results = require('macos-spotify').search_tracks('song name')
```

## 📚 Help Documentation

The plugin includes comprehensive Vim help documentation. Access it with:

```vim
:help macos-spotify
```

Browse help topics:
- `:help macos-spotify-commands` - Command reference
- `:help macos-spotify-api` - Lua API documentation
- `:help macos-spotify-configuration` - Configuration options
- `:help macos-spotify-troubleshooting` - Common issues

## 🐛 Troubleshooting

### "This plugin only works on macOS"

This plugin uses AppleScript which is only available on macOS. It will not work on Linux or Windows.

### "Spotify is not running"

Make sure the Spotify application is open and running. The plugin cannot control Spotify if it's not running.

### Commands don't respond or timeout

1. Verify Spotify is running and responsive
2. Try controlling Spotify manually to ensure it's not frozen
3. Check Console.app for any AppleScript errors
4. Restart Spotify

### Notifications not appearing

Check your configuration to ensure notifications are enabled:

```lua
require('macos-spotify').setup({
  notifications = true,
})
```

### Floating window not showing

1. Ensure you're using Neovim 0.7+
2. Check for Lua errors with `:messages`
3. Try running `:SpotifyShowTrack` directly

### Telescope commands not working

1. Make sure Telescope.nvim is installed: `:Telescope` should work
2. Check if the plugin can load telescope: `:lua print(pcall(require, 'telescope'))`
3. Verify Spotify is running before using Telescope commands

### Playlist loading is slow

Loading all tracks from multiple playlists can take time depending on:
- Number of playlists in your library
- Number of tracks per playlist
- Spotify's response time

Use `:SpotifySearch` for faster dynamic searching, or `:SpotifyPlaylists` to browse one playlist at a time.

## 🚀 Future Enhancement Ideas

Potential features for future versions:

- ✅ ~~Playlist browsing~~ (Implemented with Telescope)
- ✅ ~~Search functionality~~ (Implemented with Telescope)
- Support for Apple Music and other players
- Playlist management and creation (add/remove tracks)
- Track progress bar in statusline
- Like/unlike current track
- Shuffle and repeat controls
- Integration with statusline plugins (lualine, etc.)
- Lyrics display
- Queue management
- Album browsing
- Artist browsing

Contributions are welcome! Feel free to open issues or submit pull requests.

## 🧪 Testing

### Manual Testing Checklist

When testing the plugin, verify:

1. ✅ Plugin loads without errors
2. ✅ Commands work with Spotify not running (graceful error)
3. ✅ Commands work with Spotify running but nothing playing
4. ✅ Play/pause toggles correctly
5. ✅ Next/previous track navigation works
6. ✅ Track information displays correctly
7. ✅ Volume controls work (get and set)
8. ✅ Floating window displays and closes properly
9. ✅ Notifications appear with correct formatting
10. ✅ Keybindings work as expected

### Testing Commands

```vim
" Test basic functionality
:SpotifyPlayPause
:SpotifyNext
:SpotifyPrevious
:SpotifyShowTrack
:SpotifyStatus

" Test volume control
:SpotifyVolume
:SpotifyVolume 50

" Test seeking
:SpotifySeek 30
```

## 📄 License

MIT License - see LICENSE file for details

Copyright (c) 2025 Oliver Hnat

## 🙏 Acknowledgments

- Built with Neovim's powerful Lua API
- Uses macOS AppleScript for Spotify control
- Inspired by various Spotify integration plugins

## 📞 Support

If you encounter issues or have questions:

1. Check the [Troubleshooting](#-troubleshooting) section
2. Read the help documentation: `:help macos-spotify`
3. Open an issue on GitHub

---

**Note**: This plugin is not affiliated with, endorsed by, or sponsored by Spotify AB.

Made with ❤️ for the Neovim community
