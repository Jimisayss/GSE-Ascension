-- Ascension Compatibility Layer for GSE
-- This file contains wrapper functions to handle differences between the retail WoW API and the 3.3.5 API used by Ascension.
-- All replacement functions should be prefixed with "Asc_" to avoid conflicts.

local GSE = GSE
local Asc = {}
GSE.AscensionCompat = Asc

-- Create a timer object for C_Timer.After replacement
local timer = LibStub("AceAddon-3.0"):NewAddon("GSE_AscensionTimer", "AceTimer-3.0")
local function after(delay, func)
  timer:ScheduleTimer(func, delay)
end

-- ============================================================================
-- API Wrappers
-- ============================================================================

-- Spells
-- ============================================================================

function Asc.GetSpellInfo(spellIdOrName)
  -- In 3.3.5, GetSpellInfo is the primary function.
  return GetSpellInfo(spellIdOrName)
end

function Asc.IsUsableSpell(spellIdOrName)
  -- In 3.3.5, IsUsableSpell takes a spell name or spell ID.
  local name, rank = GetSpellInfo(spellIdOrName)
  if not name then
    return false, false
  end
  return IsUsableSpell(name, nil)
end

function Asc.GetSpellCooldown(spellIdOrName)
  -- In 3.3.5, GetSpellCooldown takes a spell name or spell ID.
  local name, rank = GetSpellInfo(spellIdOrName)
  if not name then
    return 0, 0, 0
  end
  return GetSpellCooldown(name, nil)
end

function Asc.FindSpellBookSlotBySpellID(spellId)
  -- This is a custom implementation for 3.3.5, as there is no direct equivalent.
  if not spellId then return nil end
  for i = 1, 1000 do -- Iterate through a reasonable number of spellbook slots
    local spellName, spellSubName = GetSpellBookItemInfo(i, "spell")
    if not spellName then
      -- No more spells in the book
      return nil
    end
    local _, _, _, _, _, _, id = GetSpellInfo(spellName)
    if id == spellId then
      return i
    end
  end
  return nil
end

-- Timers
-- ============================================================================

function Asc.TimerAfter(delay, func)
  -- Replaces C_Timer.After with AceTimer-3.0
  return after(delay, func)
end

-- ============================================================================
-- Retail API Stubs (to prevent errors)
-- ============================================================================
-- These are tables that exist in the retail API but not in 3.3.5.
-- We create them here as empty tables to prevent "attempt to index global" errors.

C_Spell = {}
C_Timer = { After = Asc.TimerAfter }
C_SpecializationInfo = {}
PlayerUtil = {}

-- Map the new functions to the retail names for easier replacement.
-- This allows us to replace `C_Spell.GetSpellInfo` with `GSE.AscensionCompat.C_Spell.GetSpellInfo`
-- without changing the call signature.
C_Spell.GetSpellInfo = Asc.GetSpellInfo
C_Spell.IsSpellUsable = Asc.IsUsableSpell
C_Spell.GetSpellCooldown = Asc.GetSpellCooldown
C_Spell.ShouldHoldToCast = function() return false end -- Shim for Hold to Cast API

C_SpecializationInfo.GetSpells = function() return {} end -- Return empty table to avoid errors
PlayerUtil.GetCurrentClassId = function() return GSE.GetCurrentClassID() end
PlayerUtil.GetSpecName = function() return "" end

-- ============================================================================
-- Global Shims
-- ============================================================================

if not HasRuneUI then
  function HasRuneUI()
    local _, class = UnitClass("player")
    return class == "DEATHKNIGHT"
  end
end
