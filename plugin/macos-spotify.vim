" plugin/macos-spotify.vim
" Neovim Spotify controller plugin for macOS
" Author: Oliver Hnat
" License: MIT

" Prevent loading the plugin twice
if exists('g:loaded_macos_spotify')
  finish
endif
let g:loaded_macos_spotify = 1

" Check for Neovim
if !has('nvim')
  echohl WarningMsg
  echom 'macos-spotify.nvim requires Neovim'
  echohl None
  finish
endif

" Check Neovim version (require 0.7+)
if !has('nvim-0.7')
  echohl WarningMsg
  echom 'macos-spotify.nvim requires Neovim 0.7 or later'
  echohl None
  finish
endif

" Define user commands

" Toggle play/pause
command! SpotifyPlayPause lua require('macos-spotify').play_pause()

" Next track
command! SpotifyNext lua require('macos-spotify').next_track()

" Previous track
command! SpotifyPrevious lua require('macos-spotify').previous_track()

" Show current track in floating window
command! SpotifyShowTrack lua require('macos-spotify').show_current_track()

" Show comprehensive status
command! SpotifyStatus lua require('macos-spotify').show_status()

" Volume control
" Usage: :SpotifyVolume       - Show current volume
"        :SpotifyVolume 50    - Set volume to 50%
command! -nargs=? SpotifyVolume lua require('macos-spotify').volume(<args>)

" Set playback position in seconds
command! -nargs=1 SpotifySeek lua require('macos-spotify').set_position(<args>)

" Toggle play/pause with track info
command! SpotifyToggle lua require('macos-spotify').toggle_with_info()

" Auto-setup with default config if not already configured
" Users can override this with their own setup() call in their config
if !exists('g:macos_spotify_configured')
  lua require('macos-spotify').setup()
  let g:macos_spotify_configured = 1
endif
