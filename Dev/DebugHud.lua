
local function set_target_type(utype)
    pc = pc or api:get_player_controller(0)
    hudInst = pc:GetHUD()
    hudInst:ShowDebugForReticleTargetToggle(utype)
end
local dbgcontroller

local function get_target()
    pc = pc or api:get_player_controller(0)
    hudInst = pc:GetHUD()
    return hudInst.ShowDebugTargetActor
end

local function get_prev_target()
    pc = pc or api:get_player_controller(0)
    hudInst = pc:GetHUD()
    hudInst:PreviousDebugTarget()
    return hudInst.ShowDebugTargetActor
end

local function get_next_target()
    pc = pc or api:get_player_controller(0)
    hudInst = pc:GetHUD()
    hudInst:NextDebugTarget()
    return hudInst.ShowDebugTargetActor
end

local function enable_dbg_cam()
    pc = pc or api:get_player_controller(0)
    hudInst = pc:GetHUD()
    hudInst.bShowHUD = 1
    hudInst.bShowDebugInfo = 1
    hudInst.bShowHitBoxDebugInfo = 1
    hudInst.bShowOverlays = 1
    hudInst.bEnableDebugTextShadow = 1
    api:execute_command("ToggleDebugCamera")
    dbgcontroller = ("DebugCameraController"):find_first_of(false)
end



local function buttons()
if imgui.button("ToggleDebugCamera") then enable_dbg_cam()

end

if imgui.button("get debug target") then print(get_target():to_string())

end

if imgui.button("get next debug target") then print(get_next_target():to_string())

end
if imgui.button("get prev debug target") then print(get_prev_target():to_string())

end
if imgui.button("set target type") then set_target_type(find_fast("PrimitiveComponent"))

end
end