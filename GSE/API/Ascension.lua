local GSE = GSE

local spellCache = {}

function GSE.IsAscension()
  if GetCVar then
    local portal = GetCVar("portal")
    if type(portal) == "string" and portal:find("Ascension") then
      return true
    end
  end
  if LibStub and LibStub:GetLibrary("LibAscensionConfig", true) then
    return true
  end
  return false
end

function GSE.ResolveSpell(ref)
  if not ref then return nil end
  if spellCache[ref] ~= nil then
    return spellCache[ref]
  end
  local lookup = ref
  if type(ref) == "string" and tonumber(ref) then
    lookup = tonumber(ref)
  end
  local name, _, icon, _, _, _, spellId = GetSpellInfo(lookup)
  if not name then
    GSE.Log("WARN", "Unknown spell " .. tostring(ref))
    spellCache[ref] = nil
    return nil
  end
  local id = type(ref) == "number" and ref or spellId
  local result = {name = name, id = id, icon = icon}
  spellCache[ref] = result
  return result
end

local function clearCache()
  spellCache = {}
end

GSE:RegisterEvent("SPELLS_CHANGED", clearCache)
GSE:RegisterEvent("LEARNED_SPELL_IN_TAB", clearCache)

return GSE
