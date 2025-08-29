# GSE Ascension: Changelog

This document outlines the key changes made to the retail Gnome Sequencer Enhanced (GSE) addon to make it compatible with the Ascension (WoW 3.3.5) client.

## API Changes (Retail -> 3.3.5)

A compatibility layer (`AscensionCompat.lua`) was created to handle API differences. The following functions were replaced:

*   **Spells:**
    *   `C_Spell.GetSpellInfo()` -> `GetSpellInfo()`
    *   `C_Spell.IsSpellUsable()` -> `IsUsableSpell()`
    *   `C_Spell.GetSpellCooldown()` -> `GetSpellCooldown()`
*   **Specialization:**
    *   `C_SpecializationInfo.*` and `PlayerUtil_GetSpecName()` removed. Spec logic is simplified for the classless model.
*   **Timers:**
    *   `C_Timer.After()` -> `AceTimer-3.0` (`self:ScheduleTimer()`)

## Class & Specialization Model

*   **Classless "Hero" Support:** The addon now treats player ClassIDs 10 and 11 as a "Hero" class, removing all class-specific restrictions on spells and sequences.
*   **No Specializations:** All specialization-related logic has been removed or disabled. The UI no longer shows spec filters.

## Step Functions

*   **Deterministic Priority:** The `Priority` step function has been rewritten to be deterministic and reliable in the 3.3.5 secure environment. It generates a repeating sequence that heavily favors actions at the beginning of the list.

## Macro Management

*   **Single Macro Stub:** GSE now creates exactly one macro stub per sequence in the account-wide macro list to prevent duplicates and character-specific macro clutter.

## Known Limitations

*   The `[known:spell]` macro conditional is not supported in this version as its availability in 3.3.5 is not guaranteed. Sequences should not rely on it.
*   The addon has been tested on the Ascension client (3.3.5), but may have issues on other private servers with different client modifications.
