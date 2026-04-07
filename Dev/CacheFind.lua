api = uevr.api
local function base_types(coreuobjecttype)
     return api:find_uobject("Class /Script/CoreUObject."..coreuobjecttype)
end
local all_classes, all_structs, all_func, all_script_struct, all_enum
local base_class, base_struct, base_script_struct, base_func, base_enum

local function dump_types()
    local backup_cache = setmetatable({},{__mode = "v"})
    -- temporarily moves the object cache into a new table
    -- this way we can manually clean it out and restore the previous cache state
    extend_table(backup_cache, _sol_lua_push_objects_Object)
    co_load("inspect" , "inspect")
    local s, r = pcall(function()
        base_class, base_struct, base_script_struct, base_func, base_enum = base_types("Class"), base_types("Struct"), base_types("ScriptStruct"), base_types("Function"),
        base_types("Enum")
        all_classes = base_class:get_objects_matching(false)
        all_structs = base_struct:get_objects_matching(false)
        all_func = base_func:get_objects_matching(false)
        all_enum = base_enum:get_objects_matching(true)
        all_script_struct = base_script_struct:get_objects_matching(true)
        fs.write("all_classes.txt", inspect(all_classes), 4)

        fs.write("all_structs.txt", inspect(all_structs), 4)

        fs.write("all_functions.txt", inspect(all_func), 4)
        fs.write("all_enums.txt", inspect(all_enums), 4)

        fs.write("all_scriptstructs.txt", inspect(all_scriptstruct), 4)
    end)
    wipe_table(object_cache)
    wipe_table(class_cache)
    wipe_table(function_cache)
    wipe_table(struct_cache)
    object_cache = object_cache or {}
    extend_table(object_cache, backup_cache)
    wipe_table(backup_cache)
    all_classes, all_structs, all_func, all_script_struct, all_enum = nil
end


local short_names
local function get_unique_short_names()
    local s,r = pcall(function()
        local t = json.load_file("class_short_names.json")
        if #t > 0 then return t end
    end)
    if s then return r end
    base_class = base_class or base_types("Class")
    all_classes = base_class:get_objects_matching(false)
    local short_names = {}
    for i, v in ipairs(all_classes) do
        if v.get_class and v:get_class() == base_class then
            local short_name = v:get_fname():to_string()
            local full_name = v:get_full_name()
            if short_names[short_name] ~= nil
                then
                log("Duplicate short name "..short_name.." will be "..v:get_outer():get_short_name().."."..short_name)
                    short_name = v:get_outer():get_short_name().."."..short_name
            end
            short_names[short_name] = full_name
        end
    end
    json.dump_file("class_short_names.json", short_names, 4)
    return short_names
end

short_names = short_names or get_unique_short_names()

-- ensure you will get uobjects with usable functions without having to cast
local function discern_type(uobj)
    if uobj and UEVR_UObjectHook.exists(uobj) then
        if uobj:as_struct() then
            if uobj:as_class() then
                return uobj:as_class()
            elseif uobj:as_function() then
                return uobj:as_function()
            else
                return uobj:as_struct()
            end
        else
            return uobj
        end
    end
end

local _cache = setmetatable({}, {__mode = "v"})
-- main getter function. use this everywhere
local function find_fast(input)
    -- search by short name, most classes are unique without needing package name
    short_names = short_names or get_unique_short_names()
    if short_names and short_names[input] ~= nil then input = short_names[input]
    elseif input:sub(1, 5) ~= "Class" and input:sub(1, 12) ~= "ScriptStruct" then
        local engine_input =  "Class /Script/Engine.".. input
        if _cache[engine_input] ~= nil and UEVR_UObjectHook.exists(_cache[engine_input]) then
            return _cache[engine_input]
        else
            local temp = uevr.api:find_uobject(engine_input)
            if temp ~= nil and UEVR_UObjectHook.exists(temp) then
                _cache[engine_input] = temp
                return _cache[engine_input]
            end
        end
    end
    if _cache[input] ~= nil and UEVR_UObjectHook.exists(_cache[input])  then
       return _cache[input]
    else
        local temp = uevr.api:find_uobject(input)
          _cache[input] = UEVR_UObjectHook.exists(temp) and temp or nil
    end
   return discern_type(_cache[input])
end
_G.find_fast = find_fast
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

-- Either one works
-- Kismet.Math:VInterpTo
-- Kismet("Math"):VInterpTo

_G.Kismet = Kismet
local statics
local function Find_Statics()
    statics = statics or api:find_uobject("Class /Script/Engine.GameplayStatics"):get_class_default_object()
    return statics
end
Statics = Find_Statics()
_G.Statics = Statics


base_class = base_class or base_types("Class")
function string:find_classes_ending_with(term, defaults)
    local t = {}
    for i,v in ipairs(base_class:get_objects_matching(defaults)) do
        if v:get_short_name():endswith(term) then t[#t+1] = v
        end
    end
    return t
end

function string:find_first_of(include_cdo)
    return UEVR_UObjectHook.get_first_object_by_class(find_fast(self), include_cdo)
end

-- ("GameplayStatics"):find_first_of(true)

function string:find_all_instances(include_cdo)
    return find_fast(self):get_objects_matching(include_cdo)
end


-- ("SceneComponent"):find_all_instances(false)



find_batched = function(class_names, include_default)
    local output = {}
    for i, v in ipairs(class_names) do
        for i, object in
            ipairs(find_fast(class_name):get_objects_matching(include_default)) do
            output[#output+1] = object
        end
    end
    return output
end

    -- in truth this is useful solely because it can search tags (TArray<FName>)
    -- if no tag is provided its probably actually slower than get_objects_matching
actors_with_tag = function(tag, actorClass)
    pc = pc or api:get_player_controller(0)
    pawn = pawn or api:get_local_pawn(0)
    -- WCO can be literally any object spawned in the world
    local wco = pc:get_outer()
    local out = {}
    if tag ~= nil then
        if actorClass == nil then
            Statics:GetAllActorsWithTag(wco, tag, out)
        else
            Statics:GetAllActorsOfClassWithTag(wco, actorClass, tag, out)
        end
    else
        Statics:GetAllActorsOfClass(wco, ActorClass or find_fast("Actor"), out)
    end
    return out.result
end



function _uclass:find_all_active()
    local t = {}
    local instances = self:get_objects_matching(false)
    for idx, val in ipairs(instances) do
        if val.bIsActive ~= nil then
            if val.bIsActive then
                t[#t+1] = val
            end
        end
    end
    return temp
end



 function get_character_mesh()
    pc = pc or api:get_player_controller(0)
    local s, r = pcall(function() return api:get_local_pawn(0) end)
    if s and r ~= nil then pawn = r else return nil end
    -- infinity nikki
    pawn = pc.ControlPawn or pc.AcknowledgedPawn or pc.Character or api:get_local_pawn(0)
    if pawn and pawn.CharacterMesh0 and UEVR_UObjectHook.exists(pawn.CharacterMesh0)
        then return pawn.CharacterMesh0
    elseif pawn and pawn.Mesh and UEVR_UObjectHook.exists(pawn.Mesh) then
        return pawn.Mesh
        -- marvel
    elseif pawn.ChildActorComponent ~= nil and pawn.ChildActorComponent.ChildActor ~= nil then
        return pawn.ChildActorComponent.ChildActor.Mesh
        -- mhur
    elseif pawn._mesh ~= nil then
        return pawn._mesh
        -- Fullmetal School Girl
    elseif pawn.MainMesh ~= nil then
        return pawn.MainMesh
    -- any other games with weird main character meshes?
    else
        local sk = ("SkinnedMeshComponent"):find_all_instances(false)
        for idx, val in ipairs(sk) do
            if val:get_fname():to_string() == "CharacterMesh0" then
                -- Generally every game should have their mesh named as 
                -- CharacterMesh0 and sitting at a distance of 82 from the pawn
                if (math.abs(val.RelativeLocation.Z) < 100) then
                    return val
                end
            end
        end
    end
end

_G.GetCharacterMesh = get_character_mesh

-- local AActor = find_fast("Actor")
-- local UActorComponent = find_fast("ActorComponent")
-- local function SpawnActor(uclass, parent)
--     pc = pc or api:get_player_controller(0)
--     local a = api:spawn_object((type(uclass) == "string" and find_fast(uclass)) or uclass or AActor, parent or pc:get_outer())
--     if not a.RootComponent then a.RootComponent = a:add_component("Scene") end
--     if a then return a end
-- end

-- local function ActorClass()
--     return AActor or find_fast("Actor")
-- end

-- local function LevelName()
--     pc = pc or api:get_player_controller(0)
--     return pc:get_outer() and pc:get_outer():get_full_name()
-- end