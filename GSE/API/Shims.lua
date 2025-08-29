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
  function C_Timer.After(delay, func)
    return GSE.AscensionCompat.TimerAfter(delay, func)
  end
end

return GSE
