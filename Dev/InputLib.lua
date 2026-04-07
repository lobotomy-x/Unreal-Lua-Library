
local Cache = _G.Cache or require("API_Cache")
local ImGui = _G.ImGui or require("ImGui")
local fkey = {
    "AnyKey",
    "MouseX","MouseY","Mouse2D","MouseScrollUp","MouseScrollDown","MouseWheelAxis",
    "LeftMouseButton","RightMouseButton","MiddleMouseButton","ThumbMouseButton","ThumbMouseButton2",
    "BackSpace","Tab","Enter","Pause","CapsLock","Escape","SpaceBar","PageUp","PageDown","End","Home","Left","Up","Right","Down","Insert","Delete",
    "Zero","One","Two","Three","Four","Five","Six","Seven","Eight","Nine",
    "A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z",
    "NumPadZero","NumPadOne","NumPadTwo","NumPadThree","NumPadFour","NumPadFive","NumPadSix","NumPadSeven","NumPadEight","NumPadNine",
    "Multiply","Add","Subtract","Decimal","Divide","F1","F2","F3","F4","F5","F6","F7","F8","F9","F10","F11","F12","NumLock","ScrollLock",
    "LeftShift","RightShift","LeftControl","RightControl","LeftAlt","RightAlt","LeftCommand","RightCommand","Semicolon","Equals",
    "Comma","Underscore","Hyphen","Period","Slash","Tilde","LeftBracket","Backslash","RightBracket","Apostrophe","Ampersand",
    "Asterix","Caret","Colon","Dollar","Exclamation","LeftParantheses","RightParantheses","Quote",

    "A_AccentGrave",
    "E_AccentGrave","E_AccentAigu","C_Cedille","Section",


    "Gamepad_Left2D",
    "Gamepad_LeftX","Gamepad_LeftY","Gamepad_Right2D","Gamepad_RightX","Gamepad_RightY",
    "Gamepad_LeftTriggerAxis","Gamepad_RightTriggerAxis","Gamepad_LeftThumbstick","Gamepad_RightThumbstick",
    "Gamepad_Special_Left","Gamepad_Special_Left_X","Gamepad_Special_Left_Y","Gamepad_Special_Right",
    "Gamepad_FaceButton_Bottom","Gamepad_FaceButton_Right","Gamepad_FaceButton_Left","Gamepad_FaceButton_Top",
    "Gamepad_LeftShoulder","Gamepad_RightShoulder","Gamepad_LeftTrigger","Gamepad_RightTrigger","Gamepad_DPad_Up",
    "Gamepad_DPad_Down","Gamepad_DPad_Right","Gamepad_DPad_Left","Gamepad_LeftStick_Up","Gamepad_LeftStick_Down",
    "Gamepad_LeftStick_Right","Gamepad_LeftStick_Left","Gamepad_RightStick_Up","Gamepad_RightStick_Down","Gamepad_RightStick_Right",
    "Gamepad_RightStick_Left",


    "Tilt","RotationRate","Gravity","Acceleration",


    "Gesture_Pinch","Gesture_Flick","Gesture_Rotate",


    "OculusTouch_Left_X_Click","OculusTouch_Left_Y_Click","OculusTouch_Left_X_Touch","OculusTouch_Left_Y_Touch","OculusTouch_Left_Menu_Click",
    "OculusTouch_Left_Grip_Click","OculusTouch_Left_Grip_Axis","OculusTouch_Left_Trigger_Click","OculusTouch_Left_Trigger_Axis",
    "OculusTouch_Left_Trigger_Touch","OculusTouch_Left_Thumbstick_2D","OculusTouch_Left_Thumbstick_X","OculusTouch_Left_Thumbstick_Y",
    "OculusTouch_Left_Thumbstick_Click","OculusTouch_Left_Thumbstick_Touch","OculusTouch_Left_Thumbstick_Up","OculusTouch_Left_Thumbstick_Down",
    "OculusTouch_Left_Thumbstick_Left","OculusTouch_Left_Thumbstick_Right","OculusTouch_Right_A_Click","OculusTouch_Right_B_Click",
    "OculusTouch_Right_A_Touch","OculusTouch_Right_B_Touch","OculusTouch_Right_System_Click","OculusTouch_Right_Grip_Click","OculusTouch_Right_Grip_Axis",
    "OculusTouch_Right_Trigger_Click","OculusTouch_Right_Trigger_Axis","OculusTouch_Right_Trigger_Touch","OculusTouch_Right_Thumbstick_2D",
    "OculusTouch_Right_Thumbstick_X","OculusTouch_Right_Thumbstick_Y","OculusTouch_Right_Thumbstick_Click","OculusTouch_Right_Thumbstick_Touch",
    "OculusTouch_Right_Thumbstick_Up","OculusTouch_Right_Thumbstick_Down","OculusTouch_Right_Thumbstick_Left","OculusTouch_Right_Thumbstick_Right",
}
local imgui_keys = {
    --512
    "Tab",
    "LeftArrow", "RightArrow", "UpArrow", "DownArrow",
    "PageUp", "PageDown", "Home", "End",
    "Insert", "Delete", "Backspace", "Space",
    "Enter", "Escape",
    "LeftCtrl", "LeftShift", "LeftAlt", "WindowsKey",
    "RightCtrl", "RightShift", "RightAlt", "RightSuper", "Menu",

    "0", "1", "2", "3", "4", "5", "6", "7", "8", "9",

    "A","B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X","Y", "Z",
    "F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9", "F10", "F11", "F12",

    "Apostrophe", "Comma", "Minus","Period", "Slash", "Semicolon", "Equal", "LeftBracket", "Backslash", "RightBracket", "GraveAccent", -- tilde
    "CapsLock","ScrollLock", "NumLock", "PrintScreen", "Pause",

    "Keypad0",
    "Keypad1", "Keypad2", "Keypad3",
    "Keypad4", "Keypad5","Keypad6",
    "Keypad7", "Keypad8", "Keypad9",
    "KeypadDecimal", "KeypadDivide", "KeypadMultiply", "KeypadSubtract",
    "KeypadAdd", "KeypadEnter", "KeypadEqual",

    "GamepadStart", "GamepadBack",
     "GamepadFaceLeft", "GamepadFaceRight", "GamepadFaceUp", "GamepadFaceDown",
    "GamepadDpadLeft","GamepadDpadRight","GamepadDpadUp", "GamepadDpadDown",
    "GamepadL1", "GamepadR1", "GamepadL2", "GamepadR2", "GamepadL3", "GamepadR3",
    "GamepadLStickLeft", "GamepadLStickRight", "GamepadLStickUp", "GamepadLStickDown", -- not good for continuous input but maybe you want that
    "GamepadRStickLeft", "GamepadRStickRight", "GamepadRStickUp", "GamepadRStickDown",
    --641
    "MouseLeft", "MouseRight", "MouseMiddle", "MouseX1", "MouseX2", "MouseWheelX", "MouseWheelY"

}
local ImGui_keys_down = {}
local ImGui_keys_prev = {}
local ImGui_keys_pressed = {}
local ImGui_keys_released = {}
local ImGui_double_pressed_keys = {}
local ImGui_mouse_history = {}
local ImGui_mouse_delta = {x = 0, y = 0}


local last_delta = {x = 0, y = 0}
-- Configurable parameters
local MOUSE_SMOOTH_SAMPLES = 2 -- number of frames to average
local MOUSE_ACCEL_THRESHOLD = 0.002 -- threshold before acceleration kicks in
local MOUSE_ACCEL_FACTOR = 1.0175 -- multiplier for acceleration
local sustained_value = 0.013
local mouse_history = {}
local smoothed_mouse = {x = 0, y = 0}
local logbase = 1.01

local function average_mouse()
    local sum_x, sum_y = 0, 0
    for _, pos in ipairs(mouse_history) do
        sum_x = sum_x + pos.x
        sum_y = sum_y + pos.y
    end
    local count = #mouse_history
    return {x = sum_x / count, y = sum_y / count}
end

-- smoothing and constant max turn at screen edge
local function update_mouse_delta()
    local res = imgui.get_display_size()
    local mouse = imgui.get_mouse()

    mouse.x = math.max(0, math.min(mouse.x or 0, res.x))
    mouse.y = math.max(0, math.min(mouse.y or 0, res.y))

    table.insert(mouse_history, 1, {x = mouse.x, y = mouse.y})
    if #mouse_history > MOUSE_SMOOTH_SAMPLES then
        table.remove(mouse_history)
    end

    if #mouse_history > 0 then
        local avg_now = average_mouse()
        local from_center_x = math.abs(mouse.x - (res.x * 0.5))
        local from_center_y = math.abs(mouse.y - (res.y * 0.5))
        local distance = math.sqrt(from_center_x * from_center_x + from_center_y * from_center_y)
        local logdistance = math.log(distance + 1) / math.log(logbase)
        local dx = (avg_now.x - smoothed_mouse.x) / res.x
        local dy = (avg_now.y - smoothed_mouse.y) / res.y

        if math.abs(dx) > math.abs(dy) * 2 then dy = 0 end
        if math.abs(dy) > math.abs(dx) * 2 then dx = 0 end

        local mag = math.sqrt(dx * dx + dy * dy)
        if mag > MOUSE_ACCEL_THRESHOLD then
            local accel = 0.75 + (mag - MOUSE_ACCEL_THRESHOLD) * MOUSE_ACCEL_FACTOR * logdistance
            dx = dx * accel
            dy = dy * accel * 1.2
        end

        ImGui_mouse_delta.x = dx
        ImGui_mouse_delta.y = dy

        smoothed_mouse = avg_now
    else
        ImGui_mouse_delta.x = ImGui_mouse_delta.x
        ImGui_mouse_delta.y = ImGui_mouse_delta.y
        smoothed_mouse = mouse
    end

    if math.abs(ImGui_mouse_delta.x) > 0 then last_delta.x = ImGui_mouse_delta.x end
    if math.abs(ImGui_mouse_delta.y) > 0 then last_delta.y = ImGui_mouse_delta.y end

    for i, axis in ipairs({"x", "y"}) do
        if (res[axis] - mouse[axis]) <= 2 then ImGui_mouse_delta[axis] = sustained_value
        elseif mouse[axis] <= 2 then ImGui_mouse_delta[axis] = -1 * sustained_value
        end
    end

end

local draw_cb_count = 0

local draw_ue_inputs = true
local set_ue_mouse_pos = false
local frame = 0



local function ue_hook_mouse()
    local pc = pc or uevr.api:get_player_controller(0)
    local mouse = imgui.get_mouse()
    if set_ue_mouse_pos and pc ~= nil then
        pc:SetMouseLocation(mouse.x, mouse.y)
    end
    if show_ue_mouse_cursor then
        pcall(function()
            pc.bShowMouseCursor = true
            pc.bEnableMouseOverEvents = true
            pc.bEnableTouchOverEvents = true
            pc.bEnableClickEvents = true
        end)
    end
    if draw_ue_inputs and pc ~= nil then
        local outmouseposX = {}
        local outmouseposY = {}
        local outmousedeltaX = {}
        local outmousedeltaY = {}
        if pc:GetMousePosition(outmouseposX, outmouseposY) then

            imgui.text("UE MouseX: " .. tostring(outmouseposX.result))
            imgui.text("UE MouseY: " .. tostring(outmouseposY.result))
        end
        if pc:GetInputMouseDelta(outmousedeltaX, outmousedeltaY) then
            imgui.text("UE MouseDeltaX: " .. string.format("%.2f", outmousedeltaX.result))
            imgui.text("UE MouseDeltaY: " .. string.format("%.2f", outmousedeltaY.result))
        end
    end

end

local bind_ids = {}
local active_key = ""
local setting_bind = false

function ImGui_drawinputs()

    imgui.push_id("InputOverlay")
    local text = "Keys: "
    for name, v in pairs(current_pressed_keys) do
        if v then text = text.." "..name end
    end

    imgui.text(text)
    local mouse = imgui.get_mouse()

    imgui.text("Mouse X:" .. string.format("%.2f", mouse.x)) imgui.same_line()
    imgui.text(", Y: "..string.format("%.2f", mouse.y))
    imgui.text("MouseDeltaX: " .. string.format("%.2f", ImGui_mouse_delta.x))
    imgui.text("MouseDeltaY: " .. string.format("%.2f", ImGui_mouse_delta.y))
    ue_hook_mouse()
    imgui.pop_id()
end

function ImGui_key_names(range)
    if range then
        if type(range) == "string" then
            local _range = {range, "MouseWheelY"}
            range = _range
        end
        local t = {}
        local start = false
        for idx, val in ipairs(keys)
        do
            if val == range[1] then
                start = true
                table.insert(t, val)
            elseif val == range[2] then
                table.insert(t, val)
                return t
            elseif start then
                table.insert(t, val)
            end
        end
    end
    return keys
end
function ImGui_update_keys()
    -- check everything all at once for low cost using the real enum values
    -- our bindings provide keys as "Key_{Name}" but these are only suitable for checking one at a time
    for i = 512, 647 do
        local key_name = keys[i - 511]
        if last_key_time[key_name] == nil then last_key_time[key_name] = -1 end
        if i ~= 530 then -- windows key
            local prev = current_pressed_keys[key_name] or false
            if imgui.is_key_down(i) then
                current_pressed_keys[key_name] = true
                -- debounce
                if os.clock() - last_key_time[key_name] > 1000 then last_key_time[key_name] = -1 end
            else
                current_pressed_keys[key_name] = false
                if prev then
                    last_key_time[key_name] = os.clock()
                    current_released_keys[key_name] = true
                else
                    current_released_keys[key_name] = false
                end
            end
        end
    end

    update_mouse_delta()
end


local imgui_fkey_map = {
    GraveAccent = "Tilde",
    MouseLeft = "LeftMouseButton",
    MouseRight = "RightMouseButton",
    MouseMiddle = "MiddleMouseButton",
    LeftArrow = "Left",
    UpArrow = "Up",
    RightArrow = "Right",
    DownArrow = "Down",
    MouseX1 = "ThumbMouseButton",
    MouseX2 = "ThumbMouseButton2"
}

local function get_fkey_from_imgui(key)
    return {KeyName = imgui_fkey_map[key] or imgui_keys[key]}

end


local EControllerAnalogStick =
{
    CAS_LeftStick                            = 0,
    CAS_RightStick                           = 1,
    CAS_MAX                                  = 2,
}

local EMouseCursor =
{
    None                                     = 0,
    Default                                  = 1,
    TextEditBeam                             = 2,
    ResizeLeftRight                          = 3,
    ResizeUpDown                             = 4,
    ResizeSouthEast                          = 5,
    ResizeSouthWest                          = 6,
    CardinalCross                            = 7,
    Crosshairs                               = 8,
    Hand                                     = 9,
    GrabHand                                 = 10,
    GrabHandClosed                           = 11,
    SlashedCircle                            = 12,
    EyeDropper                               = 13,
    EMouseCursor_MAX                         = 14,


}




pc = pc or api:get_player_controller(0)
pc_input_comp = pc:get_component("Input")
pc_input = pc.PlayerInput

local function set_mouse_sens(sens)
    pc_input:SetMouseSensitivity(sens)
end

local function toggle_mouse_cursor()

    if pc.bShowMouseCursor then
        pc.bShowMouseCursor = pc.bShowMouseCursor ~= nil and false
        pc.bEnableMouseOverEvents = pc.bEnableMouseOverEvents ~= nil and false
        pc.bEnableClickEvents =  pc.bEnableClickEvents ~= nil and  false
        hookue_mouse = false
    else
        pc.bShowMouseCursor = pc.bShowMouseCursor ~= nil and true
        pc.bEnableMouseOverEvents = pc.bEnableMouseOverEvents ~= nil and true
        pc.bEnableClickEvents =  pc.bEnableClickEvents ~= nil and true
        hookue_mouse = true
    end

end


local imgui_mouse_pos = Vector2f.new(0,0)
local ue_mouse_pos
local ue_mouse_delta
local function inputs_on_frame()
    uevr.sdk.callbacks.on_frame(function()
        imgui_mouse_pos = imgui.get_mouse()
        if hookue_mouse then
            pc:SetMouseLocation(imgui_mouse_pos.x, imgui_mouse_pos.y)
        end
    end)
end



Enums = {EMouseCursor, EControllerAnalogStick}

local fkeys = {}
local function make_fkey(key)
    local fkey = {}
    fkey.KeyName =  key
    fkeys[key] = fkey
    return fkey
end

local VR = _G.VR or require("API_Mod_VR")
local toggle2d = VR.toggle_2d_mode

-- local actions = {
--     Toggle2D = {


--     }

-- }

-- local function make_action(name, func, keytbl)
--     local t = {}
--     t[name] = {
--         action = func,
--         binds = keytbl or {},
--     }
--     return t

-- end
-- --[[
-- local function binds_menu()
-- local panel_shortcuts = {}
-- local key_sets = {}
-- local function get_key_sets()
--         if not key_sets or #key_sets == 0 then
--             key_sets = {}
--             key_sets["Mod Keys"] = ImGui_key_names({"LeftCtrl", "RightAlt"})
--             key_sets["Function Keys"] = ImGui_key_names({"F1", "F12"})
--             key_sets["Numpad Keys"] = ImGui_key_names({"Keypad0", "KeypadEqual"})
--             key_sets["Arrow Keys"] = ImGui_key_names({"LeftArrow", "DownArrow"})
--             key_sets["Symbol Keys"] = ImGui_key_names({"Apostrophe", "GraveAccent"})
--             key_sets["Number Keys"] = ImGui_key_names({"0", "9"})
--             key_sets["GamepadButtons"] = ImGui_key_names({"GamepadStart", "GamepadFaceDown"})
--             key_sets["GamepadLeft"] = ImGui_key_names({"GamepadLStick", "GamepadLStickDown"})
--             extend_table(key_sets["GamepadLeft"], {"GamepadL1","GamepadL2","GamepadL3"})
--             key_sets["GamepadRight"] = ImGui_key_names({"GamepadLStick", "GamepadLStickDown"})
--             extend_table(key_sets["GamepadRight"], {"GamepadR1","GamepadR2","GamepadR3"})
--             key_sets["GamepadDpad"] = ImGui_key_names({"GamepadDpadLeft", "GamepadDpadDown"})
--             key_sets["Mouse Keys"] = ImGui_key_names({"MouseLeft", "MouseWheelY"})
--             key_sets["Letter Keys"] = ImGui_key_names({"A", "Z"})
--         end
--         return key_sets
--     end
-- local function bind_key(action)
--     if imgui.begin_menu(action.." key") then
--         imgui.text("Set a shortcut key/action")
--         for set, keys in orderedPairs(get_key_sets()) do
--             if set ~= "Letter Keys" and set ~= "Number Keys" then
--                 if imgui.begin_menu(set) then
--                     for i, key in ipairs(keys) do
--                         if imgui.menu_item(ImGui_toggle_text(key, ) then
--                             panel_shortcuts[panel_name] = key
--                         end
--                     end
--                   imgui.end_menu()
--                 end
--             end
--         end
--         imgui.end_menu()
--     end
-- end
-- ]]

-- default is -2.5 pitch, 2.5 yaw
function MouseSens(horizontal, vertical)
    pc = pc or api:get_player_controller(0)
    pc.InputYawScale = 1.0 * (horizontal or 1.0)
    pc.InputPitchScale = -1.0 * (vertical or 1.0)
end



function ShowMouseCursor(show, cursor_style)
    pc.bShowMouseCursor = show
    pc.bEnableClickEvents = true
    pc.bEnableMouseOverEvents = true
    if cursor_style then pc.CurrentMouseCursor = EMouseCursor[cursor_style] end
end




local _FKey = setmetatable({}, {
    __call = function(_, key)
        if type(key) == "string" then
        return fkeys[key] ~= nil and fkeys[key].KeyName == key and fkeys[key]
            or make_fkey(key)
        end
    end,
})

function FKey(k)
    return _FKey(k)
end

local text = ""
current_pressed_keys = {}
local draw_inputs = true




function UpdateFKeys()
    uevr.sdk.callbacks.on_post_engine_tick(function(engine, delta)
        for i, key in ipairs(fkey) do

            if pc:IsInputKeyDown(FKey(key)) then
                current_pressed_keys[key] = true
            else
                current_pressed_keys[key] = false
            end
        end
    end)
end

function MouseWheel()
    return pc:GetInputVectorKeyState(FKey("MouseWheelAxis"))
end


function IsKeyDown(key, cb)
    pc = pc or api:get_player_controller(0)
    if pc:IsInputKeyDown(FKey(key)) then
        cb()
        return true
    else
        return false
    end
end

local EControllerAnalogStick =
{
    CAS_LeftStick                            = 0,
    CAS_RightStick                           = 1,
    CAS_MAX                                  = 2,
}
local function get_left_stick()
    pc = pc or api:get_player_controller(0)
    local stickx, sticky = {}, {}
    pc:GetInputAnalogStickState(EControllerAnalogStick["CAS_LeftStick"], stickx, sticky)
    return {stickx.result, sticky.result}
end

local function get_right_stick()
    pc = pc or api:get_player_controller(0)
    local stickx, sticky = {}, {}
    pc:GetInputAnalogStickState(EControllerAnalogStick["CAS_RightStick"], stickx, sticky)
    return {stickx.result, sticky.result}
end


function GetTriggerState(side)
   return pc:GetInputAnalogKeyState(FKey((side == 0 and "Gamepad_LeftTriggerAxis") or "Gamepad_RightTriggerAxis"))
end

function KeyPressDuration(key)
    pc = pc or api:get_player_controller(0)
    return pc:GetInputKeyTimeDown(FKey(key))
end


function MousePos()
    local x = {}
    local y = {}
    pc = pc or api:get_player_controller(0)
    pc:GetMousePosition(x, y)
    return x.result, y.result
end



function SetMousePos(x,y)
    pc = pc or uevr.api:get_player_controller(0)
    pc:SetMouseLocation(x, y)
    pc.bShowMouseCursor = true
end
local function hook_inputs()
    pc = pc or api:get_player_controller(0)
    pc.GetInputAnalogStickState:as_function():set_flag("is_native")
    pc.GetInputAnalogStickState:as_function():hook_ptr(nil, function(fn, obj, locals, result)
                        local whichStick = locals.WhichStick
                        print(whichStick)
                    end)
end
 local text = ""
 local mwheeltxt = ""
function GetScriptPanels()
    return {
        InputTestPanel = function()

           text = ""
           if imgui.collapsing_header("Kismet") then
           

           end
            if imgui.collapsing_header("testing") then
                local mwheel = MouseWheel()
                    mwheeltxt= "MouseWheel "..mwheel:to_string()


                imgui.text(mwheeltxt)
                -- imgui.text("Spacebar "..pc:IsInputKeyDown(FKey("SpaceBar")))

                imgui.text("Left Trigger ".. tostring(GetTriggerState(0)))
                imgui.text("Right Trigger ".. tostring(GetTriggerState(1)))
               imgui.text("Left Analog ")
               imgui.text(inspect(get_left_stick()))
                  imgui.text("Right Analog ")
               imgui.text(inspect(get_right_stick()))
            end
            if imgui.collapsing_header("testing 2") then
                local k = {
                    KeyName = ("SpaceBar")
                    }
                    print(pc:IsInputKeyDown(k))


            end
        end

    }

end

---@enum EMouseCaptureMode
local EMouseCaptureMode = {
    NoCapture = 0,
    CapturePermanently = 1,
    CapturePermanently_IncludingInitialMouseDown = 2,
    CaptureDuringMouseDown = 3,
    CaptureDuringRightMouseDown = 4,
    EMouseCaptureMode_MAX = 5,
}

---@enum EInputEvent
local EInputEvent = {
    IE_Pressed = 0,
    IE_Released = 1,
    IE_Repeat = 2,
    IE_DoubleClick = 3,
    IE_Axis = 4,
    IE_MAX = 5,
}


---@enum EMouseLockMode
local EMouseLockMode = {
    DoNotLock = 0,
    LockOnCapture = 1,
    LockAlways = 2,
    LockInFullscreen = 3,
    EMouseLockMode_MAX = 4,
}
local function get_mouse()

local outmouseposX = {}
local outmouseposY = {}

if pc:GetMousePosition(outmouseposX, outmouseposY) then
    return Vector2f.new(outmouseposX.result, outmouseposY.result)
end
end
local function get_mouse_movement()


local outmousedeltaX = {}
local outmousedeltaY = {}

 pc:GetInputMouseDelta(outmousedeltaX, outmousedeltaY)
    return outmousedeltaX.result, outmousedeltaY.result

end

return Inputs

