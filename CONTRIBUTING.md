# Contributing

Thank you for your interest in improving GSE-Ascension.

## Guidelines
- Target WoW 3.3.5a and Lua 5.1 only.
- Avoid retail-only APIs. Use shims in `GSE/API/Shims.lua` when necessary.
- Add nil checks around all string and API operations.
- Test in a clean environment; no errors should occur on load or macro use.
- Run `luacheck` and `make dist` before submitting a PR.

Pull requests should describe what was changed and how it was tested.
