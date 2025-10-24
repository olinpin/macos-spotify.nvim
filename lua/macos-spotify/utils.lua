-- lua/macos-spotify/utils.lua
-- Utility functions for macos-spotify.nvim
-- Author: Oliver Hnat
-- License: MIT

local M = {}

--- Check if the current OS is macOS
-- @return boolean true if running on macOS
function M.is_macos()
  return vim.loop.os_uname().sysname == "Darwin"
end

--- Check if Spotify is currently running
-- @return boolean true if Spotify is running
function M.is_spotify_running()
  if not M.is_macos() then
    return false
  end
  
  local handle = io.popen('osascript -e \'application "Spotify" is running\'')
  if not handle then
    return false
  end
  
  local result = handle:read("*a")
  handle:close()
  
  return result:match("true") ~= nil
end

--- Execute an AppleScript command using osascript
-- @param script string The AppleScript code to execute
-- @return table {success: boolean, output: string, error: string}
function M.execute_osascript(script)
  if not M.is_macos() then
    return {
      success = false,
      output = "",
      error = "This plugin only works on macOS"
    }
  end
  
  -- Create a temporary file for the script
  local temp_file = os.tmpname()
  local file = io.open(temp_file, "w")
  if not file then
    return {
      success = false,
      output = "",
      error = "Failed to create temporary script file"
    }
  end
  
  file:write(script)
  file:close()
  
  -- Execute the script from the file
  local cmd = string.format('osascript "%s" 2>&1', temp_file)
  local handle = io.popen(cmd)
  if not handle then
    os.remove(temp_file)
    return {
      success = false,
      output = "",
      error = "Failed to execute osascript command"
    }
  end
  
  local output = handle:read("*a")
  local exit_code = handle:close()
  
  -- Clean up temp file
  os.remove(temp_file)
  
  -- Remove trailing whitespace
  output = output:gsub("%s+$", "")
  
  if exit_code then
    return {
      success = true,
      output = output,
      error = ""
    }
  else
    return {
      success = false,
      output = "",
      error = output
    }
  end
end

--- Show a notification using vim.notify
-- @param message string The notification message
-- @param level string|nil The log level (nil, "info", "warn", "error")
function M.notify(message, level)
  local log_level = vim.log.levels.INFO
  
  if level == "warn" then
    log_level = vim.log.levels.WARN
  elseif level == "error" then
    log_level = vim.log.levels.ERROR
  end
  
  vim.notify(message, log_level, { title = "Spotify" })
end

--- Trim whitespace from both ends of a string
-- @param str string The string to trim
-- @return string The trimmed string
function M.trim(str)
  return str:gsub("^%s+", ""):gsub("%s+$", "")
end

--- Split a string by a delimiter
-- @param str string The string to split
-- @param delimiter string The delimiter pattern
-- @return table Array of string parts
function M.split(str, delimiter)
  local result = {}
  local pattern = string.format("([^%s]+)", delimiter)
  
  for match in str:gmatch(pattern) do
    table.insert(result, match)
  end
  
  return result
end

return M
