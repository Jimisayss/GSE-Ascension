local GSE = GSE
local L = GSE.L
function myUpdateFix()
  GSE:ProcessOOCQueue()
  GSE.ReloadSequences()

end
--- This function pops up a confirmation dialog.
function GSE.GUIDeleteSequence(currentSeq, iconWidget)
  StaticPopupDialogs["GSE-DeleteMacroDialog"].text = string.format(L["Are you sure you want to delete %s?  This will delete the macro and all versions.  This action cannot be undone."], GSE.GUIEditFrame.SequenceName)
  StaticPopupDialogs["GSE-DeleteMacroDialog"].OnAccept = function(self, data)
      GSE.GUIConfirmDeleteSequence(GSE.GUIEditFrame.ClassID, GSE.GUIEditFrame.SequenceName)
  end
  StaticPopup_Show ("GSE-DeleteMacroDialog")

end

--- This function then deletes the macro
function GSE.GUIConfirmDeleteSequence(classid, sequenceName)
  GSE.GUIViewFrame:Hide()
  GSE.GUIEditFrame:Hide()
  GSE.DeleteSequence(classid, sequenceName)
  GSE.GUIShowViewer()
end


--- Format the text against the GSE Sequence Spec.
function GSE.GUIParseText(editbox)
  if GSEOptions.RealtimeParse then
    text = GSE.UnEscapeString(editbox:GetText())
    returntext = GSE.TranslateString(text , GetLocale(), GetLocale(), true)
    editbox:SetText(returntext)
    editbox:SetCursorPosition(string.len(returntext)+2)
  end
end

function GSE.GUILoadEditor(key, incomingframe, recordedstring)
  local classid
  local sequenceName
  local sequence

  if GSE.isEmpty(key) then
    classid = GSE.GetCurrentClassID()
    sequenceName = GSE.getSequenceName()
	GSE.isNewFirstTimeCreated=true
    sequence = {
      ["Author"] = GSE.GetCharacterName(),
      ["Talents"] = GSE.GetCurrentTalents(),
      ["Default"] = 1,
      ["SpecID"] = GSE.GetCurrentSpecID();
      ["MacroVersions"] = {
        [1] = {
          ["PreMacro"] = {},
          ["PostMacro"] = {},
          ["KeyPress"] = {},
          ["KeyRelease"] = {},
          ["StepFunction"] = "Sequential",
          [1] = "/say Hello",
        }
      },
    }
    if not GSE.isEmpty(recordedstring) then
      sequence.MacroVersions[1][1] = nil
      sequence.MacroVersions[1] = GSE.SplitMeIntolines(recordedstring)
    end
  else
    elements = GSE.split(key, ",")
    classid = tonumber(elements[1])
    sequenceName = elements[2]

    -- Check if the library and sequence exist before cloning
    if GSELibrary[classid] and GSELibrary[classid][sequenceName] then
      sequence = GSE.CloneSequence(GSELibrary[classid][sequenceName], true)
    end

    -- If sequence is still nil, don't create a fallback - this prevents corruption
    if not sequence then
      GSE.Print("Error: Could not load sequence '" .. (sequenceName or "unknown") .. "' for class " .. (classid or "unknown") .. ". Please recreate this sequence.")
      -- Close the editor and return to viewer
      if GSE.GUIEditFrame then
        GSE.GUIEditFrame:Hide()
      end
      if GSE.GUIViewFrame then
        GSE.GUIViewFrame:Show()
      end
      return
    end
	GSE.isNewFirstTimeCreated=false
  end
  GSE.GUIEditFrame.SequenceName = sequenceName
  GSE.GUIEditFrame.Sequence = sequence
  GSE.GUIEditFrame.ClassID = classid
  GSE.GUIEditFrame.Default = sequence.Default or 1
  GSE.GUIEditFrame.PVP = sequence.PVP or sequence.Default or 1
  GSE.GUIEditFrame.Mythic = sequence.Mythic or sequence.Default or 1
  GSE.GUIEditFrame.Raid = sequence.Raid or sequence.Default or 1
  GSE.GUIEditFrame.Dungeon = sequence.Dungeon or sequence.Default or 1
  GSE.GUIEditFrame.Heroic = sequence.Heroic or sequence.Default or 1
  GSE.GUIEditFrame.Party = sequence.Party or sequence.Default or 1
  GSE.GUIEditorPerformLayout(GSE.GUIEditFrame)
  GSE.GUIEditFrame.ContentContainer:SelectTab("config")
  incomingframe:Hide()
  if not InCombatLockdown() then
	myUpdateFix()
	GSE.GUIEditFrame:Show()
  end
  GSE.isNewFirstTimeCreated=false
end

function GSE.getSequenceName()
  local _, specname, _ = GSE.GetCurrentSpecID()
  specname = specname or "UnknownSpec"
  local newSeqName = "New" .. specname .. GetTime()
  newSeqName = GSE.TrimWhiteSpace(GSE.LowerAndReplaceSpecialCharacters(newSeqName))
  if GSE.isEmpty(newSeqName) then
    newSeqName = "GSE_New_Macro_" .. GetTime()
  end
  return newSeqName
end

function GSE.GUIUpdateSequenceList()
  local names = GSE.GetSequenceNames()
  GSE.GUIViewFrame.SequenceListbox:SetList(names)
end

function GSE.GUIToggleClasses(buttonname)
  if buttonname == "class" then
    classradio:SetValue(true)
    specradio:SetValue(false)
  else
    classradio:SetValue(false)
    specradio:SetValue(true)
  end
end


function GSE.GUIUpdateSequenceDefinition(classid, SequenceName, sequence)

  -- Changes have been made so save them
  if sequence.MacroVersions and type(sequence.MacroVersions) == "table" then
    for k,v in ipairs(sequence.MacroVersions) do
      sequence.MacroVersions[k] = GSE.TranslateSequenceFromTo(v, GetLocale(), "enUS", SequenceName)
      sequence.MacroVersions[k] = GSE.UnEscapeSequence(sequence.MacroVersions[k])
    end
  end

  if not GSE.isEmpty(SequenceName) then
    if GSE.isEmpty(classid) then
      classid = GSE.GetCurrentClassID()
    end
    if not GSE.isEmpty(SequenceName) then
      local vals = {}
      vals.action = "Replace"
      vals.sequencename = SequenceName
      vals.sequence = sequence
      vals.classid = classid
      table.insert(GSE.OOCQueue, vals)
      GSE.GUIEditFrame:SetStatusText(string.format(L["Sequence %s saved."], SequenceName))
    end
  end
end


function GSE.GUIGetColour(option)
  hex = string.gsub(option, "#","")
  return tonumber("0x".. string.sub(option,5,6))/255, tonumber("0x"..string.sub(option,7,8))/255, tonumber("0x"..string.sub(option,9,10))/255
end

function  GSE.GUISetColour(option, r, g, b)
  option = string.format("|c%02x%02x%02x%02x", 255 , r*255, g*255, b*255)
end


function GSE:OnInitialize()
    GSE.GUIRecordFrame:Hide()
    GSE.GUIVersionFrame:Hide()
    GSE.GUIEditFrame:Hide()
    GSE.GUIViewFrame:Hide()
end


function GSE.OpenOptionsPanel()
  local config = LibStub:GetLibrary("AceConfigDialog-3.0")
  config:Open("GSE")
  --config:SelectGroup("GSSE", "Debug")

end
