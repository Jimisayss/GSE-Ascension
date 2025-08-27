local GNOME, _ = ...

local GSE = GSE

local currentclassDisplayName, currentenglishclass=UnitClass("player")
local currentclassId = GSE.GetCurrentClassID()
local L = GSE.L
local Statics = GSE.Static

local GCD, GCD_Update_Timer
GSE.EventHandlers = GSE.EventHandlers or {}

function GSE.RegisterInternalEvent(evt, handler)
  if type(evt) ~= "string" or type(handler) ~= "function" then return end
  GSE.EventHandlers[evt] = GSE.EventHandlers[evt] or {}
  table.insert(GSE.EventHandlers[evt], handler)
end

function GSE.DispatchInternalEvent(evt, ...)
  local handlers = GSE.EventHandlers[evt]
  if handlers then
    for _,h in ipairs(handlers) do
      local ok, err = pcall(h, evt, ...)
      if not ok then
        GSE.Log("ERROR", err, evt)
      end
    end
  end
end



--- This function is used to debug a sequence and trace its execution.
function GSE.TraceSequence(button, step, task)
  if GSE.UnsavedOptions.DebugSequenceExecution then
    -- Note to self do i care if its a loop sequence?
    local isUsable, notEnoughMana = IsUsableSpell(task)
    local usableOutput, manaOutput, GCDOutput, CastingOutput
    if isUsable then
      usableOutput = GSEOptions.CommandColour .. "Able To Cast" .. Statics.StringReset
    else
      usableOutput =  GSEOptions.UNKNOWN .. "Not Able to Cast" .. Statics.StringReset
    end
    if notEnoughMana then
      manaOutput = GSEOptions.UNKNOWN .. "Resources Not Available".. Statics.StringReset
    else
      manaOutput =  GSEOptions.CommandColour .. "Resources Available" .. Statics.StringReset
    end
    local castingspell, _, _, _, _, _, castspellid, _ = UnitCastingInfo("player")
    if not GSE.isEmpty(castingspell) then
      CastingOutput = GSEOptions.UNKNOWN .. "Casting " .. castingspell .. Statics.StringReset
    else
      CastingOutput = GSEOptions.CommandColour .. "Not actively casting anything else." .. Statics.StringReset
    end
    GCDOutput =  GSEOptions.CommandColour .. "GCD Free" .. Statics.StringReset
    if GCD then
      GCDOutput = GSEOptions.UNKNOWN .. "GCD In Cooldown" .. Statics.StringReset
    end
    GSE.Log("DEBUG", button .. "," .. step .. "," .. (task and task or "nil")  .. "," .. usableOutput .. "," .. manaOutput .. "," .. GCDOutput .. "," .. CastingOutput, Statics.SequenceDebug)
  end
end



function GSE:UNIT_FACTION()
  --local pvpType, ffa, _ = GetZonePVPInfo()
  if UnitIsPVP("player") then
    GSE.PVPFlag = true
  else
    GSE.PVPFlag = false
  end
  GSE.Log("DEBUG", "PVP Flag toggled to " .. tostring(GSE.PVPFlag), Statics.DebugModules["API"])
  GSE.ReloadSequences()
end

function GSE:PARTY_MEMBERS_CHANGED()
  if (InCombatLockdown()~=1) then
    -- Handle what GROUP_ROSTER_UPDATE did (doesn't exist in 3.3.5a)
    -- Serialisation stuff
    GSE.sendVersionCheck()
    if not GSE.isEmpty(GSE.UnsavedOptions) and not GSE.isEmpty(GSE.UnsavedOptions["PartyUsers"]) then
      for k,v in pairs(GSE.UnsavedOptions["PartyUsers"]) do
        if not (UnitInParty(k) or UnitInRaid(k)) then
          -- Take them out of the list
          GSE.UnsavedOptions["PartyUsers"][k] = nil
        end
      end
    end
    -- Group Team stuff
    GSE:ZONE_CHANGED_NEW_AREA()
  end
end
function GSE:ZONE_CHANGED_NEW_AREA()
 local inInstance, instancetype = IsInInstance()
  local name, type1, difficulty, difficultyName, maxPlayers, playerDifficulty, isDynamicInstance = GetInstanceInfo()
  if type1 == "arena" or type1 == "pvp" then
    GSE.PVPFlag = true
  else
    GSE.PVPFlag = false
  end
  -- Mythic difficulty doesn't exist in 3.3.5a
  GSE.inMythic = false
  if ((IsInInstance()==1) and (instancetype=="party")) then
    GSE.inDungeon = true
  else
    GSE.inDungeon = false
  end
  
  -- In 3.3.5a: 2=Heroic 5-man/25-man normal, 3=10-man Heroic, 4=25-man Heroic
  if (difficulty == 2 or difficulty == 3 or difficulty == 4) then
    GSE.inHeroic = true
  else
    GSE.inHeroic = false
  end
  if ((IsInInstance()==1) and (instancetype=="raid")) then
    GSE.inRaid = true
  else
    GSE.inRaid = false
  end
  if (GetNumGroupMembers()>0) then
    GSE.inParty = true
  else
    GSE.inParty = false
  end
  GSE.Log("DEBUG", "PVP: " .. tostring(GSE.PVPFlag) .. " inMythic: " .. tostring(GSE.inMythic) .. " inRaid: " .. tostring(GSE.inRaid) .. " inDungeon " .. tostring(GSE.inDungeon) .. " inHeroic " .. tostring(GSE.inHeroic), Statics.DebugModules["API"])
  GSE.ReloadSequences()
end

function GSE:PLAYER_ENTERING_WORLD()
  GSE.PrintAvailable = true
  GSE.PerformPrint()
end

function GSE:ADDON_LOADED(event, addon)
  if addon ~= "GSE" then return end

  if GSE.isEmpty(GSELibrary) then
    GSELibrary = {}
  end
  if GSE.isEmpty(GSELibrary[GSE.GetCurrentClassID()]) then
    GSELibrary[GSE.GetCurrentClassID()] = {}
  end
  if GSE.isEmpty(GSELibrary[0]) then
    GSELibrary[0] = {}
  end

  local counter = 0

  for k,v in pairs(GSELibrary[GSE.GetCurrentClassID()]) do
    counter = counter + 1
    if v.MacroVersions and type(v.MacroVersions) == "table" then
      for i,j in ipairs(v.MacroVersions) do
        GSELibrary[GSE.GetCurrentClassID()][k].MacroVersions[tonumber(i)] = GSE.UnEscapeSequence(j)
      end
    end
    -- Create/update the functional button for this sequence
    if v.MacroVersions and v.Default and v.MacroVersions[v.Default] then
      GSE.UpdateSequence(k, v.MacroVersions[v.Default])
    end
  end
  if not GSE.isEmpty(GSELibrary[0]) then

    for k,v in pairs(GSELibrary[0]) do
      counter = counter + 1
      if v.MacroVersions and type(v.MacroVersions) == "table" then
        for i,j in ipairs(v.MacroVersions) do
          GSELibrary[0][k].MacroVersions[tonumber(i)] = GSE.UnEscapeSequence(j)
        end
      end
      -- Create/update the functional button for this global sequence
      if v.MacroVersions and v.Default and v.MacroVersions[v.Default] then
        GSE.UpdateSequence(k, v.MacroVersions[v.Default])
      end
    end
  end

  GSE.Log("DEBUG", "I am loaded")
  GSEOptions.UnfoundSpells = {}
  GSEOptions.ErroneousSpellID = {}
  GSEOptions.UnfoundSpellIDs = {}
  GSE:ZONE_CHANGED_NEW_AREA()
  
  -- Ensure all macro strings are updated after loading
  GSE.UpdateMacroString()
  
  GSE:SendMessage(Statics.CoreLoadedMessage)

  -- Initialize the Combat Queue
  if GSE.CombatQueue and GSE.CombatQueue.Initialize then
    GSE.CombatQueue:Initialize()
  end

  -- Initialize the Spell Cache
  if GSE.SpellCache and GSE.SpellCache.Initialize then
    GSE.SpellCache:Initialize()
  end

  -- Register the Sample Macros
  local seqnames = {}
  table.insert(seqnames, "Assorted Sample Macros")
  GSE.RegisterAddon("Samples", GSE.VersionString, seqnames)
  
  -- Load the documented sample macros if available
  if GSE.LoadDocumentedSampleMacros then
    GSE.LoadDocumentedSampleMacros()
  end

  -- If on Ascension, merge the Ascension sample macros into the global samples.
  if GSE.IsAscension and GSE.IsAscension() and GSE.AscensionSampleMacros then
    if not GSE.Static.SampleMacros[0] then
      GSE.Static.SampleMacros[0] = {}
    end
    for k, v in pairs(GSE.AscensionSampleMacros) do
      GSE.Static.SampleMacros[0][k] = v
    end
  end

  GSE:RegisterMessage(Statics.ReloadMessage, "processReload")

  LibStub("AceConfig-3.0"):RegisterOptionsTable("GSE", GSE.GetOptionsTable(), {"gseo"})
  LibStub("AceConfigDialog-3.0"):AddToBlizOptions("GSE", "|cffff0000GSE:|r Gnome Sequencer Enhanced")
  if not GSEOptions.HideLoginMessage then
    GSE.Print(GSEOptions.AuthorColour .. L["GnomeSequencer-Enhanced loaded.|r  Type "] .. GSEOptions.CommandColour .. L["/gs help|r to get started."], GNOME)
    GSE.Print(L["New: Type "] .. GSEOptions.CommandColour .. "/gse loadsamples" .. L["|r to load sample macros for your class."], GNOME)
  end

  -- added in 2.1.0
  if GSE.isEmpty(GSEOptions.MacroResetModifiers) then
    GSEOptions.MacroResetModifiers = {}
    GSEOptions.MacroResetModifiers["LeftButton"] = false
    GSEOptions.MacroResetModifiers["RightButton"] = false
    GSEOptions.MacroResetModifiers["MiddleButton"] = false
    GSEOptions.MacroResetModifiers["Button4"] = false
    GSEOptions.MacroResetModifiers["Button5"] = false
    GSEOptions.MacroResetModifiers["LeftAlt"] = false
    GSEOptions.MacroResetModifiers["RightAlt"] = false
    GSEOptions.MacroResetModifiers["Alt"] = false
    GSEOptions.MacroResetModifiers["LeftControl"] = false
    GSEOptions.MacroResetModifiers["RightControl"] = false
    GSEOptions.MacroResetModifiers["Control"] = false
    GSEOptions.MacroResetModifiers["LeftShift"] = false
    GSEOptions.MacroResetModifiers["RightShift"] = false
    GSEOptions.MacroResetModifiers["Shift"] = false
    GSEOptions.MacroResetModifiers["LeftAlt"] = false
    GSEOptions.MacroResetModifiers["RightAlt"] = false
    GSEOptions.MacroResetModifiers["AnyMod"] = false
  end

  -- Fix issue where IsAnyShiftKeyDown() was referenced instead of IsShiftKeyDown() #327
  if not GSE.isEmpty(GSEOptions.MacroResetModifiers["AnyShift"]) then
    GSEOptions.MacroResetModifiers["Shift"] = GSEOptions.MacroResetModifiers["AnyShift"]
    GSEOptions.MacroResetModifiers["AnyShift"] = nil
  end
  if not GSE.isEmpty(GSEOptions.MacroResetModifiers["AnyControl"]) then
    GSEOptions.MacroResetModifiers["Control"] = GSEOptions.MacroResetModifiers["AnyControl"]
    GSEOptions.MacroResetModifiers["AnyControl"] = nil
  end
  if not GSE.isEmpty(GSEOptions.MacroResetModifiers["AnyAlt"]) then
    GSEOptions.MacroResetModifiers["Alt"] = GSEOptions.MacroResetModifiers["AnyAlt"]
    GSEOptions.MacroResetModifiers["AnyAlt"] = nil
  end

  -- Added in 2.2
  if GSE.isEmpty(GSEOptions.UseVerboseFormat) then
    GSEOptions.UseVerboseFormat = true
  end
end
local function AFTER_UNIT_SPELLCAST_SUCCEEDED()
	GCD = nil
	GSE.Log("DEBUG", "GCD OFF")
end

local myAceTimer = LibStub("AceTimer-3.0"):Embed(GSE)

function GSE:UNIT_SPELLCAST_SUCCEEDED(event, unit, spell)
  if unit == "player" then
    local _, GCD_Timer = GetSpellCooldown(61304)
    GCD = true
	GCD_Update_Timer=myAceTimer:ScheduleTimer(AFTER_UNIT_SPELLCAST_SUCCEEDED, GCD_Timer)
    GSE.Log("DEBUG", "GCD Delay:" .. " " .. GCD_Timer)
    GSE.CurrentGCD = GCD_Timer

    if GSE.RecorderActive then
      GSE.GUIRecordFrame.RecordSequenceBox:SetText(GSE.GUIRecordFrame.RecordSequenceBox:GetText() .. "/cast " .. spell .. "\n")
    end
  end
end

function GSE:PLAYER_REGEN_ENABLED(unit,event,addon)
  if GSEOptions.resetOOC then
    GSE.ResetButtons()
  end
end

function GSE:PLAYER_LOGOUT()
  GSE.PrepareLogout()
end

function GSE:RAID_ROSTER_UPDATE()
  -- Handle raid roster changes
  GSE:PARTY_MEMBERS_CHANGED()
end


-- GSE:RegisterEvent("GROUP_ROSTER_UPDATE") -- Doesn't exist in 3.3.5a, using PARTY_MEMBERS_CHANGED instead
GSE:RegisterEvent('PLAYER_LOGOUT')
GSE:RegisterEvent('PLAYER_ENTERING_WORLD')
GSE:RegisterEvent('PLAYER_REGEN_ENABLED')
GSE:RegisterEvent('ADDON_LOADED')
GSE:RegisterEvent('UNIT_SPELLCAST_SUCCEEDED')
GSE:RegisterEvent("ZONE_CHANGED_NEW_AREA")
GSE:RegisterEvent("UNIT_FACTION")
GSE:RegisterEvent("PARTY_MEMBERS_CHANGED")
GSE:RegisterEvent("RAID_ROSTER_UPDATE") -- 3.3.5a event for raid changes

local function PrintGnomeHelp()
  GSE.Print(L["GnomeSequencer was originally written by semlar of wowinterface.com."], GNOME)
  GSE.Print(L["GSE is a complete rewrite of that addon that allows you create a sequence of macros to be executed at the push of a button."], GNOME)
  GSE.Print(L["Like a /castsequence macro, it cycles through a series of commands when the button is pushed. However, unlike castsequence, it uses macro text for the commands instead of spells, and it advances every time the button is pushed instead of stopping when it can't cast something."], GNOME)
  GSE.Print(L["This version has been modified by TimothyLuke to make the power of GnomeSequencer avaialble to people who are not comfortable with lua programming."], GNOME)
  GSE.Print(L["To get started "] .. GSEOptions.CommandColour .. L["/gs|r will list any macros available to your spec.  This will also add any macros available for your current spec to the macro interface."], GNOME)
  GSE.Print(L["The command "] .. GSEOptions.CommandColour .. L["/gs showspec|r will show your current Specialisation and the SPECID needed to tag any existing macros."], GNOME)
  GSE.Print(L["The command "] .. GSEOptions.CommandColour .. L["/gs cleanorphans|r will loop through your macros and delete any left over GS-E macros that no longer have a sequence to match them."], GNOME)
  GSE.Print(L["The command "] .. GSEOptions.CommandColour .. L["/gs checkmacrosforerrors|r will loop through your macros and check for corrupt macro versions.  This will then show how to correct these issues."], GNOME)
  GSE.Print(L["The command "] .. GSEOptions.CommandColour .. L["/gse cleancorrupted|r will remove corrupted sequences that cannot be edited or deleted through the interface."], GNOME)
  GSE.Print(L["The command "] .. GSEOptions.CommandColour .. L["/gse loadsamples|r will load documented sample macros for your current class."], GNOME)
  GSE.Print(L["The command "] .. GSEOptions.CommandColour .. L["/gse version|r will display the current version of GSE."], GNOME)
end

GSE:RegisterChatCommand("gsse", "GSSlash")
---GSE:RegisterChatCommand("gs", "GSSlash")
GSE:RegisterChatCommand("gse", "GSSlash")


-- Functions
--- Handle slash commands
function GSE:GSSlash(input)
  if string.lower(input) == "showspec" then
    if GSE.IsAscension and GSE.IsAscension() then
      GSE.Print(L["Ascension detected: Global profile active."])
    else
      local currentSpecID, specname, specicon = GSE.GetCurrentSpecID()
      GSE.Print(L["Your current Specialisation is "] .. currentSpecID .. ':' .. specname, GNOME)
    end
  elseif string.lower(input) == "help" then
    PrintGnomeHelp()
  elseif string.lower(input) == "cleanorphans" or string.lower(input) == "clean" then
    GSE.CleanOrphanSequences()
  elseif string.lower(input) == "forceclean" then
    GSE.CleanOrphanSequences()
    GSE.CleanMacroLibrary(true)
  elseif string.lower(string.sub(string.lower(input),1,6)) == "export" then
    GSE.Print(GSE.ExportSequence(string.sub(string.lower(input),8)))
  elseif string.lower(input) == "showdebugoutput" then
    StaticPopup_Show ("GS-DebugOutput")
  elseif string.lower(input) == "record" then
    GSE.GUIRecordFrame:Show()
  elseif string.lower(input) == "debug" then
    GSE.GUIShowDebugWindow()
  elseif string.lower(input) == "compilemissingspells" then
    GSE.Print("Compiling Language Table errors.  If the game hangs please be patient.")
    GSE.ReportUnfoundSpells()
    GSE.Print("Language Spells compiled.  Please exit the game and obtain the values from WTF/AccountName/SavedVariables/GSE.lua")
  elseif string.lower(input) == "resetoptions" then
    GSE.SetDefaultOptions()
    GSE.Print(L["Options have been reset to defaults."])
    StaticPopup_Show ("GSE_ConfirmReloadUIDialog")
  elseif string.lower(input) == "updatemacrostrings" then
    -- Convert macros to new format in a one off run.
    GSE.UpdateMacroString()
  elseif string.lower(input) == "movelostmacros" then
    GSE.MoveMacroToClassFromGlobal()
  elseif string.lower(input) == "checkmacrosforerrors" then
    GSE.ScanMacrosForErrors()
  elseif string.lower(input) == "compressstring" then
    GSE.GUICompressFrame:Show()
  elseif string.lower(input) == "loadsamples" then
    if GSE.IsAscension and GSE.IsAscension() then
      if GSE.Static.SampleMacros and GSE.Static.SampleMacros[0] then
        GSE.ImportMacroCollection(GSE.Static.SampleMacros[0])
        GSE.Print(L["Sample macros for Ascension have been loaded. Type /gse to view them."], GNOME)
      else
        GSE.Print(L["Ascension sample macros are not available."], GNOME)
      end
    else
      if GSE.LoadDocumentedSampleMacros then
        GSE.LoadDocumentedSampleMacros()
        GSE.Print(L["Sample macros for your class have been loaded. Type /gse to view them."], GNOME)
      else
        GSE.Print(L["Sample macros are not available."], GNOME)
      end
    end
  elseif string.lower(input) == "version" then
    GSE.Print(string.format(L["GSE Version: %s"], GSE.formatModVersion(GSE.VersionString)), GNOME)
  elseif string.lower(input) == "cleancorrupted" then
    GSE.CleanCorruptedSequences()
  elseif string.lower(input) == "cleartranslatorcache" then
    GSE.ClearTranslatorCache()
    GSE.Print("Translator cache cleared", GNOME)
  elseif string.lower(string.sub(input, 1, 8)) == "loglevel" then
    local requestedLevel = string.lower(string.sub(input, 10))
    local logLevels = {error = 1, warn = 2, info = 3, debug = 4}
    if logLevels[requestedLevel] then
      GSEOptions.LogLevel = logLevels[requestedLevel]
      GSE.Print("Log level set to " .. requestedLevel, "GSE")
    else
      GSE.Print("Invalid log level. Use one of: error, warn, info, debug", "GSE")
    end
  else
    GSE.GUIShowViewer()
  end
end

function GSE:processReload(action, arg)
  if arg == "Samples" then
    GSE.LoadSampleMacros(GSE.GetCurrentClassID())
    GSE.Print(L["The Sample Macros have been reloaded."])
  end
end
