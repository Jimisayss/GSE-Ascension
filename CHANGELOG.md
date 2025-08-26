# Changelog

## [Unreleased]
- Initial Ascension compatibility port with Lua 5.1 fixes.
- Added spell resolution cache and Ascension detection.
- Added defensive event registration and nil-safe string helpers.
- Included stubbed `LibHealComm-3.0` to avoid class lookup errors on Ascension.
- Deduplicated TOC library references and raised stub minor version and load order so it overrides conflicting Ace3 copies and exposes a global for diagnostics.
