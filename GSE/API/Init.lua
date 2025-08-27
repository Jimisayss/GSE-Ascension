-- GLOBALS: GSE
GSE = LibStub("AceAddon-3.0"):NewAddon("GSE", "AceConsole-3.0", "AceEvent-3.0", "AceComm-3.0", "AceSerializer-3.0", "AceTimer-3.0")
GSE.L = LibStub("AceLocale-3.0"):GetLocale("GSE")
GSE.Static = {}

GSE.VersionString = GetAddOnMetadata("GSE", "Version");

GSE.MediaPath = "Interface\\Addons\\GSE\\Media"

GSE.OutputQueue = {}
GSE.DebugOutput = ""
GSE.SequenceDebugOutput = ""
GSE.GUI = {}
GSE.isNewFirstTimeCreated = false
local L = GSE.L
local Statics = GSE.Static
local GNOME = "GSE"
local logLevels = { ERROR = 1, WARN = 2, INFO = 3, DEBUG = 4 }
GSEOptions = GSEOptions or {}
GSEOptions.LogLevel = GSEOptions.LogLevel or logLevels.INFO

function GSE.Log(level, message, context)
  local lvl = logLevels[level] or logLevels.INFO
  if lvl > (GSEOptions.LogLevel or logLevels.INFO) then return end
  local prefix = level
  if context then prefix = prefix .. ' [' .. context .. ']' end
  GSE.Print(prefix .. ': ' .. tostring(message))
end


-- Initialisation Functions


--- When the Addon loads, printing is paused until after every other mod has loaded.
--    This method prints the print queue.
function GSE.PerformPrint()
  for k,v in ipairs(GSE.OutputQueue) do
    print(v)
    GSE.OutputQueue[k] = nil
  end
end


--- Prints <code>filepath</code>to the chat handler.  This accepts an optional
--    <code>title</code> to be prepended to that message.
function GSE.Print(message, title)
  -- store this for later on.
  if not GSE.isEmpty(title) then
    message = GSEOptions.TitleColour .. title .. Statics.StringReset .." " .. message
  end
  table.insert(GSE.OutputQueue, message)
  if GSE.PrintAvailable then
    GSE.PerformPrint()
  end
end

GSE.CurrentGCD = GetSpellCooldown(61304)
GSE.RecorderActive = false

-- Macro mode Status
GSE.PVPFlag = false
GSE.inRaid = false
GSE.inMythic = false
GSE.inDungeon = false
GSE.inHeroic = false
GSE.inParty = false
