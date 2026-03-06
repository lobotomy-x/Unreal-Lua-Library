
local api = uevr.api
local _cache = {}
v4f = function(t) return Vector4f.new(table.unpack(t)) end
v2f = function(t) return Vector2f.new(table.unpack(t)) end
    local  object_cache = _sol_lua_push_objects_Object
    local  struct_cache = _sol_lua_push_objects_Struct
    local  scriptstruct_cache = _sol_lua_push_objects_ScriptStruct
    local  class_cache = _sol_lua_push_objects_Class
    local  function_cache = _sol_lua_push_objects_Function
    local  property_cache = _sol_lua_push_objects_Property
    local  field_cache = _sol_lua_push_objects_Field
    local  enum_cache = _sol_lua_push_objects_Enum
    local function clean_uevr_cache()
        print("cleaning cache")
        for address, object in pairs(object_cache) do
            -- this just force checks it, if its nil then the field becomes nil which is how we wipe tables anyway
            object_cache[address] = api:to_uobject(address)
            if object_cache[address] == nil then
                class_cache[address] = nil
                struct_cache[address] = nil
                function_cache[address] = nil
            end
            if class_cache[address] then
                _cache[object:get_full_name()] = object
            elseif function_cache[address] then
                _cache[object:get_full_name()] = object
            elseif struct_cache[address] then
               _cache[object:get_full_name()] = object
            end

        end
        collectgarbage("collect")
    end


    setmetatable(_cache, {__mode = "v"})
    function get(input)
        -- clean_uevr_cache()

    if _cache[input] and UEVR_UObjectHook.exists(_cache[input]) then return _cache[input] end
        if type(input) == "string" then
            -- use short names for base engine classes
            if input:sub(1, 5) ~= "Class" and input:sub(1, 12) ~= "ScriptStruct" then
                input = "Class /Script/Engine." .. input
                local temp = api:find_uobject(input)
                if temp ~= nil then
                    _cache[input] = temp
                end
                -- should you pass an object to this function? Hell no but if you do I'm not gonna throw an error
            elseif type(input) == "userdata" then
                return input
                -- take an address because why not
            elseif type(input) == "number" then
                local temp = api:to_uobject(input)
                if temp ~= nil then
                    return temp
                end
            end
        elseif _cache[input] == nil then
            _cache[input] = api:find_uobject(input)
        end
       return UEVR_UObjectHook.exists(_cache[input]) and _cache[input] or api:find_uobject(input)
    end

local kismet_libs = {
Animation = "Class /Script/AnimGraphRuntime.KismetAnimationLibrary",
Material =  "Class /Script/Engine.KismetMaterialLibrary",
Math =      "Class /Script/Engine.KismetMathLibrary",
Rendering = "Class /Script/Engine.KismetRenderingLibrary",
System = "Class /Script/Engine.KismetSystemLibrary",
String = "Class /Script/Engine.KismetStringLibrary",
Text = "Class /Script/Engine.KismetTextLibrary",
StringTable = "Class /Script/Engine.KismetStringTableLibrary",
Guid = "Class /Script/Engine.KismetGuidLibrary",
NodeHelper = "Class /Script/Engine.KismetNodeHelperLibrary",
}

function UEVR_UObject:add_component(uclass)
    local t = api:add_component_by_class(
        (self:is_actor() and self) or self:get_outer(),
        type(uclass) == "string" and get((uclass:endswith("Component") and uclass or uclass.."Component")) or uclass,
        false
    )
    if not t then print(inspect({uclass, self})) end
    t:K2_SetRelativeTransform(self:as_component():GetRelativeTransform(), false, get_hitresult(), false)
    return t
end

local kismet_libs = {
Animation = "Class /Script/AnimGraphRuntime.KismetAnimationLibrary",
Material =  "Class /Script/Engine.KismetMaterialLibrary",
Math =      "Class /Script/Engine.KismetMathLibrary",
Rendering = "Class /Script/Engine.KismetRenderingLibrary",
System = "Class /Script/Engine.KismetSystemLibrary",
String = "Class /Script/Engine.KismetStringLibrary",
Text = "Class /Script/Engine.KismetTextLibrary",
StringTable = "Class /Script/Engine.KismetStringTableLibrary",
Guid = "Class /Script/Engine.KismetGuidLibrary",
NodeHelper = "Class /Script/Engine.KismetNodeHelperLibrary",
}
kismet_cache = {}
Kismet = setmetatable({}, {
            __call = function(_, lib)
                kismet_cache[lib] = kismet_cache[lib] or
                    (kismet_libs[lib] and
                        (UEVR_UObjectHook.get_first_object_by_class(api:find_uobject(kismet_libs[lib]), true)
                        or api:find_uobject(kismet_libs[lib]):get_class_default_object()))
                return kismet_cache[lib]
            end,
            __index = function(_, lib)
               kismet_cache[lib] = kismet_cache[lib] or
                    (kismet_libs[lib] and
                        (UEVR_UObjectHook.get_first_object_by_class(api:find_uobject(kismet_libs[lib]), true)
                        or api:find_uobject(kismet_libs[lib]):get_class_default_object()))
                return kismet_cache[lib]
            end
        })

local flags = {
    is_final=0x1,
    is_required_api=0x2,
    is_blueprint_authority_only=0x4,
    is_blueprint_cosmetic=0x8,
    is_net=0x40,
    is_net_reliable=0x80,
    is_net_request=0x100,
    is_exec=0x200,
    is_native=0x400,
    is_event=0x800,
    is_net_response=0x1000,
    is_static=0x2000,
    is_net_multicast=0x4000,
    is_ubergraph_function=0x8000,
    is_multicast_delegate=0x10000,
    is_public=0x20000,
    is_private=0x40000,
    is_protected=0x80000,
    is_delegate=0x100000,
    is_net_server=0x200000,
    has_out_params=0x400000,
    has_defaults=0x800000,
    is_net_client=0x1000000,
    is_dll_import=0x2000000,
    is_blueprint_callable=0x4000000,
    is_blueprint_event=0x8000000,
    is_blueprint_pure=0x10000000,
    is_editor_only=0x20000000,
    is_const=0x40000000,
    is_net_validate=0x80000000,
}
   flags[0x1]=0x1
   flags[0x2]=0x2
   flags[0x4]=0x4
   flags[0x8]=0x8
   flags[0x40]=0x40
   flags[0x80]=0x80
   flags[0x100]=0x100
   flags[0x200]=0x200
   flags[0x400]=0x400
   flags[0x800]=0x800
   flags[0x1000]=0x1000
   flags[0x2000]=0x2000
   flags[0x4000]=0x4000
   flags[0x8000]=0x8000
   flags[0x10000]=0x10000
   flags[0x20000]=0x20000
   flags[0x40000]=0x40000
   flags[0x80000]=0x80000
   flags[0x100000]=0x100000
   flags[0x200000]=0x200000
   flags[0x400000]=0x400000
   flags[0x800000]=0x800000
   flags[0x1000000]=0x1000000
   flags[0x2000000]=0x2000000
   flags[0x4000000]=0x4000000
   flags[0x8000000]=0x8000000
   flags[0x10000000]=0x10000000
   flags[0x20000000]=0x20000000
   flags[0x40000000]=0x40000000
   flags[0x80000000]=0x80000000
local function check_flag(ufunc, flag)
    if ufunc:get_function_flags() & flags[flag] ~= 0 then
        return true
    end
    return false
end



local function set_flag(ufunc, flag)
    register_flag_to_reset(ufunc, flag)
    -- ufunc:set_function_flags(ufunc:get_function_flags() | ((type(flag) == "string" and flags[flag]) or (type(flag) == "number" and flag)))
    ufunc:set_function_flags(ufunc:get_function_flags() | flags[flag])
end

local function unset_flag(ufunc, flag)
        register_flag_to_set(ufunc, flag)
    ufunc:set_function_flags(ufunc:get_function_flags() & ~  flags[flag])
end

local function set_flag(ufunc, flag)
    if not check_flag(ufunc, flag) then
        set_flag(ufunc, flag)
    end
end

local function unset_flag(ufunc, flag)
    if check_flag(ufunc, flag) then
        unset_flag(ufunc, flag)
    end
end



local function set_flags(_flags)
    for idx, flag in ipairs(_flags) do
        set_flag(self, flag)
    end
end

local function unset_flags(_flags)
    for idx, flag in ipairs(_flags) do
        unset_flag(self, flag)
    end
end

 -- // static void DrawDebugArrow(const class UObject* WorldContextObject, const struct FVector& LineStart, const struct FVector& LineEnd, float ArrowSize, const struct FLinearColor& LineColor, float Duration, float Thickness);
 -- //    static void DrawDebugBox(const class UObject* WorldContextObject, const struct FVector& Center, const struct FVector& Extent, const struct FLinearColor& LineColor, const struct FRotator& Rotation, float Duration, float Thickness);
 -- //    static void DrawDebugCamera(const class ACameraActor* CameraActor, const struct FLinearColor& CameraColor, float Duration);
 -- //    static void DrawDebugCapsule(const class UObject* WorldContextObject, const struct FVector& Center, float HalfHeight, float Radius, const struct FRotator& Rotation, const struct FLinearColor& LineColor, float Duration, float Thickness);
 -- //    static void DrawDebugCircle(const class UObject* WorldContextObject, const struct FVector& Center, float Radius, int32 NumSegments, const struct FLinearColor& LineColor, float Duration, float Thickness, const struct FVector& YAxis, const struct FVector& ZAxis, bool bDrawAxis);
 -- //    static void DrawDebugCone(const class UObject* WorldContextObject, const struct FVector& Origin, const struct FVector& Direction, float Length, float AngleWidth, float AngleHeight, int32 NumSides, const struct FLinearColor& LineColor, float Duration, float Thickness);

function SpawnActor(uclass, parent)
    pc = pc or api:get_player_controller(0)
    local a = api:spawn_object((type(uclass) == "string" and get(uclass)) or uclass or get("Actor"), parent or pc:get_outer())
    if not a.RootComponent then a.RootComponent = a:add_component("Scene") end
    if a then return a end
end





local EViewTargetBlendFunction = {
   VTBlend_Linear    = 0,
   VTBlend_Cubic     = 1,
   VTBlend_EaseIn    = 2,
   VTBlend_EaseOut   = 3,
   VTBlend_EaseInOut = 4,
}

local function FViewTargetTransitionParams(blendTime, blendFunc, blendExponent, bLockOutGoing)
   return {
      BlendTime = blendTime or 1.0,
      BlendFunction = blendFunc or 1,
      BlendExp = blendExponent or 1.1,
      bLockOutgoing = bLockOutGoing or false
   }
end


    local string_to_fname_cache = {}

    local fname_tostring_cache = {}

    FName = setmetatable({}, {__mode = "v",
        __call = function(_, s)
            if not string_to_fname_cache[s] then
               local f = Kismet("String"):Conv_StringToName(s)
               if f then string_to_fname_cache[s] = f end
            end
            return string_to_fname_cache[s]
        end,
    })

local old_vt 
local checked = false
local text_buffer = ""
local float_value = 1.0
local cameraman
local keep_open = nil
pawn = api:get_local_pawn(0)
pc = api:get_player_controller(0)


uevr.lua.add_script_panel("test2", function()
--
    if imgui.button("Add camera actor") then
         old_vt = pc:GetViewTarget()
         cameraman = pc.PlayerCameraManager
         local temp = SpawnActor("Class /Script/Engine.CameraActor", pc)
         cameraman.AnimCameraActor = temp
         pc:ClientMessage("Test Message", UEVR_FName.new())
         pc:ClientSetViewTarget(temp,  FViewTargetTransitionParams())

         temp.CameraComponent.PostProcessSettings = {
    bOverride_GrainJitter = 1,
    GrainJitter = 1,
    bOverride_GrainIntensity = 1,
    GrainIntensity = 12,
}
      end

      if imgui.button("attachment test") then
             local light = SpawnActor("Class /Script/Engine.PointLight", pc)
            light.RootComponent:K2_AttachToComponent(pawn.SkeletalMesh, "", 2, 2, 2, false)
            print(tostring(pawn.SkeletalMesh:BoneIsChildOf("Head", "neck")))

         -- for i, flag in pairs(flags) do
         --    print(i) print(check_flag(Kismet.System.DrawDebugCamera:as_function(),flag))
         -- end
         -- Kismet.System:DrawDebugCamera(pc.PlayerCameraManager.AnimCameraActor, Kismet.Math:LinearColor_Yellow() , 10)
      end


 if imgui.button("reset camera actor") then
   pc:ClientSetViewTarget(old_vt or api:get_local_pawn(0),  FViewTargetTransitionParams())
 end

   if imgui.button("Draw debug capsules") then
pawn = pawn or  api:get_local_pawn(0)
            shape = pawn.CapsuleComponent

            shape:SetHiddenInGame(false, false)
            shape.bAutoActivate = true
            shape:SetVisibility(true, true)
            shape:SetRenderInMainPass(true)
            shape:SetRenderCustomDepth(true)

            shape.ShapeColor = {R = 255, G = 0, B = 0, A = 255}
         end
end)
local function donothing()

end


         -- imgui.begin_window("TEST###test")
         -- imgui.begin_child_window("child",  imgui.get_window_size() * 0.5, true)
         -- if imgui.begin_menu("menu", true) then
         --    if imgui.menu_item("I do nothing") then donothing() end
         --    local c, nv = imgui.slider_float("Float Slider", float_value, 0.01, 3.0)
         --    if c and float_value ~= tempscalar then float_value = nv end
         --    local c, nt, selection_start, selection_end = imgui.input_text_multiline("InputText", text_buffer, Vector2f.new(200, 200))
         --    if c then text_buffer = nt end
         --    imgui.begin_group()
         --    local c, nv = imgui.checkbox("Checkbox", checked)
         --    if c then checked = nv end
         --    imgui.same_line()
         --    imgui.text(checked and "Doing thing!" or "Do thing?")
         --    imgui.end_group()
         --    imgui.end_menu()

         -- end
         -- if imgui.begin_menu("menu2") then
         --    imgui.text("hi")
         --  imgui.end_menu()

         -- end
         -- imgui.end_child_window()
         -- imgui.end_window()

        --  imgui.begin_window("DIFFERENT NAME###test")
        --  local text = "test2"
        --  imgui.text(text)
        --  if imgui.begin_popup_context_item("Context") then
        --     if imgui.menu_item("Copy text") then
        --         imgui.set_clipboard(text)
        --         imgui.close_current_popup()
        --     end
        --     imgui.end_popup()
        -- end
        --  imgui.end_window()


   -- end)
    local statics = nil
    function Statics()
            statics = statics or api:find_uobject("Class /Script/Engine.GameplayStatics"):get_class_default_object()
            return statics
        end

function UEVR_UObject:world_to_screen()
    local out = {}
    pc = pc or api:get_player_controller(0)
    Statics:ProjectWorldToScreen(pc, self:location(), out, true)
    return Vector2f.new(out.result.X, out.result.Y)
end

function hsv_to_rgb(h, s, v)
    local i = math.floor(h * 6)
    local f = h * 6 - i
    local p = v * (1 - s)
    local q = v * (1 - f)
    local t = v * (1 - (1 - f) * s)

    local r, g, b
    local mod_i = i % 6

    if mod_i == 0 then r, g, b = v, t, p
    elseif mod_i == 1 then r, g, b = q, v, p
    elseif mod_i == 2 then r, g, b = p, v, t
    elseif mod_i == 3 then r, g, b = p, q, v
    elseif mod_i == 4 then r, g, b = t, p, v
    else r, g, b = v, p, q
    end

    return r, g, b
end
function VecToU32(vec)
    local r = math.floor(math.max(0, math.min(255, vec.x * 255 + 0.5)))
    local g = math.floor(math.max(0, math.min(255, vec.y * 255 + 0.5)))
    local b = math.floor(math.max(0, math.min(255, vec.z * 255 + 0.5)))
    local a = math.floor(math.max(0, math.min(255, vec.w * 255 + 0.5)))

    -- ImGui expects 0xAABBGGRR
    return (a << 24) | (b << 16) | (g << 8) | r
end
-- get a semi-random, bright, and saturated color (0.0-1.0 RGBA)
-- easy to use for debug shapes, e.y. with 800 or so colliders suddenly drawn
-- use VecToU32 with draw api
function get_semi_random_bright_color(index, total_count)
    if index == nil and total_count == nil then
        index = math.random(255)
        total_count = 255
    end

    -- convert to HSV since this is easiest to think of in terms of hue variation by index
    -- (math.xandom() * 0.1) adds a slight random jitter to prevent band-like colors
    local h = (index / total_count + math.random() * 0.1) % 1.0

    -- hsv also makes it easier to guarantee high saturation without bias towards a hue
    local s = 0.8 + math.random() * 0.2

    -- same deal with brightness
    local v = 0.9 + math.random() * 0.1 -- Range: 0.9 to 1.0 (High Brightness)

    -- Convert HSV back to RGB
    local r, g, b = hsv_to_rgb(h, s, v)

    return v4f{r, g, b, 1.0}
end

function Vector3d:world_to_screen()
    local out = {}
    pc = pc or api:get_player_controller(0)
    Statics:ProjectWorldToScreen(pc, self, out, true)
    return Vector2f.new(out.result.X, out.result.Y)
end

local function printOnceEvery(text, time)
   if os.time() % time == 0 then
      print(text)
   end
end
pc = api:get_player_controller(0)
local fill_color = 0xB1A3D9D8
local UE_WORLD_MAX = 2097152.0
local MIN_DISTANCE = 850.0
local RADIUS_SCALE = 0.6
local MAX_DISTANCE = 6000
local function scale_by_distance(world_location, distance, min_radius, max_radius)
  -- use GetFocalLocation for quick camera world location
  if distance > MAX_DISTANCE then MAX_DISTANCE = distance * 1.1 end
  local d = math.min(math.max(distance, MIN_DISTANCE), MAX_DISTANCE)
  -- normalize distance to 1.0
  -- local t = math.min(distance / UE_WORLD_MAX, 1.0)
  local t = (math.log(d) - math.log(MIN_DISTANCE)) / (math.log(MAX_DISTANCE) - math.log(MIN_DISTANCE))
  t = math.min(math.max(t, 0.0), 1.0)
  -- lerp specified radius scale by normalized distance
  local radius = max_radius + (min_radius - max_radius) * t

  return radius
end

local object_colors = {}
local function get_screen_position(world_location)
  local screen_location = {}
  Statics():ProjectWorldToScreen(pc, world_location, screen_location, true)
  return Vector2f.new(screen_location.result.X, screen_location.result.Y)
end

local draw_calls = {}
local resolution = imgui.get_display_size()
local function object_draw_call(object)
  if UEVR_UObjectHook.exists(object) then
   object_colors = object_colors or {}
   local color = get_semi_random_bright_color()
   color.w = 0.2
   object_colors[object] = object_colors[object] or  VecToU32(color)
    fill_color = object_colors[object]
   -- omg do not do this per frame unless you like having seizures
   -- fill_color = VecToU32(get_semi_random_bright_color())
    -- get location assuming object is either an actor or component
    local world_location = object.K2_GetActorLocation and object:K2_GetActorLocation() or object:K2_GetComponentLocation() or object:get_outer():K2_GetActorLocation()
    -- project the world location to screen
    world_location.z = world_location.z + 25
    local screen_position = get_screen_position(world_location)
    if not screen_position then return end

    -- check that the object is actually on screen (could limit to portion of the screen easily)
    if screen_position and screen_position.x and (screen_position.x < resolution.x and screen_position.x > 0) and
     screen_position.y and  (screen_position.y < resolution.y and screen_position.y > 0) then

      -- scale the size of the output circle
      local distance = (world_location - pc:GetFocalLocation()):length()
      local radius = scale_by_distance(world_location, distance, 4.0, 48.0) * RADIUS_SCALE

      -- use the radius to simplify the circle and reduce draw call complexity
      local segments = math.floor(radius * 0.25)
      draw.filled_circle(screen_position.x, screen_position.y, radius, fill_color, segments)

      draw.outline_circle(screen_position.x, screen_position.y, radius*1.05, VecToU32(Vector4f.new(1.0,1.0,1.0,1.0)), segments)
      draw.text("Distance: "..tostring(math.floor(distance)), screen_position.x, math.max(0,screen_position.y - radius * 2), fill_color)
      draw.text("Radius: "..tostring(math.floor(radius)), screen_position.x, math.max(0,screen_position.y - radius), fill_color)

      end
  end
end


local mesh_comps
local skinnedmesh = api:find_uobject("Class /Script/Engine.SkinnedMeshComponent")
local function add_mesh_comps()
mesh_comps = mesh_comps or skinnedmesh:get_objects_matching(false)
end
local vr = uevr.params.vr
-- mesh_comps = skinnedmesh:get_objects_matching(false)

uevr.sdk.callbacks.on_frame(function()
   imgui.text(vr.get_hmd_width())


imgui.text(vr.get_hmd_height())


imgui.text(vr.get_ui_width())

imgui.text(vr.get_ui_height())


    if imgui.button("toggle draws")  then if mesh_comps ~= nil then mesh_comps = nil else mesh_comps =   skinnedmesh:get_objects_matching(false) end end
    imgui.push_id(1)
    local c, nv = imgui.slider_float(imgui.get_id("Max Distance scalar"), MAX_DISTANCE, 2000, UE_WORLD_MAX)
    if c then MAX_DISTANCE = nv end
    imgui.pop_id()
    imgui.push_id(2)
    local c, nv = imgui.slider_float(imgui.get_id("Min Distance scalar"), MIN_DISTANCE, 100, 1000)
    if c then MIN_DISTANCE = nv end
    imgui.pop_id()
    imgui.push_id(3)
    local c, nv = imgui.slider_float(imgui.get_id("Radius Scale"), RADIUS_SCALE, 0.1, 2.0)
    if c then RADIUS_SCALE = nv end
    imgui.pop_id()

    -- make a full sized window with flags to hide the background, prevent focus, and ignore inputs
    imgui.set_next_window_size(imgui.get_display_size())
    imgui.set_next_window_pos(Vector2f.new(0, 0))

    imgui.begin_window("###Canvas", true, 209599)
    if mesh_comps then
        for i, object in ipairs(mesh_comps) do
            object_draw_call(object)
        end
    end
    imgui.end_window()

end)