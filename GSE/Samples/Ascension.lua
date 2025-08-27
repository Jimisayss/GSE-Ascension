-- ============================================================================
--
--      Ascension.lua
--
--  Sample macros for the Project Ascension classless environment.
--  These macros are designed to be movement-friendly and use global scope.
--
-- ============================================================================

local GSE = GSE
local L = GSE.L

-- Ascension Sample Macros
-- These are stored in a separate table and will be merged into the main
-- sample macro table if the Ascension client is detected.
GSE.AscensionSampleMacros = {
  ["Ascension_Melee_Weave"] = {
    Author = "GSE Team",
    SpecID = 0, -- Global Spec ID
    Talents = "",
    Default = 1,
    Help = "A simple melee weaving macro that prioritizes an instant attack and fills with a spammable one.",
    Icon = "Interface\\Icons\\Ability_Warrior_Charge",
    MacroVersions = {
      [1] = {
        StepFunction = "Priority",
        KeyPress = {},
        PreMacro = {},
        "/castsequence reset=combat/target Stormstrike, Sinister Strike, Sinister Strike, Sinister Strike",
        PostMacro = {},
        KeyRelease = {},
      }
    }
  },
  ["Ascension_Caster_Basic"] = {
    Author = "GSE Team",
    SpecID = 0, -- Global Spec ID
    Talents = "",
    Default = 1,
    Help = "A basic caster macro that uses an instant cast spell while moving and a cast-time spell when stationary.",
    Icon = "Interface\\Icons\\Spell_Fire_Fireball",
    MacroVersions = {
      [1] = {
        StepFunction = "Sequential",
        KeyPress = {},
        PreMacro = {
          "/cast [nochanneling,combat,@target,exists,nodead,harm] Moonfire"
        },
        "/cast [nochanneling,combat,@target,exists,nodead,harm] Wrath",
        PostMacro = {},
        KeyRelease = {},
      }
    }
  }
}
