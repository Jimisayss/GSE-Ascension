# GSE (Gnome Sequencer Enhanced) for WoW 3.3.5a/Project Ascension -Season 9-

A revival and restoration of Gnome Sequencer Enhanced for World of Warcraft 3.3.5a (Wrath of the Lich King).

## About

Almost all of this is the same as Cerberus's original GSE Backport update. I simply took his and Gummed's legwork and then added a few fixes and added support for use with the Project Ascension client as the original implementation didnt work properly, throwing errors in the ascension client, and had no means to load custom spells and abilities that werent properly registered in the default client.

GSE (Gnome Sequencer Enhanced) is an advanced macro sequencer for World of Warcraft that allows players to create and execute complex macro sequences, bypassing normal macro limitations. This version has been specifically restored and fixed for WoW 3.3.5a compatibility and then further iterated on with fixes and edits to allow usage with Project Ascensions custom client.

**Original Author**: TimothyLuke  
**WotLK Backport**: Gummed (Warmane) - abandoned  
**Revival & Fixes**: cerberus (January 2025)
**Adapted for Ascension**: dmjohn0x (August 2025)

## Features

- Create complex macro sequences that execute with a single button press
- Bypass the 255 character macro limit
- Support for conditional execution (PvP, Raid, Dungeon, Heroic, Party)
- Import/Export sequences for sharing
- Multi-language support
- Sample macros included for all classes
- Full GUI for easy sequence management

## Installation

1. Download the latest release
2. Extract the folder to your `World of Warcraft/Interface/AddOns/` directory
3. Ensure the folder structure looks like:
   ```
   Interface/
   └── AddOns/
           ├── GSE/
           ├── GSE_GUI/
           └── GSE_LDB/
   ```
4. Enable all three GSE modules in your addon selection screen

## Usage

### Basic Commands
- `/gse` - Open the main interface
- `/gse help` - Show help information
- `/gse showspec` - Show your current specialization
- `/gse loadsamples` - Load sample macros for your class
- `/gse debug` - Toggle debug mode

### Creating Your First Macro
1. Type `/gse` to open the interface
2. Click "Create New Sequence"
3. Give your sequence a name
4. Add your macro commands (one per line)
5. Save and create the macro icon
6. Drag the icon to your action bar

### Sample Macros
The addon includes documented sample macros for all classes. Load them with `/gse loadsamples`. Examples include:
- Warrior: Arms DPS, Protection Tank
- Paladin: Retribution DPS, Holy Healing
- Hunter: Beast Mastery, Marksmanship
- And more for all classes!
-For Project Ascension, you'll need to make you macros "Global" when selecting Class/Specialization as Project Ascension is classless.

## What's Been Fixed

This revival addresses numerous issues from the abandoned original:

### Critical Fixes
- ✅ Fixed 20+ typos and naming errors that caused crashes
- ✅ Added comprehensive nil checking to prevent errors
- ✅ Full WoW 3.3.5a API compatibility (removed modern API calls)
- ✅ Fixed global variable pollution
- ✅ Removed 17,548 lines of duplicate code (5MB+ reduction)
- ✅ Fixed performance issues with caching and string operations

### Compatibility Updates
- Removed unsupported events (GROUP_ROSTER_UPDATE, PLAYER_SPECIALIZATION_CHANGED)
- Fixed difficulty checks for 3.3.5a
- Updated talent system detection for pre-MoP design
- Removed BackdropTemplateMixin usage

### New Features
- Added comprehensive sample macros for all classes
- Improved error handling and user messages
- Better defensive programming throughout

## Technical Details

Built using:
- Ace3 Framework
- LibStub for library management
- LibDataBroker for minimap integration
- Lua 5.1 (WoW 3.3.5a embedded)

## Known Limitations

- Some operations fail during combat due to Blizzard's combat lockdown
- Spec detection uses talent tree analysis (pre-specialization era)
- Maximum of 120 character macros + 18 account macros
- Conflicts with TSM cause taint, breaking GSE. Dont use TSM with GSE.

## Contributing

This revival was done by cerberus after Gummed's WotLK backport was abandoned. TimothyLuke continues to maintain GSE for retail WoW. Contributions welcome!

### Development Guidelines
1. Maintain WoW 3.3.5a compatibility
2. Always use local variables (avoid globals)
3. Add nil checks for all WoW API calls
4. Test thoroughly before submitting

## Version History

- **2.2.04-wotlk** (January 2025) - Complete revival for 3.3.5a by cerberus
  - Fixed all critical bugs and crashes
  - Added sample macros for all classes
  - Full compatibility restoration
  - Based on Gummed's backport of GSE 2.x
  
- **2.2.03** - Last known version backported to 3.3.5a by Gummed (abandoned)

Note: Current retail GSE is version 3.2.x and is a complete rewrite by TimothyLuke

## License

Original GSE by TimothyLuke is released under the MIT License.  
This WotLK backport and revival maintains the same open-source spirit.  
See https://github.com/TimothyLuke/GSE-Advanced-Macro-Compiler for the original project.

## Support

There is no support. Cerberus doesnt play Ascension and I'm only going to maintain this as I play new seasons. The official Modding discord for Ascension mods "SzylerAddons" actually despises GSE and doesn't want the addon discussed there. (They see it as harmful to the game rather than an accessibilty mod) So be respectful of their wishes and do not ask for support there.

## Acknowledgments

- **TimothyLuke** - Original author of GSE (still maintains retail version)
- **Gummed** - Created the WotLK 3.3.5a backport
- **semlar** - Original GnomeSequencer creator
- **cerberus** - for Updating Gummed's backport.
- WoW addon community for keeping Classic servers and World of Warcraft as a whole, alive.

---

*This addon is not affiliated with or endorsed by Blizzard Entertainment.*
