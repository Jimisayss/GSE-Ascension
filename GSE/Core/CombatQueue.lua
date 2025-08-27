-- ============================================================================
--
--      CombatQueue.lua
--
--  This file manages a queue of actions that must be executed out of
--  combat. This is critical for functions that are protected by the
--  WoW API and cannot be called during combat lockdown, such as creating
--  or modifying macros.
--
--  The queue is processed automatically when the player leaves combat.
--
-- ============================================================================

local GSE = GSE
local L = GSE.L

GSE.CombatQueue = {}

local CombatQueue = GSE.CombatQueue

function CombatQueue:Initialize()
  GSE:RegisterEvent("PLAYER_REGEN_ENABLED", function()
    GSE.PrintDebugMessage("Player has left combat, processing combat queue.", "CombatQueue")
    CombatQueue:Process()
  end)
end

--- Add an action to the combat queue.
-- @param action A table containing the action details.
function CombatQueue:QueueAction(action)
  if not action or not action.action then
    GSE.PrintDebugMessage("Attempted to queue an invalid action.", "CombatQueue")
    return
  end

  table.insert(GSE.OOCQueue, action)
  GSE.Print(L["Your action has been queued and will be executed when you leave combat."])
end


--- Process all actions in the combat queue.
function CombatQueue:Process()
  -- To prevent getting stuck in a loop, we'll only process a few items per frame.
  -- However, since this is triggered by PLAYER_REGEN_ENABLED, we can probably
  -- process the whole queue at once.
  while not InCombatLockdown() and #GSE.OOCQueue > 0 do
    local v = table.remove(GSE.OOCQueue, 1)
    if v then
      local success, err = pcall(function()
        if GSE.isEmpty(v.action) then
          GSE.PrintDebugMessage("Invalid OOC Queue entry", "CombatQueue")
          return
        end

        if v.action == "UpdateSequence" then
          GSE.OOCUpdateSequence(v.name, v.macroversion)
        elseif v.action == "Save" then
          GSE.OOCAddSequenceToCollection(v.sequencename, v.sequence, v.classid)
        elseif v.action == "Replace" then
          if GSE.isEmpty(v.classid) or GSE.isEmpty(v.sequencename) then
            GSE.Print("ERROR: Replace action missing classid or sequencename")
            return
          end

          if GSE.isEmpty(GSELibrary[v.classid]) then
            GSELibrary[v.classid] = {}
          end

          GSELibrary[v.classid][v.sequencename] = v.sequence
          GSE.Print("Saved sequence: " .. v.sequencename .. " for class " .. v.classid)

          if not GSE.isEmpty(v.sequence) and not GSE.isEmpty(v.sequence.MacroVersions) then
            local activeVersion = v.sequence.Default or 1
            if v.sequence.MacroVersions[activeVersion] then
              GSE.OOCUpdateSequence(v.sequencename, v.sequence.MacroVersions[activeVersion])
            end
          end
        elseif v.action == "openviewer" then
          GSE.GUIShowViewer()
        elseif v.action == "CheckMacroCreated" then
          GSE.OOCCheckMacroCreated(v.sequencename, v.create)
        end
      end)

      if not success then
        GSE.PrintDebugMessage("Error processing OOC Queue item: " .. tostring(err), "CombatQueue")
      end
    end
  end
end
