" plugin/spicetify.vim
" Neovim Spotify controller plugin for macOS
" Author: Oliver Hnat
" License: MIT

" Prevent loading the plugin twice
if exists('g:loaded_spicetify')
  finish
endif
let g:loaded_spicetify = 1

" Check for Neovim
if !has('nvim')
  echohl WarningMsg
  echom 'spicetify.nvim requires Neovim'
  echohl None
  finish
endif

" Check Neovim version (require 0.7+)
if !has('nvim-0.7')
  echohl WarningMsg
  echom 'spicetify.nvim requires Neovim 0.7 or later'
  echohl None
  finish
endif

" Define user commands

" Toggle play/pause
command! SpotifyPlayPause lua require('spicetify').play_pause()

" Next track
command! SpotifyNext lua require('spicetify').next_track()

" Previous track
command! SpotifyPrevious lua require('spicetify').previous_track()

" Show current track in floating window
command! SpotifyShowTrack lua require('spicetify').show_current_track()

" Show comprehensive status
command! SpotifyStatus lua require('spicetify').show_status()

" Volume control
" Usage: :SpotifyVolume       - Show current volume
"        :SpotifyVolume 50    - Set volume to 50%
command! -nargs=? SpotifyVolume lua require('spicetify').volume(<args>)

" Set playback position in seconds
command! -nargs=1 SpotifySeek lua require('spicetify').set_position(<args>)

" Toggle play/pause with track info
command! SpotifyToggle lua require('spicetify').toggle_with_info()

" Auto-setup with default config if not already configured
" Users can override this with their own setup() call in their config
if !exists('g:spicetify_configured')
  lua require('spicetify').setup()
  let g:spicetify_configured = 1
endif
