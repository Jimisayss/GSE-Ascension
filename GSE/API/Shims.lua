local GSE = GSE

-- Retail-only API replacements or fallbacks for 3.3.5a
if not GetSpecialization then
  function GetSpecialization()
    return nil
  end
end

if not GetSpecializationInfo then
  function GetSpecializationInfo()
    return nil
  end
end

if not GetSpecializationInfoByID then
  function GetSpecializationInfoByID()
    return nil
  end
end

-- C_Timer does not exist in 3.3.5a
if not C_Timer then
  C_Timer = {}
  local timers = {}
  local frame = CreateFrame("Frame")

  frame:SetScript("OnUpdate", function(self, e)
    for i = #timers, 1, -1 do
      local timer = timers[i]
      timer.elapsed = (timer.elapsed or 0) + e
      if timer.elapsed >= timer.delay then
        if type(timer.func) == "function" then
          pcall(timer.func)
        end
        table.remove(timers, i)
      end
    end
  end)

  function C_Timer.After(delay, func)
    table.insert(timers, {
      delay = delay,
      func = func,
      elapsed = 0
    })
  end
end

return GSE
