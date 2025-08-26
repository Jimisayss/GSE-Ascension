# Port Notes

## Shims
- Added `GSE/API/Shims.lua` providing fallbacks for Retail-only functions such as `GetSpecialization`.

## Ascension Support
- Added `GSE/API/Ascension.lua` detecting Ascension client and resolving spells safely through a cache.

## Limitations
- Spec-based features are disabled on Ascension where `GetSpecialization` is unavailable.
- Unknown spells are skipped with a warning rather than causing errors.
