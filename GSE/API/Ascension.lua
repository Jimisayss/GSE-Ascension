local GSE = GSE

local spellCache = {}

function GSE.IsAscension()
  if GetCVar then
    local portal = GetCVar("portal")
    if type(portal) == "string" and portal:find("Ascension") then
      return true
    end
  end
  return false
end

function GSE.ResolveSpell(ref)
  if not ref or ref == "" then
    return nil
  end
  if spellCache[ref] ~= nil then
    return spellCache[ref]
  end
  local name, _, icon = GetSpellInfo(ref)
  if not name then
    GSE.Log("WARN", "Unknown spell " .. tostring(ref))
    spellCache[ref] = nil
    return nil
  end
  local id = type(ref) == "number" and ref or select(7, GetSpellInfo(name))
  local result = {name = name, id = id, icon = icon}
  spellCache[ref] = result
  return result
end

local function clearCache()
  spellCache = {}
end

GSE:RegisterEvent("SPELLS_CHANGED", clearCache)
GSE:RegisterEvent("LEARNED_SPELL_IN_TAB", clearCache)

if GSE.IsAscension() then
  local lhc = LibStub and LibStub("LibHealComm-3.0", true)
  if not lhc then
    GSE.Log("WARN", "LibHealComm-3.0 not found; healing predictions disabled")
  end
end

return GSE
