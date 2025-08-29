local GSE = GSE
local L = GSE.L

local Statics = GSE.Static
local GetSpecialization=GetSpecialization or GSE.GetCurrentSpecID
if not GetSpecialization then
	GetSpecialization=GSE.GetCurrentSpecID
end
--- Return the characters current spec id
function GSE.GetSpecialization()
  return GSE.GetCurrentSpecID()
end

function GSE.GetCurrentSpecID()
  if GSE.IsAscension() then
    return 11, "HERO", "Interface\\Icons\\INV_Misc_MonsterClaw_04" -- Return Hero spec for Ascension
  end
  local activeSpec = GetActiveTalentGroup()
  local maxpointspents=0
  local  primarytree=0
  for tab = 1, GetNumTalentTabs() do
    local tabname, tabicon, nopointsSpent, tabbackground, tabpreviewPointsSpent = GetTalentTabInfo(tab,false,false,activeSpec)
    if (nopointsSpent>maxpointspents) then
        maxpointspents=nopointsSpent
        primarytree=tab
    end
    if (primarytree==0) then
        primarytree=1
    end
  end

  local name1,icon=GetTalentTabInfo(primarytree,false,false,activeSpec);
  if name1 then
    name1=string.upper(name1)
  else
    name1 = ""
  end
  local specid;

  for k,v in pairs(Statics.wotlkSpecIDList) do
    local searchStr = v and string.upper(v) or ""
    local st,ed=string.find(searchStr,name1)
    local isClass,isClass1=UnitClass("player")
    isClass = isClass and string.upper(isClass) or ""
    isClass1 = isClass1 and string.upper(isClass1) or ""
    local st1,ed1=string.find(searchStr,isClass)
    local st2,ed2=string.find(searchStr,isClass1)
    if(st~=nil) then
      if(st1~=nil or st2~=nil) then
        specid=k
      end
    end
  end
  return specid,name1,icon;
end

--- Return the characters class id
function GSE.GetCurrentClassID()
  if GSE.IsAscension() then
    return 11 -- Return Hero class ID for Ascension
  end
  local class1, class = UnitClass("player")
  local currentclassId1=""
  for k,v in pairs(Statics.wotlkClassIDList) do
    if (string.upper(v)==string.upper(class) or string.upper(v)==string.upper(class1)) then
      currentclassId1=k
    end
  end
  return currentclassId1
end

--- Return the characters class id
function GSE.GetCurrentClassNormalisedName()
  if GSE.IsAscension() then
    return "HERO" -- Return Hero class name for Ascension
  end
  local _, classnormalisedname = UnitClass("player")
  return string.upper(classnormalisedname)
end

function GSE.GetClassIDforSpec(specid)
  if GSE.IsAscension() then
    return 11 -- Return Hero class ID for Ascension
  end
  local value,classid,class;
  for k,v in pairs(Statics.wotlkClassIDList) do
    if (k==specid) then
      classid=k
    end
  end

  for k,v in pairs(Statics.wotlkSpecIDList) do
    if (k==specid) then
      local idx=string.find(v," - ")
      if(idx~=nil) then
        class=string.sub(v,idx+3)
      end
      for k1,v1 in pairs(Statics.wotlkClassIDList) do
        if (string.upper(v1)==string.upper(class)) then
          classid=k1
        end
      end
    end
  end
   return classid
end

function GSE.GetClassIcon(classid)
  local classicon = {}
   classicon[1] = "Interface\\Icons\\inv_sword_27" -- Warrior
  classicon[2] = "Interface\\Icons\\ability_thunderbolt" -- Paladin
  classicon[3] = "Interface\\Icons\\inv_weapon_bow_07" -- Hunter
  classicon[4] = "Interface\\Icons\\inv_throwingknife_04" -- Rogue
  classicon[5] = "Interface\\Icons\\INV_Staff_30" -- Priest
  classicon[6] = "Interface\\Icons\\Spell_Deathknight_ClassIcon" -- Death Knight
  classicon[7] = "Interface\\Icons\\Spell_Nature_BloodLust" -- SWhaman
  classicon[8] = "Interface\\Icons\\INV_Staff_13" -- Mage
  classicon[9] = "Interface\\Icons\\Spell_Nature_FaerieFire" -- Warlock
  classicon[10] = "Interface\\Icons\\INV_Misc_MonsterClaw_04" -- Monk
  classicon[11] = "Interface\\Icons\\INV_Misc_MonsterClaw_04" -- Hero
  classicon[12] = "Interface\\Icons\\inv_weapon_bow_07" -- DEMONHUNTER
  return classicon[classid]

end

--- Check if the specID provided matches the plauers current class.
function GSE.isSpecIDForCurrentClass(specID)
  if GSE.IsAscension() then
    return true -- Ascension heroes can use any spec
  end
  for k,v in pairs(Statics.wotlkSpecIDList) do
	if (k==specID) then
		local value=Statics.wotlkSpecIDList[specID]
		if value then
			local last = string.split( value, "% " )
	    local class=string.upper(last[#last])
		local currentenglishclass, currentclassDisplayName = UnitClass("player")

		currentenglishclass=string.upper(currentenglishclass)
		local currentclassId=string.upper(currentclassDisplayName)

		for k1,v1 in pairs(Statics.wotlkClassIDList) do
			if (string.upper(v1)==string.upper(class)) then currentclassId=k1 end
		end

		return (class==currentenglishclass or specID==currentclassId)
		end
	end
  end
  return false
end


function GSE.GetDynamicSpecList()
  if not GSE.DynamicSpecList or GSE.IsAscension() then
    if GSE.IsAscension() then
      GSE.DynamicSpecList = {
        [0] = "Global",
        [11] = "Hero",
      }
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
  if GSE.IsAscension() then
    return "" -- Disable talent export for Ascension
  end
  local talents = ""
    for talentTier = 1, 7 do
   talents = talents .. ("?" .. ",")
  end
  return talents
end


--- Experimental attempt to load a WeakAuras string.
function GSE.LoadWeakauras(str)
  local WeakAuras = WeakAuras

  if WeakAuras then
    WeakAuras.ImportString(str)
  end
end
