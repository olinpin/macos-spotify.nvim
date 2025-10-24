-- lua/macos-spotify/debug.lua
-- Debug utility for testing Spotify AppleScript
-- Author: Oliver Hnat
-- License: MIT

local utils = require("macos-spotify.utils")
local M = {}

function M.test_spotify_connection()
  print("=== Testing Spotify Connection ===")
  
  -- Test 1: Check if on macOS
  local is_mac = utils.is_macos()
  print("1. Running on macOS: " .. tostring(is_mac))
  
  if not is_mac then
    print("ERROR: Not on macOS, tests cannot continue")
    return
  end
  
  -- Test 2: Check if Spotify is running
  local is_running = utils.is_spotify_running()
  print("2. Spotify is running: " .. tostring(is_running))
  
  if not is_running then
    print("ERROR: Spotify is not running, please start it")
    return
  end
  
  print("\n=== Testing Playlist Access ===")
  
  -- Test 3: Try to count playlists
  local script1 = [[
tell application "Spotify"
  return count of playlists
end tell
]]
  
  print("3. Testing: count of playlists")
  local result1 = utils.execute_osascript(script1)
  print("   Success: " .. tostring(result1.success))
  print("   Output: " .. result1.output)
  if not result1.success then
    print("   Error: " .. result1.error)
  end
  
  -- Test 4: Get first playlist name
  local script2 = [[
tell application "Spotify"
  if (count of playlists) > 0 then
    return name of first item of playlists
  else
    return "NO_PLAYLISTS"
  end if
end tell
]]
  
  print("\n4. Testing: get first playlist name")
  local result2 = utils.execute_osascript(script2)
  print("   Success: " .. tostring(result2.success))
  print("   Output: " .. result2.output)
  if not result2.success then
    print("   Error: " .. result2.error)
  end
  
  -- Test 5: Get full playlist data
  local script3 = [[
tell application "Spotify"
  set playlistData to ""
  set playlistCount to 0
  
  repeat with aPlaylist in playlists
    if playlistCount > 0 then
      set playlistData to playlistData & linefeed
    end if
    
    set playlistData to playlistData & (name of aPlaylist) & "|" & (id of aPlaylist) & "|" & (count of tracks of aPlaylist)
    set playlistCount to playlistCount + 1
    
    -- Limit to first 5 for testing
    if playlistCount >= 5 then exit repeat
  end repeat
  
  return playlistData
end tell
]]
  
  print("\n5. Testing: full playlist data format")
  local result3 = utils.execute_osascript(script3)
  print("   Success: " .. tostring(result3.success))
  print("   Output length: " .. #result3.output)
  if result3.success then
    print("   Output (first 200 chars):")
    print("   " .. result3.output:sub(1, 200))
    
    -- Try to parse it
    print("\n   Parsing playlists:")
    local count = 0
    for line in result3.output:gmatch("[^\r\n]+") do
      count = count + 1
      print("   Line " .. count .. ": " .. line)
      local parts = utils.split(line, "|")
      if #parts >= 3 then
        print("      Name: " .. utils.trim(parts[1]))
        print("      URI: " .. utils.trim(parts[2]))
        print("      Tracks: " .. utils.trim(parts[3]))
      end
    end
    print("   Total playlists parsed: " .. count)
  else
    print("   Error: " .. result3.error)
  end
  
  print("\n=== Tests Complete ===")
end

return M
