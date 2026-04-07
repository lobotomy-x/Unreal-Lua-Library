
local M = {}


local ECC = {
    "ECC_WorldStatic",
    "ECC_WorldDynamic",
    "ECC_Pawn",
    "ECC_Visibility",
    "ECC_Camera",
    "ECC_PhysicsBody",
    "ECC_Vehicle",
    "ECC_Destructible",
    "ECC_EngineTraceChannel1",
    "ECC_EngineTraceChannel2",
    "ECC_EngineTraceChannel3",
    "ECC_EngineTraceChannel4",
    "ECC_EngineTraceChannel5",
    "ECC_EngineTraceChannel6",
    "ECC_GameTraceChannel1",
    "ECC_GameTraceChannel2",
    "ECC_GameTraceChannel3",
    "ECC_GameTraceChannel4",
    "ECC_GameTraceChannel5",
    "ECC_GameTraceChannel6",
    "ECC_GameTraceChannel7",
    "ECC_GameTraceChannel8",
    "ECC_GameTraceChannel9",
    "ECC_GameTraceChannel10",
    "ECC_GameTraceChannel11",
    "ECC_GameTraceChannel12",
    "ECC_GameTraceChannel13",
    "ECC_GameTraceChannel14",
    "ECC_GameTraceChannel15",
    "ECC_GameTraceChannel16",
    "ECC_GameTraceChannel17",
    "ECC_GameTraceChannel18",
    "ECC_OverlapAll_Deprecated",
    "ECC_MAX",
}


local CollisionResponseContainer = {
    WorldStatic = 0,
    WorldDynamic = 0,
    Pawn = 0,
    Visibility = 0,
    Camera = 0,
    PhysicsBody = 0,
    Vehicle = 0,
    Destructible = 0,
    EngineTraceChannel1 = 0,
    EngineTraceChannel2 = 0,
    EngineTraceChannel3 = 0,
    EngineTraceChannel4 = 0,
    EngineTraceChannel5 = 0,
    EngineTraceChannel6 = 0,
    GameTraceChannel1 = 0,
    GameTraceChannel2 = 0,
    GameTraceChannel3 = 0,
    GameTraceChannel4 = 0,
    GameTraceChannel5 = 0,
    GameTraceChannel6 = 0,
    GameTraceChannel7 = 0,
    GameTraceChannel8 = 0,
    GameTraceChannel9 = 0,
    GameTraceChannel10 = 0,
    GameTraceChannel11 = 0,
    GameTraceChannel12 = 0,
    GameTraceChannel13 = 0,
    GameTraceChannel14 = 0,
    GameTraceChannel15 = 0,
    GameTraceChannel16 = 0,
    GameTraceChannel17 = 0,
    GameTraceChannel18 = 0,
}
local CollisionResponse = {
    ResponseToChannels = {
        WorldStatic = 0,
        WorldDynamic = 0,
        Pawn = 0,
        Visibility = 0,
        Camera = 0,
        PhysicsBody = 0,
        Vehicle = 0,
        Destructible = 0,
        EngineTraceChannel1 = 0,
        EngineTraceChannel2 = 0,
        EngineTraceChannel3 = 0,
        EngineTraceChannel4 = 0,
        EngineTraceChannel5 = 0,
        EngineTraceChannel6 = 0,
        GameTraceChannel1 = 0,
        GameTraceChannel2 = 0,
        GameTraceChannel3 = 0,
        GameTraceChannel4 = 0,
        GameTraceChannel5 = 0,
        GameTraceChannel6 = 0,
        GameTraceChannel7 = 0,
        GameTraceChannel8 = 0,
        GameTraceChannel9 = 0,
        GameTraceChannel10 = 0,
        GameTraceChannel11 = 0,
        GameTraceChannel12 = 0,
        GameTraceChannel13 = 0,
        GameTraceChannel14 = 0,
        GameTraceChannel15 = 0,
        GameTraceChannel16 = 0,
        GameTraceChannel17 = 0,
        GameTraceChannel18 = 0,
    },
    ResponseArray = {
        Channel = ("Visibility"),
        Response = 1

    }
}
local ECollisionResponse =
{
    ECR_Ignore                               = 0,
    ECR_Overlap                              = 1,
    ECR_Block                                = 2,
    ECR_MAX                                  = 3,
}

local ECollisionEnabled =   {
    NoCollision                              = 0,
    QueryOnly                                = 1,
    PhysicsOnly                              = 2,
    QueryAndPhysics                          = 3,
    ECollisionEnabled_MAX                    = 4,
}


local phandle, hitcomp = nil
local hr = nil
local channel = 3
local teleport = false
local target = nil
local APIUE  = require("APIUE")
_ENV.print_to_ue_console = APIUE.print_to_ue_console
_ENV.get_camera_location = APIUE.get_camera_location
_ENV.SpawnActor = APIUE.SpawnActor
_ENV.ActorClass = APIUE.ActorClass
_ENV.LevelName = APIUE.LevelName
_ENV.get_hitresult = APIUE.get_hitresult
_ENV.UEVR_UObject = APIUE.UEVR_UObject
_ENV.UEVR_UStruct = APIUE.UEVR_UStruct
_ENV.UEVR_UClass = APIUE.UEVR_UClass
_ENV.UEVR_Ufunction = APIUE.UEVR_Ufunction
_ENV.UEVR_FField = APIUE.UEVR_FField
_ENV.UEVR_FProperty = APIUE.UEVR_FProperty

---[[
local staticmesh = Cache.get("StaticMeshActor")
local staticmeshcomp = Cache.get("StaticMeshComponent")
local hitactors = {}
local hit_meshes = {}
local pc = api:get_player_controller(0)
local pawn = api:get_local_pawn(0)
local ignore_actors = {pawn, pc}

local Colors = _G.Colors or require("Colors")
local colors = Colors.GetSemiRandomBrightColor(nil, nil, true)
local w2s_texts = {}
local dotext = false
local color_index = 1
local color = colors[color_index]

local function w2_screen(object, name)
    name = name or ""
    if object ~= nil and object.world_to_screen then
        local location = object.location and object:location() or object
        -- if dotext then draw.world_text(object and object:to_string(), location)  end
        local ss = object:world_to_screen()
        w2s_texts[#w2s_texts+1] = {
            location=location,
            name = name.."\n"..(object and object.to_string and object:to_string()),
            ss = ss,
            color = color
            }
        return ss end

end

function M.GetClickTraceParams()
    return pc.HitResultTraceDistance, pc.CurrentClickTraceChannel, pc.DefaultClickTraceChannel
end

function M.SetClickTraceParams(Channel, Distance)
    if type(Channel) == "string" then Channel = Cache.getCollisionChannel(Channel) end
    pc.CurrentClickTraceChannel = Channel
    pc.HitResultTraceDistance = Distance
end

local hitresults = {}
local params = {}
local ImGui = _G.ImGui or require("ImGui")
function M.TraceImGui(results, chains)
    local function build_hr_chain(hitresult)
        hitresults[#hitresults+1] = {chainid = tostring(hitresult), hit = hitresult, time = os.time()}
        local chainid = tostring(hitresult)
        local results = M.BreakHitResult(hitresult)
        local start_ss = w2_screen(results.TraceStart, "TraceStart")
        local end_ss = w2_screen(results.TraceEnd, "TraceEnd")
        local chain = {start_ss}
        params = params or {}
        -- colors[chainid] = colors[chainid] or
        params[chainid] = {fill_color = color}

        if results.bBlockingHit then
            local impact_ss = results.ImpactPoint and w2_screen(results.ImpactPoint, "ImpactPoint")
            if results.HitActor ~= nil then
                if results.HitComponent ~= nil then
                    if results.BoneName ~= nil or results.HitBoneName ~= nil then
                        local bonename = results.BoneName ~= nil and results.BoneName or results.HitBoneName ~= nil and results.HitBoneName or "None"
                        local bonepos = results.HitComponent.GetSocketLocation and results.HitComponent:GetSocketLocation(bonename)
                        if bonepos then chain[#chain+1] = w2_screen(bonepos, "BonePosition")
                        end
                    end
                end
                chain[#chain+1] = w2_screen(results.HitActor, "Actor")
            end
            chain[#chain+1] = impact_ss
        end
        chain[#chain+1] = end_ss

        return chain
    end
    chains = chains or {}
    if #results > #chains then
            for i, result in ipairs(results) do
               -- chains[#chains+1] = build_hr_chain(result)

                    ImGui.CanvasWindow()
                    draw.chain(build_hr_chain(result), params)
                    imgui.end_window()

                end
            if dotext then
            local seen = {}
                for i, text in ipairs(w2s_texts) do
                    text.ss = text.location:world_to_screen()
                    if not seen[text.name]   then
                        seen[text.name] = true

                    draw.text(text.name, text.ss.x, text.ss.y, text.color)
                end
                end
            end
        end
    if #chains > 8 then
        for i = #chains, 5, -1 do
            table.remove(chains, i)
            table.remove()
        end
    end

 end

local function trace_multi(results)
    ImGui.CanvasWindow()
--                imgui.draw_list_path_clear()

    for i, res in ipairs(results) do

        local ts = res.TraceStart:world_to_screen()
        if ts.x + ts.y == 0 then
            imgui.draw_list_path_clear()
        else
            imgui.set_cursor_screen_pos(ts)
            imgui.text("Trace start")
            imgui.set_cursor_screen_pos(ts)

            local end_ss =  res.TraceEnd:world_to_screen()
            if res.bBlockingHit and res.ImpactPoint then end_ss =  res.ImpactPoint end
            pcall(function()
            if res.HitActor ~= nil then
                if res.HitComponent ~= nil then
                    if res.BoneName ~= nil then

                        local bonepos = res.HitComponent.GetSocketLocation and res.BoneName and res.HitComponent:GetSocketLocation(res.BoneName, 0)

                        if bonepos then end_ss = bonepos
                        else
                            end_ss = res.HitActor:world_to_screen()
                        end
                    end
                end

            end
            end)
            imgui.draw_list_path_line_to(end_ss)
        end

    end
        imgui.draw_list_path_stroke(colors[1], false, 12)
     imgui.end_window()


 end



function trace_(object, socket)
    local cam_loc = get_camera_location()
    local start = (socket and object:GetSocketTransform(socket, 0).Translation or object:location()):closest_point(cam_loc, pc:GetViewTarget():forward() * 8192)
    local endp = start + (pc:GetViewTarget():forward() * 8192)

    return Kismet("System"):LineTraceSingle(pc:get_outer(), start, endp, 3, true, {}, 0, hit, true, {R=0,G=0,B=0,A=0},{R=0,G=0,B=0,A=0}, 1.0)
end
function line_trace()
 local hit = {}
     local startpos = cam_location()
    local endpos = (cam_rotation():forward() * 8192) + cam_location()
  --  local res = prim:check_output("K2_LineTraceComponent", {TraceStart = start, TraceEnd = endpos, bTraceComplex =  true, bShowTrace = false, bPersistentShowTrace = false})

 Kismet("System"):LineTraceSingle(pc:get_outer(), startpos, startpos:extrapolate(endpos, 8192), 3, true, {}, 0, hit, true, {R=0,G=0,B=0,A=0},{R=0,G=0,B=0,A=0}, 1.0)
 return hit.result
end
function sphere_trace()
     local hit = {}
     local startpos = cam_location()
    local endpos = (cam_rotation():forward() * 512) + cam_location()

 Kismet("System"):LineTraceSingle(pc:get_outer(), startpos, startpos:extrapolate(endpos, 1024), 15, 3, true, {}, 0, hit, true, {R=0,G=0,B=0,A=0},{R=0,G=0,B=0,A=0}, 1.0)
 return hit.result

end
local types = {}

for i, v in ipairs({"SkeletalMeshComponent", "Pawn"}) do
    types[#types+1] = Cache.get(v)
end

local chains
local results = {}
local frames = 0
local hrs
local dohits = false
local wasdohits = false
local inputs = 0
uevr.sdk.callbacks.on_frame(function()
     inputs = ImGui.incrementer(inputs, 0, 20, "ECC")
    if imgui.button("do hits ") then dohits = true end

    pawn = pawn or api:get_local_pawn(0)
    ImGui.CanvasWindow()
    if dohits then
   -- if not dohits then if wasdohits then pc.bShowMouseCursor = false wasdohits = false end
   -- else
   --      wasdohits = dohits
        pc = pc or api:get_player_controller(0)
        pc.bShowMouseCursor = true
        pc:SetMouseLocation(imgui.get_mouse():components())

    if ImGui.is_key_toggled("L")  then
       imgui.draw_list_path_clear()
        local res =  M.GetHitResultUnderCursor(inputs)

        results[#results+1] = res

        --local lookatrot = pawn:rotation():forward():lookat(res.ImpactPoint.forward and res.ImpactPoint:forward() or res.TraceEnd)
       -- local ssi = (res.ImpactPoint or res.TraceEnd):world_to_screen()
       -- imgui.set_cursor_screen_pos(pawn:world_to_screen())
      --  imgui.draw_list_path_line_to(ssi)
--      pawn:look_at_obj2(results[#results])



    end



    if ImGui.is_key_toggled("N")  then
        local res = M.BreakHitResult(M.GetHitResultUnderCursor(0))
         pawn:set_location(res.ImpactPoint)
    end

    if ImGui.is_key_toggled("6") then
         if inputs > 18 then inputs = 0 end
        if ECC[inputs] ~= nil and ECC[inputs] ~= "ECC_Max" then
        inputs = inputs + 1

        end
    end

    if ImGui.is_key_toggled("5") then
             if inputs < 0 then inputs = 18 end
        if ECC[inputs] ~= nil and ECC[inputs] ~= "ECC_WorldStatic" then
        inputs = inputs - 1

            print(inputs)
            print(ECC[inputs])


        end
    end

      if ImGui.is_key_pressed("P")   then
        hrs = {}
        results = {}
      end
   if ImGui.is_key_pressed("K")   then
        hrs = hrs or {}
        table.insert(hrs, M.BreakHitResult(M.GetHitResultUnderCursor(inputs, false)))
    elseif hrs and #hrs > 0 then
        trace_multi(hrs)
    end


        draw.text("Collision channel: "..(ECC[inputs] or "None"), 200, 200, Vector4f.new(1.0,1.0,1.0,1.0))
     if ImGui.is_key_pressed("M")  then
        dotext = true
        hrs = nil
    else dotext = false end
    M.TraceImGui(results, chains)
    end
    imgui.end_window()

end)





function M.GetActorFromHitResult(HitResult, actor_data)
    if HitResult == nil then
        return nil
    end
    local t = M.BreakHitResult(HitResult)
    return t.HitActor or nil
end

function M.DumpHitResult(hitresult, tojson)
    local results = M.BreakHitResult(hitresult)

 local text = {}
    for k, v in pairs(results) do
        text[k] = v.to_string and v:to_string() or tostring(v)
    end
    if tojson then json.dump_file("hitresults\\" .. tostring(os.time()) .. ".json", text, 4) end
    return text
end




local function is_out_param(func, prop)
    return func:find_property(prop):is_out_param()
end


local function get_param_names(func)
    local params = func:as_function():get_child_properties()
    local param_names = {}
    while params ~= nil do
        local p = params:get_fname():to_string()
        table.insert(param_names, p)
        params = params:get_next()
    end
    return param_names
end

local function get_param_data(func)
    local param_names = M.get_param_names(func)
    local data = {}
    for i, name in ipairs(param_names) do
        data[name] = {}
        local fprop = func:find_property(name)
        if fprop.is_param and fprop:is_param() then
            data[name] = {
                is_out_param = fprop:is_out_param(),
                is_return_param = fprop:is_return_param(),
                is_reference_param = fprop:is_reference_param(),
            }
        end
    end
end



local function build_out_params(func)
    local params = func:as_function():get_child_properties()
    local out = {}
    local order = {}
    while params ~= nil do
        local p = params:get_fname():to_string()
            print(#order, p)
            local param_class = params:get_class()
            if func:as_struct():find_property(p):is_out_param() then
                out[p] = {}  -- dynamically create empty table
            end
            -- this is equivalent to table.insert but is more optimal
            order[#order+1] = p
        params = params:get_next()
    end
    return out, order
end



function M.BreakHitResult(hitresult)
    Statics = _G.Statics or ("GameplayStatics"):find_first_of(true)
    local func = Statics.BreakHitResult
    local tbls = {}

     local tbls, order = build_out_params(func)
     --tbls.Hit = hitresult
    -- Collect arguments in order
    -- start with the hitresult already in the table

   local args = {}
   tbls["Hit"] = hitresult
    -- this is the same as table.insert, we cant just do args[i] since we have  to offset by 1
    -- for i, name in ipairs(order) do
    --     args[#args+1] = args[#args+1] or tbls[name]
    -- end
    for i, name in ipairs(order) do
        args[i] = tbls[name]
    end
    -- unpack the empty tables
    -- despite having no data in each table and
    -- despite table.unpack technically generating new values
    -- tbls still keeps references to each of them allowing us to retrieve the results
    Statics:BreakHitResult(table.unpack(args))

    -- Build results map
    -- This is simple here due to the function only taking out params
    -- but even if it didn't we would still know the order
    -- without the ordering steps we can get the data but we won't know which result goes where
    local results = { }
    for i = 2, #args do
        local name = order[i]
        results[name] =  tbls[name].result
    end
    if os.time() % 5 == 0 then
        local text = {}
        for k, v in pairs(results) do
            if v ~= nil then
                text[k] = can_index(v) and v.to_string and v:to_string() or tostring(v)
            end
        end
        json.dump_file("hitresults\\" .. tostring(os.time()) .. ".json", text, 4)
    end

    return results
end


local function get_resolution()
    local res
    if not res then
        uevr.sdk.callbacks.on_frame(function()
            res = imgui.get_display_size()
        end)
    end
    return res
end


-- You DO NOT need to break a hitresult if you just want to use it for transforms
-- If you're just trying to move something quickly you can fire off a quick hitresult
function M.GetHitResultUnderCursor(inputs, _break)
    local hitresult = {}
    local hitResult = nil
    --pc:SetMouseLocation({X = get_resolution().x * 0.5, Y = get_resolution().y * 0.5})
    pc = pc or api:get_player_controller(0)
    if inputs == nil then
        inputs = 1
    end
    if type(inputs) == "string" then
        inputs = M.GetCollisionChannel(inputs)
    end
    if type(inputs) == "table" then
        if pc:GetHitResultUnderCursorForObjects(inputs, true, hitresult) then
            hitResult = hitresult.result
        end
    end

    if pc:GetHitResultUnderCursorByChannel(inputs, true, hitresult) then
        hitResult = hitresult.result
    end
    if hitResult ~= nil then
        -- this puts the responsibility on the caller to parse out the results which do include the hitresult itself
        if _break then
            --return Statics:check_output("BreakHitResult", {Hit =hitResult})
            return M.BreakHitResult(hitResult)
        else
            -- this gives the actual hitresult struct if you just need it for a transformation
            return hitResult
        end
    end
end



return M