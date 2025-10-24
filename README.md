# 🎵 spicetify.nvim

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
- ⚡ **Fast & Lightweight**: Uses native AppleScript for instant response
- 🛠️ **Easy Configuration**: Simple Lua-based setup

## 📋 Requirements

- **macOS**: This plugin uses AppleScript and only works on macOS
- **Neovim 0.7+**: Requires modern Neovim with Lua support
- **Spotify**: The Spotify application must be installed and running

## 📦 Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  'yourusername/spicetify-nvim',
  config = function()
    require('spicetify').setup({
      notifications = true,
      notification_style = 'detailed',
      show_track_info = true,
    })
  end,
  keys = {
    { '<leader>sp', '<cmd>SpotifyPlayPause<cr>', desc = 'Spotify: Play/Pause' },
    { '<leader>sn', '<cmd>SpotifyNext<cr>', desc = 'Spotify: Next Track' },
    { '<leader>sb', '<cmd>SpotifyPrevious<cr>', desc = 'Spotify: Previous Track' },
    { '<leader>ss', '<cmd>SpotifyShowTrack<cr>', desc = 'Spotify: Show Track' },
    { '<leader>st', '<cmd>SpotifyStatus<cr>', desc = 'Spotify: Status' },
  },
}
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  'yourusername/spicetify-nvim',
  config = function()
    require('spicetify').setup()
  end
}
```

### Using [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'yourusername/spicetify-nvim'
```

Then add to your `init.lua`:

```lua
require('spicetify').setup()
```

## ⚙️ Configuration

The plugin works out of the box with sensible defaults, but you can customize it:

```lua
require('spicetify').setup({
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
  require('spicetify').play_pause()
end, { desc = 'Spotify: Play/Pause' })

vim.keymap.set('n', '<leader>sn', function()
  require('spicetify').next_track()
end, { desc = 'Spotify: Next Track' })

vim.keymap.set('n', '<leader>sb', function()
  require('spicetify').previous_track()
end, { desc = 'Spotify: Previous Track' })

vim.keymap.set('n', '<leader>ss', function()
  require('spicetify').show_current_track()
end, { desc = 'Spotify: Show Track' })
```

## 🔧 Lua API

All functionality is available through the Lua API:

### Setup

```lua
require('spicetify').setup(opts)
```

Initialize the plugin with configuration options.

### Playback Control

```lua
-- Toggle play/pause
require('spicetify').play_pause()

-- Next track
require('spicetify').next_track()

-- Previous track  
require('spicetify').previous_track()
```

### Information Display

```lua
-- Show current track in floating window
require('spicetify').show_current_track()

-- Show comprehensive status
require('spicetify').show_status()
```

### Volume Control

```lua
-- Get current volume
local volume = require('spicetify').get_volume()

-- Set volume to 75%
require('spicetify').set_volume(75)

-- Get or set volume (command style)
require('spicetify').volume(50)  -- Set to 50%
require('spicetify').volume()     -- Show current
```

### Track Information

```lua
-- Get current track info
local track = require('spicetify').get_current_track()
if track then
  print(track.name)     -- Track name
  print(track.artist)   -- Artist name
  print(track.album)    -- Album name
  print(track.display)  -- Formatted "Track - Artist"
end

-- Get player state
local state = require('spicetify').get_player_state()
if state then
  print(state.state)    -- "playing" or "paused"
  print(state.playing)  -- boolean
  print(state.paused)   -- boolean
end

-- Get comprehensive status
local status = require('spicetify').get_status()
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
local position = require('spicetify').get_position()

-- Set position to 30 seconds
require('spicetify').set_position(30)

-- Get track duration (in milliseconds)
local duration = require('spicetify').get_duration()
```

## 📚 Help Documentation

The plugin includes comprehensive Vim help documentation. Access it with:

```vim
:help spicetify
```

Browse help topics:
- `:help spicetify-commands` - Command reference
- `:help spicetify-api` - Lua API documentation
- `:help spicetify-configuration` - Configuration options
- `:help spicetify-troubleshooting` - Common issues

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
require('spicetify').setup({
  notifications = true,
})
```

### Floating window not showing

1. Ensure you're using Neovim 0.7+
2. Check for Lua errors with `:messages`
3. Try running `:SpotifyShowTrack` directly

## 🚀 Future Enhancement Ideas

Potential features for future versions:

- Support for Apple Music and other players
- Playlist management and creation
- Search functionality
- Track progress bar in statusline
- Like/unlike current track
- Shuffle and repeat controls
- Integration with statusline plugins (lualine, etc.)
- Lyrics display
- Queue management

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
2. Read the help documentation: `:help spicetify`
3. Open an issue on GitHub

---

**Note**: This plugin is not affiliated with, endorsed by, or sponsored by Spotify AB.

Made with ❤️ for the Neovim community
