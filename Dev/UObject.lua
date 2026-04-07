local _uobject =  UEVR_UObject
local _ustruct  =  UEVR_UStruct --    setmetatable({}, uevr_ustruct)
local _uclass   =  UEVR_UClass --    setmetatable({}, uevr_uclass)
local _ufunction = UEVR_UFunction --     setmetatable({}, uevr_ufunction)
local _ffield   =  UEVR_FField --    setmetatable({}, uevr_ffield)
local _fproperty = UEVR_FProperty --        setmetatable({}, uevr_fproperty)
local _uevr_types = {
     _uobject,
     _ustruct,
     _uclass,
     _ufunction,
     _ffield,
     _fproperty
}

function UEVR_FName:__tostring(self)
    return self:to_string()
end

_uevr_types.assign_to_all = function(name, fn)
    for i, v in ipairs(_uevr_types) do
        v[name] = fn
    end
end


local min,max = math.min, math.max
Kismet = _G.Kismet
Statics = _G.Statics
UE5 = _G.UE5
UE4 = _G.UE4
Minor = _G.UE_Version_Minor
pc = pc or api:get_player_controller(0)
 pawn = api:get_local_pawn(0) or pc.AcknowledgedPawn
if pawn == nil and pc.ControlPawn ~= nil then
    pc.AcknowledgedPawn = pc.ControlPawn
    pawn = api:get_local_pawn(0)
end


function _uobject:readable_name()
    local parent = self:get_outer():get_short_name()
    return parent.."."..self:get_short_name():trim_uobject()
end


local function _u_tostring(s)
    return s and (s.get_full_name and s:get_full_name()) or
    (s.get_fname and s.get_fname():to_string())
end

_uevr_types.assign_to_all("__tostring", _u_tostring)
_uevr_types.assign_to_all("to_string", _u_tostring)


UEVR_UObjectHook.set_disabled(false)

function _uobject:exists()
    return UEVR_UObjectHook.exists(self)
end

function _uobject:check()
    return self:exists() and self
end

local parent_cache = {}
function _uclass:is_child_of(uclass)
    uclass = type(uclass) == "string" and find_fast(uclass) or uclass
    parent_cache[uclass] = parent_cache[uclass] or {}
    parent_cache[uclass][self] = parent_cache[uclass][self] or Kismet("Math"):ClassIsChildOf(self, uclass)
    return parent_cache[uclass][self]
end

--utest(function() return pawn:get_class():is_child_of(AActor) end, "function() pawn:get_class():is_child_of(AActor) end")

function _uobject:is_instance()
    return self:exists() and
        (self.as_struct and self:as_struct() or nil) == nil and self.get_class ~= nil
end


--utest(function() return pawn:is_instance() end, "is instance")


function _uobject:class_is_child_of(uclass)
     local self_class = self.as_class and self:as_class() or self.get_class and self:get_class()
     return self_class ~=nil and self_class:is_child_of(uclass) or nil
end
-- I can never remember which it was so its both
_uobject.is_child_class_of = _uobject.class_is_child_of


-- Type Checking / "casting" for actor/component system

-- In very simple terms Actors are the game representation of objects in the game world that hold a collection of components
-- actors are replicated across network and are the higher level abstraction for interacting with game objects
-- Actual logic generally occurs in the components and actors are mainly for grouping, communicating, and accessing components
-- Components are divided into 3 main types with each type descending from the others:
-- ActorComponent the base type which handles logic and receives ticks,
-- SceneComponent which handle transformations,
-- and PrimitiveComponent which deal with rendering and physics
-- Every component you interact with descends from one of these
-- All PrimitiveComponents are SceneComponents and all SceneComponents are ActorComponents
-- All mesh components are primitive components

function _uobject:is_actor()
    if not self:is_instance() then return false end
    return self.K2_GetActorLocation ~= nil and self
end

function _uobject:as_actor()
    if not self:is_instance() then return false end
    return (self:is_actor() and self) or (self.GetOwner and self:GetOwner()) or self:get_outer()
end


function _uobject:is_component()
    if not self:is_instance() then return false end
    return self.GetComponentTickInterval ~= nil
end

function _uobject:is_scene_component()
    if not self:is_instance() then return false end
    return self.K2_GetComponentToWorld ~= nil
end


-- for brevity I'm calling this as_component but it really should be as_scene_component
function _uobject:as_component()
    if not self:is_instance() then return false end
    local s, r = pcall(function()
    local root = (self:is_scene_component() and self) or self.RootComponent or
        self.CapsuleComponent or self.TransformComponent or self:as_actor().RootComponent

    if root:exists() then
        if self.RootComponent == nil and self:get_class():find_property("RootComponent") ~= nil then
            self.RootComponent = root
        end
        return root
    end
    end)
    if s then return r end
end

-- -- use get_objects_matching if you only want live objects
-- -- and keep in mind this may be very slow with a full run through uobjectarray
-- -- which can literally hit the maximum 32bit integer size
-- -- it will probably take up to a second which sounds very fast if you don't have a scle for reference
-- -- uobjecthook takes 30ms on average to get every single struct
-- function _uclass:get_child_classes_slow()
--     local arr = UEVR_FUObjectArray.get()
--     array_data.instance = arr
--     local t = {}
--     for i = 0, arr:get_object_count() - 1 do
--         if arr[i] and arr[i].as_class and arr[i]:as_class()
--             and Kismet("Math"):ClassIsChildOf(arr[i]:as_class(), self) then
--             t[#t+1] = arr[i]:as_class()
--         end
--     end
--     return t
-- end



function _uclass:get_child_classes()
    local class = api:find_uobject("Class /Script/CoreUObject.Class")
    local all_classes = class:get_objects_matching(false)
    local t = {}
    for i, obj in ipairs(all_classes) do
        if (obj.as_class and obj:as_class()):is_child_of(self) then
            t[#t+1] = obj
        end
    end
    all_classes = nil
    return t
end



-- Object Creation / Lifecycle

local function closest_bone(mesh, loc)
    local out_loc = {}
    local b = mesh:FindClosestBone_K2(loc, out_loc, true, false)
    return {name = b, location = out_loc.result}
end

local function toggle_hide_skeletal_mesh(mesh)
    local n = mesh:GetNumMaterials()
    for i = 0, n - 1 do
        local shown = mesh:IsMaterialSectionShown(i)
        mesh:ShowMaterialSection(i,i, not shown)
    end
end

function _uobject:toggle_visibility()
    if self:class_is_child_of(find_fast("SkinnedMeshComponent")) then
        toggle_hide_skeletal_mesh(self)
    end
   local show = self.bRenderInMainPass
   if not show then return nil end
   self:SetRenderInMainPass(not show)
   self:ToggleVisibility(not show)
   return show
end


function _uobject:toggle_active()
   local active = self.bIsActive
   if not active then return nil end
   self:Activate(not active)
   return active
end


function _uobject:set_properties(prop_source)
    if not self:is_instance() then return nil end
    local class = self:get_class()
    if type(prop_source) == "table" then
        for k,v in pairs(prop_source) do
            if class:find_property(k) then
                pcall(self:set_property(k, v))
            end
        end
    elseif prop_source.exists and prop_source:exists() then
        local properties = prop_source:get_properties()
        for i, v in ipairs(properties) do
            local pname = v:get_fname():to_string()
            if class:find_property(pname) then
            -- I've made a point of not overusing pcall in this api extension as it does slow things down
            -- and you can always wrap things in pcall yourself. I also don't want people to feel any need to modify these funcs\
            -- but without pcall this will fail if there are unimplemented props like ArrayProperties on the target object
            -- but this does future proof it
                pcall(self:set_property(pname, v))
            end
        end
    end
    return self
end


function _uobject:add_component(uclass, offset)
    offset = offset or Vector3.new(0,0,0)
    local t = api:add_component_by_class(
        self:as_actor(),
        type(uclass) == "string" and find_fast((uclass:endswith("Component") 
            and uclass or uclass.."Component")) or uclass,
        false
    )
    if not t then print(inspect({uclass, self, "failed to add component"})) end
    t.RelativeLocation = offset
    return t
end

function _uobject:add_components(args)
    local out = {}
    for i, v in ipairs(args) do
        local class = v.class
        local attach_socket = v.attach_socket or nil
        local attach_rules = v.attach_rules or nil
        local offset = v.offset or nil
        local unique = v.unique or nil
        local properties = v.properties or nil
        local rotation = v.rotation or nil
        local scale = v.scale or nil
        local own_bounds = v.own_bounds or true
        if v.class then
            if unique and attach_socket then
                local comps = self:get_socket_attachments(attach_socket)
                if comps ~= nil and #comps > 0 then
                    for _, other in ipairs(comps) do
                        if other:exists() and other:get_class() == class then
                            if rotation ~= nil then
                                other.RelativeRotation = rotation
                            end
                            if offset ~= nil then
                                other.RelativeLocation = offset
                            end
                             if scale ~= nil then
                                other.RelativeScale3D = scale
                            end
                            out[i] = other
                            goto continue
                        end
                    end
                end
            end
            local comp = self:add_component(class, offset)
            if comp and attach_socket then
                comp:attach(self, attach_socket, attach_rules)
                if properties ~= nil then
                    for k, v in pairs(properties) do
                        if class:find_property(k) ~= nil then
                           comp:set_property(k, v)
                       end
                    end
                end
                if not own_bounds then
                    comp.bUseAttachParentBound = true
                end
                if rotation ~= nil then
                    comp.RelativeRotation = rotation
                end
                if offset ~= nil then
                    comp.RelativeLocation = offset
                end
                 if scale ~= nil then
                    comp.RelativeScale3D = scale
                end
            end
            out[i] = comp
        end
        ::continue::
    end
    return out
end


local transform_cache = {}
function _uobject:get_or_add_component(v)

    local class = v.class
    local attach_socket = v.attach_socket or nil
    local attach_rules = v.attach_rules or nil
    local offset = v.offset or nil
    local rotation = v.rotation or nil
    local scale = v.scale or nil
    local properties = v.properties or nil

    if v.class then
        if type(v.class) == "string" then v.class = find_fast(v.class) end
        local comps = self:get_socket_attachments(attach_socket)
        if comps ~= nil and #comps > 0 then
            for _, other in ipairs(comps) do
                if other:exists() and other:is_child_class_of(v.class) then
                    if properties ~= nil then
                        for k, v in pairs(properties) do
                            if class:find_property(k) ~= nil then
                               other:set_property(k, v)
                           end
                        end
                    end
                    if rotation ~= nil then
                        other.RelativeRotation = rotation
                    end
                    if offset ~= nil then
                        other.RelativeLocation = offset
                    end
                     if scale ~= nil then
                        other.RelativeScale3D = scale
                    end
                   return other
                end
            end
        end
        local comp = self:add_component(class, offset)
        if comp and attach_socket then
            comp:attach(self, attach_socket, attach_rules)
            if properties ~= nil then
                for k, v in pairs(properties) do
                    if class:find_property(k) ~= nil then
                       comp:set_property(k, v)
                   end
                end
            end
        end
        return comp
    end

end



function _uobject:get_component(search_class)
    local class = (type(search_class) == "string" and (search_class:endswith("Component") and find_fast(search_class) or find_fast(search_class.."Component"))
            or search_class.get_class ~= nil and search_class)
    return (self.GetComponentByClass and self or self:get_outer().GetComponentByClass and self:get_outer()):GetComponentByClass(class)
end

local testcompf = function()
      return pawn:get_component("SkeletalMesh")
    end
--utest(testcompf, "pawn:get_component(SkeletalMesh)")


function _uobject:get_components(search_class)
    if type(search_class) == "table" and search_class.class then search_class = search_class.class end
    search_class = search_class or "ActorComponent"
    if self.K2_GetComponentsByClass ~= nil then
        local class = find_fast(search_class)
        return self:K2_GetComponentsByClass(class)
    elseif self.AttachChildren ~= nil then
        local t = {}
        for i,v in ipairs(self.AttachChildren) do
            if type(search_class) == "string" then
                if v:get_class():to_string():contains(search_class) then
                    t[#t+1] = v
                end
            elseif v:get_class() == search_class then
                t[#t+1] = v
            end
        end
        return t
    end
    return {}
end

--utest(testcomps, "pawn:get_components(SkeletalMesh)")

function _uobject:get_attached_components()
    local t = {}
    local numcomps = self:as_component():GetNumChildrenComponents()
    if numcomps == nil or numcomps == 0 then return nil end
    for i = 1, numcomps do
        table.insert(t, self:as_component():GetChildComponent(i-1))
    end
    return t
end


local testcomps = function()
 --   if not pawn then return 1 end
      return pawn:get_components()
    end
local testcomps2 = function()
    --    if not pawn then return 1 end

      return pawn:get_attached_components()
end

utest(testcomps, "pawn:get_components()")
utest(testcomp2, "pawn:get_attached_components()")


function _uobject:lifespan()
    return (self:as_actor()):GetLifeSpan()
end

function _uobject:age()
    return (self:as_actor()):GetGameTimeSinceCreation()
end

function _uobject:set_lifespan(lifespan, destroy_after)
    (self:as_actor()):SetLifeSpan(lifespan)
    if destroy_after ~= nil then (self:as_actor()):SetAutoDestroyWhenFinished(destroy_after) end
end

-- t = {enabled = true, when_paused = true, group = 0, interval = 2}
function _uobject:set_tickable(t)
    local a = self:as_actor()
    if not a then return end
    if t.enabled ~= nil then a:SetActorTickEnabled(t.enabled) end
    if t.when_paused ~= nil then a:SetTickableWhenPaused(t.when_paused) end
    if t.group ~= nil then a:SetTickGroup(t.group) end
    if t.interval ~= nil then a:SetActorTickInterval(t.interval) end
end

function _uobject:tickable_data()
    local a = self:as_actor()
    local t = {}
    if not a then return end
    t.enabled = a:GetActorTickEnabled()
    t.when_paused = a:GetTickableWhenPaused()
    t.group = a:GetTickGroup()
    t.interval = a:GetActorTickInterval()
    return t
end




function _uobject:get_all_bone_names()
    local bone_names = nil
    local comp = self:get_mesh_component()
    if comp and comp.GetNumBones then
        bone_names = {}
        local numbones = comp:GetNumBones()
        for i = 0, numbones do
            local bone_name = comp:GetBoneName(i)
            bone_names[#bone_names+1]= bone_name:to_string()
        end
    end
    return bone_names
end


local function get_ref_poses(mesh)
    local t = {}
    t.__orderedIndex = {}
    for i = 0, mesh:GetNumBones() do
        local bone_name = mesh:GetBoneName(i):to_string()
        t[bone_name] = mesh:GetRefPosePosition(i)
        t.__orderedIndex[i] = bone_name
    end
    return t
end

function get_bone_parents(mesh)
    if not mesh then return end
    local t = {}
    t.__orderedIndex = {}
    for i = 0, mesh:GetNumBones() do
        local bone_name = mesh:GetBoneName(i):to_string()
        t[bone_name] = mesh:GetParentBone(bone_name)
        t.__orderedIndex[i] = bone_name
    end
    return t
end


local function find_last_spine(bones)
    local last = 00
    local lastbone = ""
    for i, v in ipairs(bones) do
        if v:contains("spine", true) then
            local nums = tonumber(v:digits())
            if nums and nums > last then
                last = nums
                lastbone = v
            end
        end
    end
    print(lastbone)
    return lastbone
end

function find_important_bones(mesh)
    local t = {}
    local bone_parents = get_bone_parents(mesh)
    local refposes = get_ref_poses(mesh)
    local headx = 0.5
    for bone, pose in orderedPairs(refposes) do
        local parent = mesh:GetParentBone(bone)
        if bone:contains("head", true) and mesh:GetSocketLocation(bone, 1) ~= mesh:GetSocketLocation("Root", 1)
            then
                if not t.head then
                    t.head = {name = bone, refpose = pose}
                    print(bone)
                elseif pose.x <= headx then
                    headx = pose.x
                    t.head = {name = bone, refpose = pose}
                end
        elseif bone:contains("neck", true) and mesh:GetSocketLocation(bone, 1) ~= mesh:GetSocketLocation("Root", 1)
            then t.neck = {name = bone, refpose = refposes[parent]}

        end

    end
     t.spine = {name = find_last_spine(mesh:get_all_bone_names())}


    return t
end
local function check_socket(obj, socket)
    if obj.DoesSocketExist and obj:DoesSocketExist(socket) then return socket
    else
        local bones = obj.get_all_bone_names and obj:get_all_bone_names()
        if bones then
            local candidates = {}
            for i, bone in ipairs(bones) do
                if bone:letters():equals(socket, true) then return bone
                elseif bone:contains(socket, true) then candidates[#candidates+1] = bone
                end
            end
            if #candidates > 0 then
                local socket_length = #socket
                local lengths = {}
                for i,v in ipairs(candidates) do
                    lengths[i] = #v
                end
                local mincandidate = math.min(table.unpack(lengths))
                for i,v in ipairs(candidates) do
                    if mincandidate == #v then return v end
                end
            end
        end
    end
    return "None"
end

-- Attachment / Relations

local EAttachmentRule = {
    KeepRelative                             = 0,
    KeepWorld                                = 1,
    SnapToTarget                             = 2,
    EAttachmentRule_MAX                      = 3,
}

local EDetachmentRule =
{
    KeepRelative                             = 0,
    KeepWorld                                = 1,
    EDetachmentRule_MAX                      = 2,
}
-- simple universal attachment for actors and components.
-- Socket can be a string, FName, or nil
-- rules should be a table like {2, 2, 2}, an array of the string names corresponding to each enum value, or nil
-- e.g. {"KeepRelative", "KeepRelative", "SnapToTarget"}
-- {2, 0, 2} is the default and will generally give expected results
-- weld only matters for physics objects but I'm not sure why you wouldn't want it. defaults to true
function _uobject:attach(parent, socket, rules, weld)
    socket = socket or "None"
    if socket then
        socket = check_socket(self, socket)
    end
    if rules ~= nil then
        for i, v in ipairs(rules) do
            if type(v) == "string" then
                rules[i] = EAttachmentRule[v]
            end
        end
    else
        -- defaults to snap location and scale, keep world rotation
        rules = {2, 0, 2}
    end
    local location_rule = rules[1] or rules.Location or 2
    local rotation_rule =  rules[2] or rules.Rotation or 0
    local scale_rule =  rules[3] or rules.Scale3D or 2
    -- If you're wondering about K2_AttachToActor, well fun fact this is exactly what it does under the hood anyway lol
    -- there is no actual concept of attaching an actor in unreal,
    -- as with anything related to transforms we're just passing it onto the scene comp
    self:as_component():K2_AttachToComponent(parent:as_component(), socket, location_rule, rotation_rule, scale_rule, weld or true)
    return self, parent
end


function _uobject:get_attach_parent()
    return (self.GetAttachParentActor and self:GetAttachParentActor()) or self.AttachParent or nil
end

function _uobject:get_attach_socket()
    return (self.GetAttachParentSocketName and self:GetAttachParentSocketName()) or self.AttachSocketName or nil
end

function _uobject:get_socket_attachments(socket)
    local comps = self:get_attached_components()
    if comps then
        for i = #comps, 1, -1 do
            local attachsocket = comps[i]:get_attach_socket()
            if (not attachsocket) or (attachsocket ~= socket) then
                table.remove(comps, i)
            end
        end
    end
    return comps
end


local function test_func_attachments()
    local mesh = get_character_mesh()
    if mesh then
        return  mesh:add_components({
            {class = "Sphere", attach_socket = "head"},
            {class = "Arrow", attach_socket = "head"}
        })
    end

end
local function test_func_attachments2()
    local mesh = get_character_mesh()
    if mesh then
        return get_socket_attachments("head")
    end
end

-- --utest(test_func_attachments, "test_func_setattachments_head")
-- --utest(test_func_attachments2,"test_func_getattachments2_head")

local function get_leader(component)
    -- post 5.1
    if NEW_MESH_API then
        return component.LeaderPoseComponent or component
    end
    return component.MasterPoseComponent or component

end


function _uobject:get_mesh_component(name, meshtype)
    meshtype = meshtype or "SkinnedMesh"
    if name then
        if self:get_fname():to_string():contains(name) then return self
        else
            local all_meshes = self:get_components(meshtype)
            for i,v in ipairs(all_meshes) do
                if v:get_short_name():contains(name)
                then return v
                end
            end
        end
    end
    local comp = (self:class_is_child_of(meshtype:endswith("Component") and meshtype or meshtype.."Component") and self) or self:get_component(meshtype)
    comp = (comp ~= nil and meshtype ~= "StaticMesh") and get_leader(comp) or comp
    if comp then return comp end
end

local function get_mesh_asset(mesh)
    if mesh:class_is_child_of("StreamableRenderAsset") then return mesh
    elseif mesh:class_is_child_of("MeshComponent") then
        local asset = mesh.SkeletalMesh or mesh.StaticMesh or nil
        if asset ~= nil then return asset end
         -- 5.1 on
        if NEW_MESH_API then return  mesh.GetSkinnedAsset and mesh:GetSkinnedAsset()
            or mesh.GetSkeletalMeshAsset and mesh:GetSkeletalMeshAsset()
        else
            return mesh.GetSkeletalMesh and mesh.GetSkeletalMesh()
        end
    end
end



local  EVisibilityBasedAnimTickOption =
{
    AlwaysTickPoseAndRefreshBones            = 0,
    AlwaysTickPose                           = 1,
    OnlyTickMontagesWhenNotRendered          = 2,
    OnlyTickPoseWhenRendered                 = 3,
    EVisibilityBasedAnimTickOption_MAX       = 4,
}







local function set_leader(component, leader)
    -- post 5.1
    if NEW_MESH_API then
        component:SetLeaderPoseComponent(leader, true)
    else
        component:SetMasterPoseComponent(leader, true)
    end
    if component.CopyPoseFromSkeletalComponent then
        component:CopyPoseFromSkeletalComponent(leader)
    end
    component:set_location(leader:location())
    component:set_rotation(leader:rotation())
end



-- note that you probably don't actually want to change a mesh
-- its far better to make a new one as materials won't always copy
-- only really useful if you need to hard reference to avoid garbage collection
function _uobject:add_or_change_mesh(asset_or_component, leader)
    local comp = self:get_mesh_component()
    local asset = get_mesh_asset(asset_or_component)
    if not asset then return end
    if not comp then
        local meshtype = asset:get_class():get_short_name()
        comp = self:add_component(meshtype:endswith("Asset") and "SkinnedMesh" or meshtype)
    end
    if asset.Skeleton == nil then
        comp:SetStaticMesh(asset)
    elseif NEW_MESH_API then
        if comp.SetSkeletalMeshAsset then comp:SetSkeletalMeshAsset(asset)
        elseif comp.SetSkinnedAssetAndUpdate then
            comp:SetSkinnedAssetAndUpdate(asset, true)
        end
    elseif comp.SetSkeletalMesh then
        comp:SetSkeletalMesh(asset, true)
    end
    if leader then set_leader(comp, leader) end
end

-- note that you probably don't actually want to change a mesh
-- its far better to make a new one as materials won't always copy
-- only really useful if you need to hard reference to avoid garbage collection
function _uobject:poseable_clone()
    if not self:class_is_child_of("SkinnedMeshComponent") then return end
    local asset = get_mesh_asset(self)
    if not asset then return end
    local comp = self:as_actor():add_component("PoseableMeshComponent")

    if NEW_MESH_API then
        comp:SetSkinnedAssetAndUpdate(asset, true)
    else
        comp:SetSkeletalMesh(asset, true)
    end
    set_leader(comp, self)
    self.PrimaryComponentTick.bTickEvenWhenPaused = true
    comp.VisibilityBasedAnimTickOption = EVisibilityBasedAnimTickOption["AlwaysTickPoseAndRefreshBones"]

    if asset.PhysicsAsset ~= nil and comp.SetPhysicAsset then
        comp:SetPhysicsAsset(asset.PhysicsAsset, true)
    end
    comp:attach(self:get_attach_parent(), self:get_attach_socket())
    comp:set_location(self:location())
    comp:set_rotation(self:rotation())
    return comp
end






-- detach from parent
function _uobject:detach(keep_world)
    keep_world = keep_world or true
    if self:is_actor() then
        self:DetachRootComponentFromParent(keep_world)
    elseif self:is_scene_component() then
        self:DetachFromParent(keep_world, false)
    end
    return self
end


function _uobject:destroy(owning_tbl, key)
    self:detach()
    if self:is_actor() then
        self:K2_DestroyActor()
    elseif self:is_component() then
        local owner = self:GetOwner() or self:as_actor()
        if owner and owner.K2_DestroyComponent then
            owner:K2_DestroyComponent(self)
        end
    end
    if owning_tbl then
        owning_tbl[key] = nil
    end
end




function _uobject:is_overlapping(other)
    return (self:as_actor()):IsOverlappingActor(other:as_actor()) or
    (self:as_component()):IsOverlappingComponent(other:as_component())
end



-- no one even knows this function exists so I'mma modify it a little
-- now this will strip out the numbers at the end of newly spawned objects
local old_short_name = UEVR_UObject.get_short_name
function _uobject:get_short_name()
    local short_name = old_short_name(self) or self.get_fname and self:get_fname():to_string()
    return short_name:trim_uobject()
end


-- Transformations
local TransformSpace = {
    "World",
    "Relative",
    "Local",
}
local ERelativeTransformSpace = {
    RTS_World                                = 0,
    RTS_Actor                                = 1,
    RTS_Component                            = 2,
    RTS_ParentBoneSpace                      = 3,
    RTS_MAX                                  = 4,
}




function _uobject:get_transform(args)
    local socket = args and args.socket or nil
    local relative = args and args.relative or false
    if socket then
        return self:as_component():GetSocketTransform(socket, relative and 1 or 0)
    elseif relative then
        return self.GetRelativeTransform and self:GetRelativeTransform()
    else return self.GetTransform and
        self:GetTransform() or
        self.K2_GetComponentToWorld and
        self:K2_GetComponentToWorld()
    end
end

function _uobject:get_location(args)
    local transform = self:get_transform(args)
    return transform and transform.Translation
end

function _uobject:get_rotation_quat(args)
    local transform = self:get_transform(args)
    return transform and transform.Rotation
end

function _uobject:get_scale(args)
    local transform = self:get_transform(args)
    return transform and transform.Scale3D
end

function _uobject:get_rotation(args)
    local socket = args and args.socket or nil
    local relative = args and args.relative or false
    if socket then
        return self:as_component():GetSocketRotation(socket, relative and 1 or 0)
    elseif relative then
        return self.GetRelativeRotation and self:GetRelativeRotation()
    else return (self.K2_GetActorRotation and self:K2_GetActorRotation()) or
        (self.K2_GetComponentRotation and self:K2_GetComponentRotation())
    end
end


function _uobject:get_rotation_rot(args)
    return Vector3.from_quat(self:get_rotation_quat(args))
end

local function test_rots()
    pawn = pawn or api:get_local_pawn(0)
    local rot = pawn:get_rotation()
    local rotq = pawn:get_rotation_quat()
    local rotr = pawn:get_rotation_rot()
    print("rot",tostring(rot))
    print("rotr",tostring(rotr))
    print("rotq",tostring(rotq))
end
utest("rotations", test_rots)

function _uobject:location()
    return self:get_location()
end

function _uobject:rotation()
    return self:get_rotation()
end

function _uobject:scale()
    return (self:is_actor() and self:GetActorScale3D()) or (self.is_scene_component() and self:K2_GetComponentScale())
end

function _uobject:set_scale()
    return (self:is_actor() and self:SetActorScale3D()) or (self.is_scene_component() and self:SetWorldScale())
end


function _uobject:set_location(vec, sweep, tp, space)
    local obj = (self:as_component() or self)
    local func = obj.K2_SetWorldLocation ~= nil and "K2_SetWorldLocation" 
        or obj.K2_SetActorLocation and "K2_SetActorLocation"
    if func and obj then
        obj:call(func, table.unpack({vec, sweep or false, {}, tp or false}))
        return obj
    end
end

function _uobject:set_rotation(vec, sweep, tp)
    self:as_component():K2_SetWorldRotation(vec, sweep or false, {}, tp or false)
    return self
end

function _uobject:set_yaw(yaw)
    local old_rot = self:get_rotation()
    old_rot.y = yaw
    self:as_component():K2_SetWorldRotation(old_rot)
    return self
end

function _uobject:set_pitch(pitch)
    local old_rot = self:get_rotation()
    old_rot.x = pitch
    self:as_component():K2_SetWorldRotation(old_rot)
    return self
end


function _uobject:set_roll(roll)
    local old_rot = self:get_rotation()
    old_rot.z = pitch
    self:as_component():K2_SetWorldRotation(old_rot)
    return self
end

function _uobject:add_yaw(yaw)
    local old_rot = self:get_rotation()
    old_rot.y = old_rot.y + yaw
    if old_rot.y > 360 then old_rot.y = old_rot.y - 360 end
    self:as_component():K2_SetWorldRotation(old_rot)
    return self
end

function _uobject:add_pitch(pitch)
    local old_rot = self:get_rotation()
    old_rot.x = old_rot.x + pitch
        if old_rot.y > 180 then old_rot.y = old_rot.y - 180 end

    self:as_component():K2_SetWorldRotation(old_rot)
    return self
end


function _uobject:add_roll(roll)
    local old_rot = self:get_rotation()
    old_rot.z = roll
        if old_rot.z > 360 then old_rot.y = old_rot.z - 360 end

    self:as_component():K2_SetWorldRotation(old_rot)
    return self
end
function _uobject:reset_relative_transform()
    return self:as_component():ResetRelativeTransform()
end


function _uobject:set_relative_transform(t)
    return self:as_component():K2_SetRelativeTransform(t)
end

function _uobject:get_relative_transform()
    return self:as_component():GetRelativeTransform()
end



local TransformSpace = {
    "World",
    "Relative",
    "Local",
}
function _uobject:add_offset(vec, sweep, tp, space)
    local tspace = ((type(space) == "string" and space) or (type(space) == "number" and TransformSpace[space])) or "Local"
    local func = "K2_Add"..tspace.."Offset"

    (self:as_component()):call(func,table.unpack({vec, sweep or false, {}, tp or false}))
    return self
end

function _uobject:add_rotation(rot, sweep, tp, space)
    local func = "K2_Add"..((type(space) == "string" and space) or (type(space) == "number" and TransformSpace[space])).."Rotation"

    (self:as_component()):call(func,table.unpack({rot, sweep or false, {}, tp or false}))
    return self
end

function _uobject:add_transform(transform, sweep, tp, space)
    local func = "K2_Add"..((type(space) == "string" and space) or (type(space) == "number" and TransformSpace[space])).."Transform"

    (self:as_component()):call(func,table.unpack({transform, sweep or false, {}, tp or false}))
    return self
end



function _uobject:set_location_and_rotation(loc, rot)
    self:set_location(loc)
    self:set_rotation(rot)
    return self
end

function _uobject:velocity()
    return self.GetVelocity and self:GetVelocity() or self:as_component():GetComponentVelocity()
end



function _uobject:get_look_at(other)
    local lookat = Kismet("Math"):FindLookAtRotation(self:location(), (other.location and other:location()) or (other.x and other))
    return lookat
end

function Vector3:get_look_at(other)
    local lookat = Kismet("Math"):FindLookAtRotation(self, (other.location and other:location()) or (other.x and other))
    return lookat
end


local lerp_time = nil
local total_time = nil
function _uobject:look_at(other, progress)
  self:set_rotation(self:rotation():lerp(self:get_look_at(other), progress or 1.0))
  return self
end

local lerp_time = nil
local total_time = nil
function Vector3:look_at(other, progress)
  self:lerp(self:get_look_at(other), progress or 1.0)
  return self
end


function _uobject:delta_rot_kismet(new_rotation)
    return Kismet("Math"):NormalizedDeltaRotator(self:rotation(), new_rotation)
end


-- not a particularly difficult function and one we could just implement in lua
function _uobject:is_looking_at(other, tolerance)
    return Kismet("Math"):EqualEqual_RotatorRotator(self:rotation(), self:get_look_at(other), tolerance)
end


function _uobject:get_forward()
    return (self and (self.GetActorForwardVector and self:GetActorForwardVector()) or self.GetForwardVector and self:GetForwardVector())
end

function _uobject:forward()
    local rotation = self:rotation()
    return rotation:rotator_forward()
end

local function test_forward()
    local gameforward = pawn:get_forward()
    local myforward = pawn:rotator_forward()
    print("game forward "..gameforward:to_string())
    print("my forward "..myforward:to_string())

end

utest(test_forward, "test forward")

function _uobject:right()
    return (self and (self.GetActorRightVector and self:GetActorRightVector()) or self.GetRightVector and self:GetRightVector())
end

function _uobject:up()
    return (self and (self.GetActorUpVector and self:GetActorUpVector()) or self.GetUpVector and self:GetUpVector())
end

---[[
local ECollisionChannel = {
    ECC_WorldStatic                          = 0,
    ECC_WorldDynamic                         = 1,
    ECC_Pawn                                 = 2,
    ECC_Visibility                           = 3,
    ECC_Camera                               = 4,
    ECC_PhysicsBody                          = 5,
    ECC_Vehicle                              = 6,
    ECC_Destructible                         = 7,
    ECC_EngineTraceChannel1                  = 8,
    ECC_EngineTraceChannel2                  = 9,
    ECC_EngineTraceChannel3                  = 10,
    ECC_EngineTraceChannel4                  = 11,
    ECC_EngineTraceChannel5                  = 12,
    ECC_EngineTraceChannel6                  = 13,
    ECC_GameTraceChannel1                    = 14,
    ECC_GameTraceChannel2                    = 15,
    ECC_GameTraceChannel3                    = 16,
    ECC_GameTraceChannel4                    = 17,
    ECC_GameTraceChannel5                    = 18,
    ECC_GameTraceChannel6                    = 19,
    ECC_GameTraceChannel7                    = 20,
    ECC_GameTraceChannel8                    = 21,
    ECC_GameTraceChannel9                    = 22,
    ECC_GameTraceChannel10                   = 23,
    ECC_GameTraceChannel11                   = 24,
    ECC_GameTraceChannel12                   = 25,
    ECC_GameTraceChannel13                   = 26,
    ECC_GameTraceChannel14                   = 27,
    ECC_GameTraceChannel15                   = 28,
    ECC_GameTraceChannel16                   = 29,
    ECC_GameTraceChannel17                   = 30,
    ECC_GameTraceChannel18                   = 31,
    ECC_OverlapAll_Deprecated                = 32,
    ECC_MAX                                  = 33,
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
--]]
function _uobject:get_collision_profile()
    if self.BodyInstance ~= nil then
        return self.BodyInstance.CollisionProfileName
    end
end



function _uobject:set_all_collision_responses(response)
    if self.BodyInstance ~= nil then
        self:SetCollisionResponseToAllChannels(response)
    end
end
local ECollisionResponse =
{
    ECR_Ignore                               = 0,
    ECR_Overlap                              = 1,
    ECR_Block                                = 2,
    ECR_MAX                                  = 3,
}

function _uobject:set_collision_response(channel, response)
    if self.BodyInstance ~= nil then
        self:SetCollisionResponseToChannel(channel, response)
    end
end

local ECollisionEnabled =   {
    NoCollision                              = 0,
    QueryOnly                                = 1,
    PhysicsOnly                              = 2,
    QueryAndPhysics                          = 3,
    ECollisionEnabled_MAX                    = 4,
}

function _uobject:enable_collision(collision_type, colision_channel, response)
    self:SetCollisionEnabled(ECollisionEnabled[collision_type])
    self:SetCollisionObjectType(ECollisionChannel[collision_channel])
    self:SetCollisionProfileName("OverlapAll", true)
   self:SetCollisionResponseToChannel(ECollisionChannel[collision_channel], ECollisionResponse[response])
end

function _uobject:get_materials()
    local num_mats = self.GetNumMaterials and self:GetNumMaterials() or nil
    if num_mats ~= nil then
        local t = {}
        for i=0,num_mats do
            t[i+1] = self:GetMaterial(i)
        end
        return t
    end
end



function _uobject:distance_to(other)
    local s,r = pcall(function() return (self:location() - other:location()):length() end)
    if s then return r end
end



function _uobject:time_dilation()
    return self:as_actor():GetTimeDilation()
end



function _uobject:get_bounds()
    local origin, extent, radius = {}, {}, {}
    if self.GetBounds then self:GetBounds(origin, extent, radius)
        return origin.result, extent.result, radius.result
    else
        Kismet("System"):GetComponentBounds(self:as_component(), origin, extent, radius)
        return origin.result, extent.result, radius.result
    end
end


function Vector3:world_to_screen()
    local out = {}
    pc = pc or api:get_player_controller(0)
    Statics:ProjectWorldToScreen(pc, self, out, true)
    return Vector2f.new(out.result.X, out.result.Y)
end

function _uobject:world_to_screen()
    return self.location and self:location():world_to_screen()
end


function Vector2f:screen_to_world()
    local WorldPos = {}
    local WorldDir = {}
    pc = pc or api:get_player_controller(0)
    Statics:DeprojectScreenToWorld(pc, self, WorldPos, WorldDir)
    return WorldPos.result, WorldDir.result
end


function _uobject:distance(other)
    return (self:location() - other:location()):length()
end


function  _uobject:calc_lookat(other)
    local v = self:forward() - other:forward()
    local distance = v:length()
    return v:normalized(), distance
end

function _uobject:trace_component(start, endpos)
    local prim = self:class_is_child_of("PrimitiveComponent") and self or self:get_component("PrimitiveComponent")
    start = start or get_camera_location()
    endpos = endpos or start:extrapolate(prim:location(), 1024)
    local hitresults = Kismet("System"):check_output("K2_LineTraceComponent", {TraceStart = start, TraceEnd = endpos, bTraceComplex =  true, bShowTrace = false, bPersistentShowTrace = false})
    local fullresult = Statics:check_output("BreakHitResult", {Hit = hitresults.OutHit})
    return fullresult
end


function  _uobject:look_at_obj(other)
    local lookat, distance = self:calc_lookat(other)

    self:set_rotation(self:rotation():lerp(lookat, 1 ))
end

function  _uobject:look_at_obj2(other)
    self:set_rotation(self:rotation():lookat(other.forward and other:forward() or other))
end

-- function _uobject:bounds_to_screen()
--     local origin, extent, radius = self:get_bounds()
--     if origin then
--         local origin_ss = origin:world_to_screen()
--         local

-- end

-- ragdoll =
-- breakhitresult => get bone name => if not hit bone try different collision channel or manually calculate trace and bone location => get closest bone
-- => all bodies below simulate physics => add impulse at location =>disable capsule component collision



function cam_rotation()
    return pc.PlayerCameraManager:GetCameraRotation()
end

function cam_location()
    return pc.PlayerCameraManager:GetCameraLocation()
end

_ENV.UEVR_UObject =      _uobject
_ENV.UEVR_UStruct =      _ustruct
_ENV.UEVR_UClass =       _uclass
_ENV.UEVR_UFunction =    _ufunction
_ENV.UEVR_FField =       _ffield
_ENV.UEVR_FProperty =    _fproperty
_G.UEVR_UObject =        _uobject
_G.UEVR_UStruct =        _ustruct
_G.UEVR_UClass =         _uclass
_G.UEVR_UFunction =      _ufunction
_G.UEVR_FField =         _ffield
_G.UEVR_FProperty =      _fproperty
