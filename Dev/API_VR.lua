VR = {}
-- incomplete yet in use

local api = uevr.api
local vr = uevr.params.vr
UE5 = _G.UE5
UE4 = _G.UE4
UEVR_Vector3 = UE4 and UEVR_Vector3f or UEVR_Vector3d
UEVR_Vector4 = UE4 and UEVR_Vector4f or UEVR_Vector4d
UEVR_Vector2 = UE4 and UEVR_Vector2f or UEVR_Vector2d

UEVR_Matrix4 = UE4 and UEVR_Matrix4f or UEVR_Matrix4d
UEVR_Rotator = UE4 and UEVR_Rotatorf or UEVR_Rotatord
register_post_tick = _G.register_post_tick

function VR.check_action(action, hand)
    return vr.is_action_active(vr.get_action_handle(action), hand)
end
local pc = api:get_player_controller(0)
local pawn = api:get_local_pawn(0)
local vr_ui = uevr.params.functions.is_drawing_ui

-- This module is specifically for interfacing with UEVR's VR specific functionality
-- There will be some crossover with MotionController


function VR.checkVR()
    return vr.is_runtime_ready() and (vr.is_hmd_active() or vr.is_using_controllers())
end

local function is_cinematic()
    return pc:GetViewTarget():get_class():to_string() == "Class /Script/CinematicCamera.CineCameraActor"
end

local is_aim_disabled = true
local last_aim = 0

function VR.check_aim()
    return vr.get_aim_method()
end

function VR.set_right_controller_aim()
    vr.set_aim_allowed(true)
    vr.set_aim_method(2)
end

function VR.set_last_aim()
    vr.set_aim_allowed(true)
    vr.set_aim_method(last_aim)
end

function VR.set_game_aim()
    vr.set_aim_allowed(true)
    vr.set_aim_method(0)
end

function VR.set_head_aim()
    vr.set_aim_allowed(true)
    vr.set_aim_method(1)
end

function VR.disable_aim()
    vr.set_aim_allowed(false)
    vr.set_aim_method(0)
end


local aim_settings = {}
local aim_checks = {}

local was_drawing_ui = false




function VR.begin_draw_ui()
    local prev_aim = VR.check_aim()
    VR.disable_aim()
    return prev_aim
end
function VR.end_draw_ui(prev_aim)
    vr.set_aim_allowed(true)
    vr.set_aim_method(prev_aim)
end


local aimmeth = 0
uevr.sdk.callbacks.on_frame(function()
    if  vr.is_runtime_ready() and vr.is_hmd_active() and vr.is_using_controllers() then
        if not uevr.params.functions.is_drawing_ui() then
            vr.set_aim_allowed(true)
        else
            vr.set_aim_allowed(false)
        end
    end
end)

function VR.pre_slate_draw()
    if not VR.checkVR() then
        return
    end
    -- if not is_aim_disabled then last_aim = check_aim() end
end
function VR.post_slate_draw()
    if not VR.checkVR() then
        return
    end
    -- pc = api:get_player_controller(0)

    if not (vr_ui() or is_cinematic()) then
        if not is_aim_disabled then
            last_aim = check_aim()
        else
            if last_aim and last_aim ~= 0 then
                vr.set_aim_method(last_aim)
                vr.set_aim_allowed(true)
            end
        end
    else
        vr.disable_aim()
        is_aim_disabled = true
    end
end

function VR.register_aim_check(name, func, method)
    local should_aim
    uevr.sdk.callbacks.on_pre_calculate_stereo_view_offset(function()
            if vr.is_using_controllers() and not uevr.params.functions.is_drawing_ui() then
                should_aim = func()
                if should_aim then
                    vr.set_aim_allowed(true)
                    vr.set_aim_method(method)
                end
            end
    end)
    
end
--[[
    e.g.
            local function is_ranged()
                return using_weapon == pawn.RangedWeapon
            end

            local function not_using_weapon()
                return using_weapon == nil
            end

            local function is_using_melee()
                return using_weapon == pawn.MeleeWeapon
            end

            VR.register_aim_check("EMRangedWeapon", is_ranged, 2)

            VR.register_aim_check("EMMeleeWeapon", is_using_melee, 0)

            VR.register_aim_check("EMNoWeapon", not_using_weapon, 0)

]]--


local xinput_state = nil



local vr_my_config = {
    FrameworkConfig_AdvancedMode=true,
    FrameworkConfig_AlwaysShowCursor=false,
    FrameworkConfig_EnableL3R3Toggle=true,
    FrameworkConfig_FontSize=14,
    FrameworkConfig_ImGuiTheme=0,
    FrameworkConfig_L3R3LongPress=true,
    FrameworkConfig_LogLevel=0,
    FrameworkConfig_MenuKey=45,
    FrameworkConfig_MenuOpen=true,
    FrameworkConfig_RememberMenuState=true,
    FrameworkConfig_ShowCursorKey=18,
    Frontend_RequestedRuntime="openxr_loader.dll",
    LuaLoader_GarbageCollectionBudget=1000.000000,
    LuaLoader_GarbageCollectionHandler=0,
    LuaLoader_GarbageCollectionMajorMultiplier=100.000000,
    LuaLoader_GarbageCollectionMinorMultiplier=1.000000,
    LuaLoader_GarbageCollectionMode=0,
    LuaLoader_GarbageCollectionType=0,
    LuaLoader_LogToDisk=true,
    OpenXR_IgnoreVirtualDesktopChecks=false,
    OpenXR_ResolutionScale=1.000000,
    UI_Cylinder_Angle=90.000000,
    UI_Distance=2.000000,
    UI_FollowView=false,
    UI_Framework_Distance=1.750000,
    UI_Framework_FollowView=false,
    UI_Framework_MouseEmulation=true,
    UI_Framework_Size=2.000000,
    UI_Framework_WristUI=false,
    UI_InvertAlpha=true,
    UI_OverlayType=0,
    UI_Size=2.000000,
    UI_X_Offset=0.000000,
    UI_Y_Offset=0.000000,
    UObjectHook_AttachLerpEnabled=true,
    UObjectHook_AttachLerpSpeed=15.000000,
    UObjectHook_EnabledAtStartup=false,
    UObjectHook_ToggleUObjectHookKey=-1,
    VR_2DScreenMode=false,
    VR_AimInterp=true,
    VR_AimMPSupport=false,
    VR_AimMethod=0,
    VR_AimModifyPlayerControlRotation=false,
    VR_AimSpeed=15.000000,
    VR_AimUsePawnControlRotation=true,
    VR_AsynchronousScan=true,
    VR_CameraForwardOffset=0.000000,
    VR_CameraRightOffset=0.000000,
    VR_CameraUpOffset=0.000000,
    VR_Compatibility_AHUD=true,
    VR_Compatibility_SceneView=false,
    VR_Compatibility_SkipPostInitProperties=true,
    VR_Compatibility_SkipUObjectArrayInit=false,
    VR_Compatibility_SplitScreen=false,
    VR_ControllerPitchOffset=0.000000,
    VR_ControllersAllowed=true,
    VR_CustomZNear=0.010000,
    VR_DPadShifting=true,
    VR_DPadShiftingMethod=2,
    VR_DecoupledPitch=true,
    VR_DecoupledPitchUIAdjust=true,
    VR_DepthScale=1.000000,
    VR_DesktopRecordingFix_V2=true,
    VR_DisableHDRCompositing=true,
    VR_DisableHZBOcclusion=true,
    VR_DisableInstanceCulling=true,
    VR_DisableVRKey=-1,
    VR_EnableCustomZNear=false,
    VR_EnableGUI=true,
    VR_ExtremeCompatibilityMode=false,
    VR_FrameDelayCompensation=0,
    VR_GhostingFix=false,
    VR_GrowRectangleForProjectionCropping=false,
    VR_HorizontalProjectionOverride=0,
    VR_JoystickDeadzone=0.200000,
    VR_LerpCameraPitch=false,
    VR_LerpCameraRoll=false,
    VR_LerpCameraSpeed=1.000000,
    VR_LerpCameraYaw=false,
    VR_LoadBlueprintCode=false,
    VR_LoadCamera0Key=-1,
    VR_LoadCamera1Key=-1,
    VR_LoadCamera2Key=-1,
    VR_MotionControlsInactivityTimer=12.000000,
    VR_MovementOrientation=0,
    VR_NativeStereoFix=false,
    VR_NativeStereoFixSamePass=true,
    VR_PassDepthToRuntime=true,
    VR_RecenterHorizonKey=-1,
    VR_RecenterViewKey=-1,
    VR_RecreateTexturesOnReset=true,
    VR_RenderingMethod=0,
    VR_ResetStandingOriginKey=-1,
    VR_RoomscaleMovement=true,
    VR_RoomscaleMovementSweep=true,
    VR_ShowFPSOverlay=true,
    VR_ShowStatsOverlay=true,
    VR_SnapTurn=false,
    VR_SnapturnJoystickDeadzone=0.0600000,
    VR_SnapturnTurnAngle=45,
    VR_SplitscreenViewIndex=0,
    VR_SwapControllerInputs=false,
    VR_SyncedSequentialMethod=1,
    VR_Toggle2DScreenKey=-1,
    VR_ToggleSlateGUIKey=-1,
    VR_UncapFramerate=true,
    VR_UseFMallocSceneViewExtensions=true,
    VR_VerticalProjectionOverride=0,
    VR_WorldScale=1.000000,
}

local vr_default_config = {
    FrameworkConfig_AdvancedMode=false,
    FrameworkConfig_AlwaysShowCursor=false,
    FrameworkConfig_EnableL3R3Toggle=true,
    FrameworkConfig_FontSize=16,
    FrameworkConfig_ImGuiTheme=0,
    FrameworkConfig_L3R3LongPress=false,
    FrameworkConfig_LogLevel=2,
    FrameworkConfig_MenuKey=45,
    FrameworkConfig_MenuOpen=true,
    FrameworkConfig_RememberMenuState=false,
    FrameworkConfig_ShowCursorKey=-1,
    Frontend_RequestedRuntime="unset",
    LuaLoader_GarbageCollectionBudget=1000.000000,
    LuaLoader_GarbageCollectionHandler=0,
    LuaLoader_GarbageCollectionMajorMultiplier=100.000000,
    LuaLoader_GarbageCollectionMinorMultiplier=1.000000,
    LuaLoader_GarbageCollectionMode=0,
    LuaLoader_GarbageCollectionType=0,
    LuaLoader_LogToDisk=false,
    OpenXR_IgnoreVirtualDesktopChecks=false,
    OpenXR_ResolutionScale=1.000000,
    UI_Cylinder_Angle=90.000000,
    UI_Distance=2.000000,
    UI_FollowView=false,
    UI_Framework_Distance=1.750000,
    UI_Framework_FollowView=false,
    UI_Framework_MouseEmulation=true,
    UI_Framework_Size=2.000000,
    UI_Framework_WristUI=false,
    UI_InvertAlpha=false,
    UI_OverlayType=0,
    UI_Size=2.000000,
    UI_X_Offset=0.000000,
    UI_Y_Offset=0.000000,
    UObjectHook_AttachLerpEnabled=true,
    UObjectHook_AttachLerpSpeed=15.000000,
    UObjectHook_EnabledAtStartup=false,
    UObjectHook_ToggleUObjectHookKey=-1,
    VR_2DScreenMode=false,
    VR_AimInterp=true,
    VR_AimMPSupport=false,
    VR_AimMethod=0,
    VR_AimModifyPlayerControlRotation=false,
    VR_AimSpeed=15.000000,
    VR_AimUsePawnControlRotation=false,
    VR_AsynchronousScan=true,
    VR_CameraForwardOffset=0.000000,
    VR_CameraRightOffset=0.000000,
    VR_CameraUpOffset=0.000000,
    VR_Compatibility_AHUD=false,
    VR_Compatibility_SceneView=false,
    VR_Compatibility_SkipPostInitProperties=false,
    VR_Compatibility_SkipUObjectArrayInit=false,
    VR_Compatibility_SplitScreen=false,
    VR_ControllerPitchOffset=0.000000,
    VR_ControllersAllowed=true,
    VR_CustomZNear=0.010000,
    VR_DPadShifting=true,
    VR_DPadShiftingMethod=0,
    VR_DecoupledPitch=false,
    VR_DecoupledPitchUIAdjust=true,
    VR_DepthScale=1.000000,
    VR_DesktopRecordingFix_V2=true,
    VR_DisableHDRCompositing=true,
    VR_DisableHZBOcclusion=true,
    VR_DisableInstanceCulling=true,
    VR_DisableVRKey=-1,
    VR_EnableCustomZNear=false,
    VR_EnableGUI=true,
    VR_ExtremeCompatibilityMode=false,
    VR_FrameDelayCompensation=0,
    VR_GhostingFix=false,
    VR_GrowRectangleForProjectionCropping=false,
    VR_HorizontalProjectionOverride=0,
    VR_JoystickDeadzone=0.200000,
    VR_LerpCameraPitch=false,
    VR_LerpCameraRoll=false,
    VR_LerpCameraSpeed=1.000000,
    VR_LerpCameraYaw=false,
    VR_LoadBlueprintCode=false,
    VR_LoadCamera0Key=-1,
    VR_LoadCamera1Key=-1,
    VR_LoadCamera2Key=-1,
    VR_MotionControlsInactivityTimer=30.000000,
    VR_MovementOrientation=0,
    VR_NativeStereoFix=false,
    VR_NativeStereoFixSamePass=true,
    VR_PassDepthToRuntime=false,
    VR_RecenterHorizonKey=-1,
    VR_RecenterViewKey=-1,
    VR_RecreateTexturesOnReset=true,
    VR_RenderingMethod=0,
    VR_ResetStandingOriginKey=-1,
    VR_RoomscaleMovement=false,
    VR_RoomscaleMovementSweep=true,
    VR_ShowFPSOverlay=false,
    VR_ShowStatsOverlay=false,
    VR_SnapTurn=false,
    VR_SnapturnJoystickDeadzone=0.200000,
    VR_SnapturnTurnAngle=45,
    VR_SplitscreenViewIndex=0,
    VR_SwapControllerInputs=false,
    VR_SyncedSequentialMethod=1,
    VR_Toggle2DScreenKey=-1,
    VR_ToggleSlateGUIKey=-1,
    VR_UncapFramerate=true,
    VR_UseFMallocSceneViewExtensions=false,
    VR_VerticalProjectionOverride=0,
    VR_WorldScale=1.000000,
}

local vr_config_names = {
    "FrameworkConfig_AdvancedMode",
    "FrameworkConfig_AlwaysShowCursor",
    "FrameworkConfig_EnableL3R3Toggle",
    "FrameworkConfig_FontSize",
    "FrameworkConfig_ImGuiTheme",
    "FrameworkConfig_L3R3LongPress",
    "FrameworkConfig_LogLevel",
    "FrameworkConfig_MenuKey",
    "FrameworkConfig_MenuOpen",
    "FrameworkConfig_RememberMenuState",
    "FrameworkConfig_ShowCursorKey",
    "Frontend_RequestedRuntime",
    "LuaLoader_GarbageCollectionBudget",
    "LuaLoader_GarbageCollectionHandler",
    "LuaLoader_GarbageCollectionMajorMultiplier",
    "LuaLoader_GarbageCollectionMinorMultiplier",
    "LuaLoader_GarbageCollectionMode",
    "LuaLoader_GarbageCollectionType",
    "LuaLoader_LogToDisk",
    "OpenXR_IgnoreVirtualDesktopChecks",
    "OpenXR_ResolutionScale",
    "UI_Cylinder_Angle",
    "UI_Distance",
    "UI_FollowView",
    "UI_Framework_Distance",
    "UI_Framework_FollowView",
    "UI_Framework_MouseEmulation",
    "UI_Framework_Size",
    "UI_Framework_WristUI",
    "UI_InvertAlpha",
    "UI_OverlayType",
    "UI_Size",
    "UI_X_Offset",
    "UI_Y_Offset",
    "UObjectHook_AttachLerpEnabled",
    "UObjectHook_AttachLerpSpeed",
    "UObjectHook_EnabledAtStartup",
    "UObjectHook_ToggleUObjectHookKey",
    "VR_2DScreenMode",
    "VR_AimInterp",
    "VR_AimMPSupport",
    "VR_AimMethod",
    "VR_AimModifyPlayerControlRotation",
    "VR_AimSpeed",
    "VR_AimUsePawnControlRotation",
    "VR_AsynchronousScan",
    "VR_CameraForwardOffset",
    "VR_CameraRightOffset",
    "VR_CameraUpOffset",
    "VR_Compatibility_AHUD",
    "VR_Compatibility_SceneView",
    "VR_Compatibility_SkipPostInitProperties",
    "VR_Compatibility_SkipUObjectArrayInit",
    "VR_Compatibility_SplitScreen",
    "VR_ControllerPitchOffset",
    "VR_ControllersAllowed",
    "VR_CustomZNear",
    "VR_DPadShifting",
    "VR_DPadShiftingMethod",
    "VR_DecoupledPitch",
    "VR_DecoupledPitchUIAdjust",
    "VR_DepthScale",
    "VR_DesktopRecordingFix_V2",
    "VR_DisableHDRCompositing",
    "VR_DisableHZBOcclusion",
    "VR_DisableInstanceCulling",
    "VR_DisableVRKey",
    "VR_EnableCustomZNear",
    "VR_EnableGUI",
    "VR_ExtremeCompatibilityMode",
    "VR_FrameDelayCompensation",
    "VR_GhostingFix",
    "VR_GrowRectangleForProjectionCropping",
    "VR_HorizontalProjectionOverride",
    "VR_JoystickDeadzone",
    "VR_LerpCameraPitch",
    "VR_LerpCameraRoll",
    "VR_LerpCameraSpeed",
    "VR_LerpCameraYaw",
    "VR_LoadBlueprintCode",
    "VR_LoadCamera0Key",
    "VR_LoadCamera1Key",
    "VR_LoadCamera2Key",
    "VR_MotionControlsInactivityTimer",
    "VR_MovementOrientation",
    "VR_NativeStereoFix",
    "VR_NativeStereoFixSamePass",
    "VR_PassDepthToRuntime",
    "VR_RecenterHorizonKey",
    "VR_RecenterViewKey",
    "VR_RecreateTexturesOnReset",
    "VR_RenderingMethod",
    "VR_ResetStandingOriginKey",
    "VR_RoomscaleMovement",
    "VR_RoomscaleMovementSweep",
    "VR_ShowFPSOverlay",
    "VR_ShowStatsOverlay",
    "VR_SnapTurn",
    "VR_SnapturnJoystickDeadzone",
    "VR_SnapturnTurnAngle",
    "VR_SplitscreenViewIndex",
    "VR_SwapControllerInputs",
    "VR_SyncedSequentialMethod",
    "VR_Toggle2DScreenKey",
    "VR_ToggleSlateGUIKey",
    "VR_UncapFramerate",
    "VR_UseFMallocSceneViewExtensions",
    "VR_VerticalProjectionOverride",
    "VR_WorldScale",
}

local vr_config = {}

function VR.backup_game_config()
    local t = {}
    for i, name in ipairs(vr_config_names) do
        t[name] = vr:get_mod_value(name)
    end
    json.dump_file("backup_config.json", t, 4)
    return t
end

VR.backup_game_config()

local actions = {
    HeadsetOnHead = "/actions/default/in/HeadsetOnHead",
    SkeletonLeftHand = "/actions/default/in/SkeletonLeftHand",
    SkeletonRightHand = "/actions/default/in/SkeletonRightHand",
    Pose = "/actions/default/in/Pose",
    GripPose = "/actions/default/in/GripPose",
    Trigger = "/actions/default/in/Trigger",
    Grip = "/actions/default/in/Grip",
    Touchpad = "/actions/default/in/Touchpad",
    TouchpadClick = "/actions/default/in/TouchpadClick",
    Joystick = "/actions/default/in/Joystick",
    JoystickClick = "/actions/default/in/JoystickClick",
    AButtonRight = "/actions/default/in/AButtonRight",
    BButtonRight = "/actions/default/in/BButtonRight",
    AButtonLeft = "/actions/default/in/AButtonLeft",
    BButtonLeft = "/actions/default/in/BButtonLeft",
    AButtonTouchLeft = "/actions/default/in/AButtonTouchLeft",
    BButtonTouchLeft = "/actions/default/in/BButtonTouchLeft",
    AButtonTouchRight = "/actions/default/in/AButtonTouchRight",
    BButtonTouchRight = "/actions/default/in/BButtonTouchRight",
    ThumbRestTouchLeft = "/actions/default/in/ThumbRestTouchLeft",
    ThumbRestTouchRight = "/actions/default/in/ThumbRestTouchRight",
    SystemButton = "/actions/default/in/SystemButton",
    Squeeze = "/actions/default/in/Squeeze",    -- vector1
    Teleport = "/actions/default/in/Teleport",
    DPad_Up = "/actions/default/in/DPad_Up",
    DPad_Right = "/actions/default/in/DPad_Right",
    DPad_Down = "/actions/default/in/DPad_Down",
    DPad_Left = "/actions/default/in/DPad_Left",
    Haptic = "/actions/default/out/Haptic",
}

stereo_view_rotator2 = nil
stereo_view_rotator = nil
stereo_view_position =nil
local temp_stereo_pos, temp_stereo_rot = nil, nil
function VR.UpdateStereoView(position, rotation, is_double)
    if stereo_view_position == nil then
        if is_double then
            stereo_view_position = Vector3d.new(0, 0, 0)
            stereo_view_rotator = Vector3d.new(0, 0, 0)
        else
            stereo_view_position = Vector3f.new(0, 0, 0)
            stereo_view_rotator = Vector3f.new(0, 0, 0)
        end
    else
        stereo_view_position = position
        stereo_view_rotator = rotation
    end
end



function VR.trigger_held(hand)
    return VR.check_action(actions.Trigger, hand == 0 and vr.get_left_joystick_source() or vr.get_right_joystick_source())

end



function VR.left_trigger()
    local leftj = vr.get_left_joystick_source()
    local leftt =  vr.get_action_handle("/actions/default/in/Trigger")
    local isactive = false
    uevr.sdk.callbacks.on_pre_calculate_stereo_view_offset(function(...)
           isactive = vr.is_action_active(leftt, leftj) or false
    end)
    return isactive
end



function VR.grip_held(hand)
    return VR.check_action(actions.Grip, hand == 0 and vr.get_left_joystick_source() or vr.get_right_joystick_source())

end
function VR.check_button(button)
    return xinput_state.Gamepad.wButtons & button ~= 0 or xinput_state.Gamepad.wButtons & button == 0
end

function VR.press_button(button)
    xinput_state.Gamepad.wButtons = state.Gamepad.wButtons | button
end

function VR.unpress_button(button)
    xinput_state.Gamepad.wButtons = state.Gamepad.wButtons & ~(button)
end

function VR.check_thumbpad(hand)
    return VR.check_action("/actions/default/in/ThumbrestTouch", hand)
end
function VR.vibrate(hand, delay, duration, frequency, amplitude)
    vr.trigger_haptic_vibration(delay or 0, duration or 0.5, frequency or 1000, amplitude or 1.0, hand == 1 and vr.get_right_joystick_source() or vr.get_left_joystick_source())
end

function VR.set_2D_mode(enable)
    vr.set_mod_value("VR_2DScreenMode", tostring(enable))
end

function VR.get_2D_mode()
    return vr:get_mod_value("VR_2DScreenMode"):sub(1, 4) == "true"
end

function VR.toggle_2D_mode()
    VR.set_2D_mode(not VR.get_2D_mode())
end

function VR.set_decoupled_pitch(enable)
    vr.set_mod_value("VR_DecoupledPitch", tostring(enable))
end

function VR.get_decoupled_pitch(enable)
    return vr:get_mod_value("VR_DecoupledPitch"):sub(1, 4) == "true"

end

function VR.set_cam_lerp(state, pitch, yaw, roll)
    if pitch == true then
        vr.set_mod_value("VR_LerpCameraPitch", tostring(enable))
    end
    if yaw == true then
        vr.set_mod_value("VR_LerpCameraYaw", tostring(enable))
    end
    if roll == true then
        vr.set_mod_value("VR_LerpCameraRoll", tostring(enable))
    end
end

function VR.set_ui_follow(enable)
    vr.set_mod_value("UI_FollowView", tostring(enable))
end

function VR.set_ui_offset(offset)
    vr.set_mod_value("UI_Distance", offset.Z)
    vr.set_mod_value("UI_X_Offset", offset.X)
    vr.set_mod_value("UI_Y_Offset", offset.Y)
end

function VR.set_ui_size(size)
    vr.set_mod_value("UI_Size", tostring(size))
end

function VR.get_hmd_position(hmd_pos)
    hmd_pos = hmd_pos or UEVR_Vector3.new()
    vr.get_standing_origin(hmd_pos)
    return hmd_pos:as_full_binding()
end

function VR.get_hmd_pose(position, rotation)
    local pos,rot = UEVR_Vector3f.new(), UEVR_Quaternionf.new()
    vr.get_pose(vr.get_hmd_index(), pos, rot)
    position, rotation = pos:as_full_binding(), rot:as_full_binding()
    return position, rotation
end

function VR.get_right_pose(position, rotation)
    local pos, rot = UEVR_Vector3f.new(), UEVR_Quaternionf.new()
    vr.get_pose(vr.get_right_controller_index(), pos, rot)
    position, rotation = pos:as_full_binding(), rot:as_full_binding()
    return position, rotation
end

function VR.get_left_pose(position, rotation)
    local pos, rot = UEVR_Vector3f.new(), UEVR_Quaternionf.new()
    vr.get_pose(vr.get_left_controller_index(), pos, rot)
    position, rotation = pos:as_full_binding(), rot:as_full_binding()
    return position, rotation
end

function VR.set_standing_origin(new_origin)

    vr.set_standing_origin()
end
function VR.recenter_view()
    vr.recenter_view()
end

function VR.recenter_horizon()
    vr.recenter_horizon()
end


function VR.set_vr_table(t)
    for k,v in pairs(t) do
        vr.set_mod_value(k, v)
    end
end

function VR.on_reset()
    local vr_my_config = {}

end

return VR