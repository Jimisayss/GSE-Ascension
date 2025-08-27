-- ============================================================================
--
--      SpellCache.lua
--
--  This module provides a robust caching layer for spell information. It is
--  designed to handle the custom spell environment of Project Ascension,
--  gracefully failing on unknown spells and reducing API calls.
--
-- ============================================================================

local GSE = GSE
local L = GSE.L

GSE.SpellCache = {}
local SpellCache = GSE.SpellCache

-- The cache is private to this module.
-- It stores successful lookups and failed lookups (as false) to prevent
-- repeated API calls for spells that don't exist.
local cache = {}

function SpellCache:Initialize()
  GSE:RegisterEvent("SPELLS_CHANGED", function() SpellCache:Clear() end)
  GSE:RegisterEvent("LEARNED_SPELL_IN_TAB", function() SpellCache:Clear() end)
  GSE.PrintDebugMessage("SpellCache Initialized.", "SpellCache")
end

--- Clears the entire spell cache.
function SpellCache:Clear()
  cache = {}
  GSE.PrintDebugMessage("SpellCache cleared.", "SpellCache")
end

--- Resolves a spell by its name or ID and returns a table with its info.
-- @param ref The spell name (string) or spell ID (number).
-- @return A table with {id, name, icon} or nil if not found.
function SpellCache:Resolve(ref)
  if not ref then return nil end

  -- Check cache first
  if cache[ref] ~= nil then
    -- Return the cached result, which could be a table or false for a failed lookup.
    return cache[ref] or nil
  end

  local lookup = ref
  if type(ref) == "string" then
    -- If the string is a number, convert it to a number for lookup.
    if tonumber(ref) then
      lookup = tonumber(ref)
    end
  end

  local name, _, icon, _, _, _, spellId = GetSpellInfo(lookup)

  if not name then
    -- Spell not found. Cache the failure to prevent repeated lookups.
    GSE.PrintDebugMessage("Unknown spell: " .. tostring(ref), "SpellCache")
    cache[ref] = false
    return nil
  end

  -- Determine the correct ID. If we looked up by number, use that. Otherwise, use the returned spellId.
  local id = (type(lookup) == "number") and lookup or spellId

  local result = {
    id = id,
    name = name,
    icon = icon
  }

  -- Cache the successful result against both the original reference and the resolved ID.
  cache[ref] = result
  cache[id] = result
  if name ~= ref then
    cache[name] = result
  end

  return result
end
