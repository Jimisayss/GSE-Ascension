local MAJOR, MINOR = "LibHealComm-3.0", 1
local lib = LibStub:NewLibrary(MAJOR, MINOR)
if not lib then return end

-- Basic callback handler so addons can register without error.
local CBH = LibStub("CallbackHandler-1.0")
lib.callbacks = lib.callbacks or CBH:New(lib)

local playerClass = select(2, UnitClass("player"))
-- Ensure the class table exists even if the client uses a custom token like HERO.
lib[playerClass] = lib[playerClass] or {}

function lib:RegisterCallback(...) lib.callbacks:RegisterCallback(...) end
function lib:UnregisterCallback(...) lib.callbacks:UnregisterCallback(...) end
function lib:UnregisterAllCallbacks(...) lib.callbacks:UnregisterAllCallbacks(...) end

-- Stubbed API used by GSE; real heal calculations are not required for macro execution.
function lib:GetHealSize(...) return 0 end
function lib:GetHealTargets(...) return nil end

