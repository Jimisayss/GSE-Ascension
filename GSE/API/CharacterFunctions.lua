local GSE = GSE
local L = GSE.L
local Statics = GSE.Static

--- Returns the player's current Specialization ID.
-- In WotLK, this is determined by finding the talent tree with the most points.
function GSE.GetCurrentSpecID()
  -- On Ascension, specialization is irrelevant, so we return a global spec ID.
  if GSE.IsAscension and GSE.IsAscension() then
    return 0, "Global", "Interface\\Icons\\INV_Misc_QuestionMark"
  end

  local activeSpec = GetActiveTalentGroup()
  local maxPoints = -1
  local primaryTree = 1

  for i = 1, GetNumTalentTabs() do
    local _, _, pointsSpent = GetTalentTabInfo(i, false, false, activeSpec)
    if pointsSpent > maxPoints then
      maxPoints = pointsSpent
      primaryTree = i
    end
  end

  local specName, specIcon = GetTalentTabInfo(primaryTree, false, false, activeSpec)
  if not specName then return 0, "Unknown", "Interface\\Icons\\INV_Misc_QuestionMark" end

  local upperSpecName = string.upper(specName)
  local _, playerClass = UnitClass("player")
  local upperPlayerClass = string.upper(playerClass)

  -- Find the matching Spec ID from our static list.
  -- The list contains names in the format "SPEC - CLASS"
  for id, name in pairs(Statics.wotlkSpecIDList) do
    local upperName = string.upper(name)
    if string.find(upperName, upperSpecName) and string.find(upperName, upperPlayerClass) then
      return id, specName, specIcon
    end
  end

  return 0, specName, specIcon
end

--- Return the characters class id
function GSE.GetCurrentClassID()
  local _, class = UnitClass("player")
  local upperClass = string.upper(class)
  for id, name in pairs(Statics.wotlkClassIDList) do
    if string.upper(name) == upperClass then
      return id
    end
  end
  return 0
end

--- Return the characters class name (unlocalized)
function GSE.GetCurrentClassNormalisedName()
  local _, classnormalisedname = UnitClass("player")
  return string.upper(classnormalisedname)
end

--- Returns the Class ID for a given Spec ID.
function GSE.GetClassIDforSpec(specID)
  -- We use our shim which can derive this information.
  local _, _, _, _, _, _, classID = GetSpecializationInfoByID(specID)
  return classID
end

function GSE.GetClassIcon(classid)
  -- This list could be moved to Statics.lua for consistency.
  local classicon = {
    [1] = "Interface\\Icons\\inv_sword_27", -- Warrior
    [2] = "Interface\\Icons\\ability_thunderbolt", -- Paladin
    [3] = "Interface\\Icons\\inv_weapon_bow_07", -- Hunter
    [4] = "Interface\\Icons\\inv_throwingknife_04", -- Rogue
    [5] = "Interface\\Icons\\INV_Staff_30", -- Priest
    [6] = "Interface\\Icons\\Spell_Deathknight_ClassIcon", -- Death Knight
    [7] = "Interface\\Icons\\Spell_Nature_BloodLust", -- Shaman
    [8] = "Interface\\Icons\\INV_Staff_13", -- Mage
    [9] = "Interface\\Icons\\Spell_Nature_FaerieFire", -- Warlock
    [10] = "Interface\\Icons\\INV_Misc_MonsterClaw_04", -- Monk (Not in WotLK but might be in Ascension)
    [11] = "Interface\\Icons\\INV_Misc_MonsterClaw_04", -- Druid
    [12] = "Interface\\Icons\\inv_weapon_bow_07" -- Demon Hunter (Not in WotLK)
  }
  return classicon[classid]
end

--- Check if the specID provided matches the players current class.
function GSE.isSpecIDForCurrentClass(specID)
  local currentClassID = GSE.GetCurrentClassID()
  local specClassID = GSE.GetClassIDforSpec(specID)
  -- A specID of 0 is global and valid for all classes.
  if specID == 0 then return true end
  return currentClassID == specClassID
end


function GSE.GetDynamicSpecList()
  if not GSE.DynamicSpecList then
    if GSE.IsAscension and GSE.IsAscension() then
      local specs = {[0] = "Global"}
      local asc = LibStub and LibStub:GetLibrary("LibAscensionConfig", true)
      if asc and asc.GetArchetypes then
        for id, info in pairs(asc:GetArchetypes()) do
          specs[id] = info.name or info
        end
      end
      GSE.DynamicSpecList = specs
    else
      GSE.DynamicSpecList = Statics.wotlkSpecIDList
    end
  end
  return GSE.DynamicSpecList
end

function GSE.GetSpecIdHashList()
  local hash = {}
  for k,v in pairs(GSE.GetDynamicSpecList()) do
    hash[v] = k
  end
  return hash
end

function GSE.GetSpecNames()
  local keyset = {}
  for _,v in pairs(GSE.GetDynamicSpecList()) do
    keyset[v] = v
  end
  return keyset
end

--- Returns the Character Name in the form Player@server
function GSE.GetCharacterName()
  return  GetUnitName("player", true) .. '@' .. GetRealmName()
end

--- Returns the current Talent Selections as a string
function GSE.GetCurrentTalents()
  -- GetTalentTierInfo does not exist in 3.3.5a. This needs a WotLK implementation
  -- if we want to preserve the functionality. For now, return empty string.
  return ""
end


--- Experimental attempt to load a WeakAuras string.
function GSE.LoadWeakauras(str)
  local WeakAuras = WeakAuras
  if WeakAuras then
    WeakAuras.ImportString(str)
  end
end
