# Port Notes

## Shims
- Added `GSE/API/Shims.lua` providing fallbacks for Retail-only functions such as `GetSpecialization`.

## Ascension Support
- Added `GSE/API/Ascension.lua` detecting Ascension client and resolving spells safely through a cache.
- Bundled a minimal `LibHealComm-3.0` stub to prevent errors on Ascension's custom `HERO` class.
- Stub registers with a high version and loads before other libraries so external copies from Ace3 addons are ignored.
- Stub exposes a global `LibHealComm` and duplicate library references were removed from `GSE.toc` to avoid conflicts.

## Limitations
- Spec-based features are disabled on Ascension where `GetSpecialization` is unavailable.
- Unknown spells are skipped with a warning rather than causing errors.
