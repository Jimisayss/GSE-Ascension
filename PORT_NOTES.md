# Port Notes

## Shims
- Added `GSE/API/Shims.lua` providing fallbacks for Retail-only functions such as `GetSpecialization`.

## Ascension Support
- Added `GSE/API/Ascension.lua` detecting Ascension client and resolving spells safely through a cache.
- Improved detection via `LibAscensionConfig` for clients where the `portal` CVar isn't set.
- `ResolveSpell` now supports numeric strings and performs a single `GetSpellInfo` lookup.

## Limitations
- Spec-based features are disabled on Ascension where `GetSpecialization` is unavailable.
- Unknown spells are skipped with a warning rather than causing errors.
