
 vr.set_mod_value("FrameworkConfig_AdvancedMode",true)
local VR_ExtremeCompatibilityMode

uevr.sdk.callbacks.on_script_reset(function()
    if not console_spawned then spawn_console() end

    if not VR.checkVR() and not VR_ExtremeCompatibilityMode then
       printOnce("NonVR user or missing runtime, enabling non-vr fixes")
       vr.set_mod_value("VR_ExtremeCompatibilityMode", "true")
       VR_ExtremeCompatibilityMode = true
    elseif VR.checkVR() and VR_ExtremeCompatibilityMode then
        printOnce("VR runtime found disabling non-vr fixes")
        if VR_ExtremeCompatibilityMode then
            vr.set_mod_value("VR_ExtremeCompatibilityMode", "false")

          VR_ExtremeCompatibilityMode = false
      end
  end

end)