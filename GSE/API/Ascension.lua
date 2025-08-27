-- ============================================================================
--
--      Ascension.lua
--
--  This file contains detection logic and other functions specific to the
--  Project Ascension client.
--
-- ============================================================================

local GSE = GSE

--- Detects if the client is a Project Ascension client.
-- @return boolean
function GSE.IsAscension()
  -- First, check for the "portal" CVar, which is a common indicator.
  if GetCVar then
    local portal = GetCVar("portal")
    if type(portal) == "string" and portal:find("Ascension") then
      return true
    end
  end

  -- Second, check for the presence of the LibAscensionConfig library,
  -- which is a more reliable indicator.
  if LibStub and LibStub:GetLibrary("LibAscensionConfig", true) then
    return true
  end

  return false
end

-- The ResolveSpell and spell cache logic has been moved to Core/SpellCache.lua
-- for better modularity and robustness.

return GSE
