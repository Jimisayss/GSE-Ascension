-- ============================================================================
--
--      WotLK.lua
--
--  This file contains API shims and compatibility functions to ensure
--  GSE runs smoothly on the World of Warcraft 3.3.5a client. It
--  provides fallbacks or replacements for functions that were changed
--  or do not exist in this version of the API.
--
-- ============================================================================

local GSE = GSE

-- Simple string split utility, as the global one may not be loaded yet.
local function split(str, pat)
   local t = {}
   local fpat = "(.-)" .. pat
   local last_end = 1
   local s, e, cap = str:find(fpat, 1)
   while s do
      if s ~= 1 or cap ~= "" then
         table.insert(t,cap)
      end
      last_end = e+1
      s, e, cap = str:find(fpat, last_end)
   end
   if last_end <= #str then
      cap = str:sub(last_end)
      table.insert(t, cap)
   end
   return t
end

-- In WotLK, GetNumRaidMembers() and GetNumSubgroupMembers() are the correct
-- functions to use. GetNumGroupMembers() was introduced in later expansions.
-- We create a shim for GetNumGroupMembers to maintain compatibility with
-- code that might use the modern API.

if not GetNumGroupMembers then
  function GetNumGroupMembers()
    if IsInRaid() then
      return GetNumRaidMembers()
    elseif IsInGroup() then
      -- GetNumSubgroupMembers() is the WotLK equivalent for party size.
      return GetNumSubgroupMembers()
    end
    return 1 -- Player is always in a group of at least 1 (themselves)
  end
end

-- In WotLK, GetSpecializationInfoByID does not exist. We create a shim
-- that can return basic information based on the spec ID lists we have
-- in Statics.lua.
if not GetSpecializationInfoByID then
  function GetSpecializationInfoByID(specID)
    if not specID or not GSE.Static or not GSE.Static.wotlkSpecIDList then
      return nil
    end

    local specName = GSE.Static.wotlkSpecIDList[specID]
    if not specName then
      return nil
    end

    -- id, name, description, icon, role, class
    -- We can only reliably return some of these.
    -- The specName is in the format "SPECNAME - CLASS"
    local parts = split(specName, " - ")
    local sName = parts[1]
    local sClass = parts[2]

    local classID = 0
    if sClass and GSE.Static.wotlkClassIDList then
      for id, name in pairs(GSE.Static.wotlkClassIDList) do
        if string.upper(name) == string.upper(sClass) then
          classID = id
          break
        end
      end
    end

    local icon = "Interface\\Icons\\INV_Misc_QuestionMark" -- Default icon

    -- Attempt to find a real icon from talent tabs
    for i=1, GetNumTalentTabs() do
      local name, tabIcon = GetTalentTabInfo(i)
      if name and sName and string.find(string.upper(sName), string.upper(name)) then
        icon = tabIcon
        break
      end
    end

    return specID, specName, "", icon, "DAMAGER", sClass, classID
  end
end
