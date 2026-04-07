local functions = uevr.params.functions
UEVR_TAG = functions.get_tag()
api = uevr.api
UEVR_COMMITS_PAST_TAG = functions.get_commits_past_tag()
UEVR_COMMIT_HASH = functions.get_commit_hash()
UEVR_NAME = "UEVR ["..tostring(UEVR_TAG).."+"..tostring(UEVR_COMMITS_PAST_TAG).."-"..(tostring(UEVR_COMMIT_HASH):sub(1,8)).."]"
 colors = {
        Vector4f.new(1.00, 1.00, 1.00, 1.0),
        Vector4f.new(0.86, 0.93, 0.89, 0.68),
        Vector4f.new(0.13, 0.14, 0.17, 0.70),
        Vector4f.new(0.13, 0.14, 0.17, 1.0),
        Vector4f.new(0.31, 0.31, 1.00, 0.04),
        Vector4f.new(0.00, 0.00, 0.00, 0.00),
        Vector4f.new(0.20, 0.22, 0.27, 1.00),
        Vector4f.new(0.92, 0.18, 0.29, 0.78),
        Vector4f.new(0.92, 0.18, 0.29, 1.00),
        Vector4f.new(0.20, 0.22, 0.27, 1.00),
        Vector4f.new(0.20, 0.22, 0.27, 0.75),
        Vector4f.new(0.92, 0.18, 0.29, 1.00),
        Vector4f.new(0.20, 0.22, 0.27, 0.47),
        Vector4f.new(0.20, 0.22, 0.27, 1.00),
        Vector4f.new(0.09, 0.15, 0.16, 1.00),
        Vector4f.new(0.92, 0.18, 0.29, 0.78),
        Vector4f.new(0.92, 0.18, 0.29, 1.00),
        Vector4f.new(0.71, 0.22, 0.27, 1.00),
        Vector4f.new(0.47, 0.77, 0.83, 0.14),
        Vector4f.new(0.92, 0.18, 0.29, 1.00),
        Vector4f.new(0.47, 0.77, 0.83, 0.14),
        Vector4f.new(0.92, 0.18, 0.29, 0.86),
        Vector4f.new(0.92, 0.18, 0.29, 1.00),
        Vector4f.new(0.92, 0.18, 0.29, 0.76),
        Vector4f.new(0.92, 0.18, 0.29, 0.86),
        Vector4f.new(0.92, 0.18, 0.29, 1.00),
        Vector4f.new(0.14, 0.16, 0.19, 1.00),
        Vector4f.new(0.92, 0.18, 0.29, 0.78),
        Vector4f.new(0.92, 0.18, 0.29, 1.00),
        Vector4f.new(0.47, 0.77, 0.83, 0.04),
        Vector4f.new(0.92, 0.18, 0.29, 0.78),
        Vector4f.new(0.92, 0.18, 0.29, 1.00),
        Vector4f.new(0.86, 0.93, 0.89, 0.63),
        Vector4f.new(0.92, 0.18, 0.29, 1.00),
        Vector4f.new(0.86, 0.93, 0.89, 0.63),
        Vector4f.new(0.92, 0.18, 0.29, 1.00),
        Vector4f.new(0.92, 0.18, 0.29, 0.43),
        Vector4f.new(0.20, 0.22, 0.27, 0.9),
        Vector4f.new(0.20, 0.22, 0.27, 0.73),
    }
function VecToU32(vec)
    local r = math.floor(math.max(0, math.min(255, vec.x * 255 + 0.5)))
    local g = math.floor(math.max(0, math.min(255, vec.y * 255 + 0.5)))
    local b = math.floor(math.max(0, math.min(255, vec.z * 255 + 0.5)))
    local a = math.floor(math.max(0, math.min(255, vec.w * 255 + 0.5)))

    -- ImGui expects 0xAABBGGRR
    return (a << 24) | (b << 16) | (g << 8) | r
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
--[[
function UEVR_UObject:add_component(uclass)
    local t = api:add_component_by_class(
        self,
        uclass,
        false
    )
    t:K2_SetRelativeTransform(self.GetRelativeTransform and self:GetRelativeTransform() or self.RootComponent:GetRelativeTransform(), false, {}, false)
    return t
end

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


]]

local stylevar = {

--Alpha",
1.0,
--DisabledAlpha",
0.7,
--WindowPadding",
Vector2f.new(2.0, 2.0),
--WindowRounding",
10.0,
--WindowBorderSize",
2.0,
--WindowMinSize",
Vector2f.new(60.0, 120.0),

--WindowTitleAlign",
Vector2f.new(0.5, 0.5),

--ChildRounding",
8,
--ChildBorderSize",
2,
--PopupRounding",
10,
--PopupBorderSize",
2,
--FramePadding",
0.5,
--FrameRounding",
10,
--FrameBorderSize",
0.0,
--ItemSpacing",
Vector2f.new(2.0, 2.0),

--ItemInnerSpacing",
Vector2f.new(2.0, 2.0),

--IndentSpacing",
8,
--CellPadding",
Vector2f.new(2.0, 2.0),

--ScrollbarSize",
22,
--ScrollbarRounding",
10,
--GrabMinSize",
15,
--GrabRounding",
12,
--TabRounding",
0,
--ButtonTextAlign",
Vector2f.new(0.5, 0.5),

--SelectableTextAlign",

--SeparatorTextBorderSize",

--SeparatorTextAlign",

--SeparatorTextPadding"

}
local float_value = 0
local text_buffer = ""
local checked = false
local res
local selected_node
local function on_screen(pos)
    res = res or imgui.get_display_size()
    if (pos.x < 0 or pos.y < 0 or pos.x > res.x or pos.y > res.y) then return false
    else return true end
end
-- ins = case insensitive
function string:contains(subword, ins, start)
    return ((ins and self:lower() or self):find((ins and subword:lower() or subword), start or 1, true) ~= nil)
end


local function example_widget()
     if imgui.begin_menu("menu", true) then
                   imgui.menu_item("I do nothing")
                   local c, nv = imgui.slider_float("Float Slider", float_value, 0.01, 3.0)
                   if c and float_value ~= tempscalar then float_value = nv end
                   local c, nt, selection_start, selection_end = imgui.input_text_multiline("InputText", text_buffer, Vector2f.new(200, 200))
                   if c then text_buffer = nt end
                   imgui.begin_group()
                   local c, nv = imgui.checkbox("Checkbox", checked)
                   if c then checked = nv end
                   imgui.same_line()
                   imgui.text(checked and "Doing thing!" or "Do thing?")
                   imgui.end_group()
                   imgui.end_menu()
                end
                if imgui.begin_menu("menu2") then
                   imgui.text("hi")
                 imgui.end_menu()
                    end

end

local visible_node = nil
function DrawTreeNode(node, filtertext)
    local node_open = false

    imgui.table_next_row()
    imgui.table_next_column()
    imgui.push_id(node.id)
    visible_node = on_screen(imgui.get_cursor_screen_pos()) and node
    if visible_node and node == visible_node  then
        node.pos = imgui.get_scroll_y()

        imgui.set_next_item_open(true, 4)
    end

    -- if node.value == false then
    --     imgui.push_style_color(0, VecToU32(Vector4f.new(0.6, 0.6, 0.6, 1.0)))
    -- end
    if #(node.children) == 0 then
        imgui.text(node.name)
        imgui.same_line()
        if imgui.small_button("Select") then
            selected_node = node
        end
    else
        node_open = imgui.tree_node(node.name)
        -- if node.value == false then
        --     imgui.pop_style_color(1)
        -- end
    end
    if imgui.is_item_active() or imgui.is_item_focused() then visible_node = node end

    if node_open then
        for i, child in ipairs(node.children)
            do
            if (not filtertext) or (child and child.name and (filtertext:contains(child.name, true) or child.name:contains(filtertext, true)) or #filtertext == 0) then
                DrawTreeNode(child)
            end
        end
        imgui.tree_pop()
    end
    imgui.pop_id()
end



local filtertext = ""
function TreeTable(root_node, widget, widget_default_args)
  if imgui.begin_child_window("##tree", Vector2f.new(0,0), true, 8388608 + 64) then
    local width = math.min(math.min(imgui.get_display_size().x * 0.25, math.max(imgui.get_window_size().x * 0.75)), imgui.get_window_size().x)
    imgui.push_item_width(width)
        local c, nt, s1, s2 = imgui.input_text("Filter", filtertext, 1048576)
        if c then filtertext = nt end

      if imgui.begin_table("##bg", selected_node and 2 or 1, 268526305) then
            imgui.table_setup_column("Items", 8 , width * (selected_node and 0.5 or 0.65) )
            if selected_node then
                imgui.table_setup_column("Inspector", 8, width * 0.5)
            end
            imgui.indent()
            imgui.table_next_row()
            imgui.table_set_column_index(0)
                if imgui.begin_table("##Items", 1, 268526305) then
                imgui.table_setup_column("Items", 8 , width * (selected_node and 0.5 or 0.65) )
                imgui.table_next_row()
                imgui.table_set_column_index(0)
                -- DrawTreeNode(root_node)
                for i, node in ipairs(root_node.children) do
                    if node and node.name and (filtertext:contains(node.name, true) or node.name:contains(filtertext, true)) or #filtertext == 0 then
                        DrawTreeNode(node, filtertext)
                    end
                end
                imgui.end_table()
             end

            if selected_node then
                imgui.table_next_column()

                imgui.begin_child_window("child",  imgui.get_window_size() * 0.5, true)
                                if selected_node and selected_node.pos then imgui.set_scroll_y(selected_node.pos) end
                if imgui.small_button("clear") then selected_node = nil end
                    if widget and type(widget) == "function" then
                        local args = widget_default_args
                        if not args then args = {} end
                            table.insert(args, selected_node.name)
                            table.insert(args, selected_node.data)

                        widget(table.unpack(args))


                    end
                    imgui.end_child_window()
            end
            imgui.end_table()
        end
      imgui.pop_item_width()
      imgui.end_child_window()
    end
end


local node_data = {}
-- Prep data for the tree-node table widget inspired by the ImGui demo PropertyEditor
-- Keys should be an array of strings, parents should be a lookup table with string keys and string values
-- data should be a table of data associated with each key and inspector widget should be a function to interact with said data
-- root_key and zero_key are optional parameters to ensure proper sorting
function CreateTreeNode(args)
    local label = args.label or "Node Data"
    local keys = args.keys or args.data.__orderedIndex
    local parents = args.parents or nil
    local data = args.data
    local widget = args.widget or nil
    local widget_default_args = args.widget_default_args or nil
    local root_key = args.root_key or "None"


    node_data = node_data or {}
    node_data[tostring(keys)] = node_data[tostring(keys)] or {}
    local _nodes = node_data[tostring(keys)]
    local root_node = {
        name = label,
        value = true,
        id = "virtual_root",
        children = {
        }
    }

    local function build_table()
        if #_nodes == 0 then
        -- First create node objects for every key
        for _, key in ipairs(keys) do
            if key and key ~= "None" and key ~= "" and (not root_key or root_key and key ~= root_key) then
                _nodes[key] = {
                    id = imgui.get_id(key),
                    name = key,
                    children = data.children or {},
                    data = data.key
                }
            end
        end
        for _, key in ipairs(keys) do
            local node = _nodes[key]
            if node then
                local children = node.children or {}
                if #children == 0 and parents ~= nil then
                -- Attach children to their parents
                    for child, parent in pairs(parents) do
                        if parent and parent == key then
                            if _nodes[child] then
                                table.insert(children, _nodes[child])
                                _nodes[parent].children = children
                            end
                        elseif not parent and _nodes[child] then table.insert(root_node.children, _nodes[child])
                        end
                    end
                end
            end
        end
    end
end
    local real_root = _nodes["Root"] or _nodes["None"] or (root_key and _nodes[root_key])
    if real_root then
        table.insert(root_node.children, real_root)
    end

   TreeTable(root_node, widget, widget_default_args)

end


local Statics = api:find_uobject("Class /Script/Engine.GameplayStatics"):get_class_default_object()
local variables = {}



function GetCharacterMesh()
    pc = pc or api:get_player_controller(0)
    pawn = pawn or api:get_local_pawn(0)
    if pawn == nil then
        return
    end
    local character = Statics:GetPlayerCharacter(pc, 0)
    if character ~= nil and character.Mesh ~= nil then
        return character.Mesh
        -- marvel
    elseif pawn.ChildActorComponent ~= nil and pawn.ChildActorComponent.ChildActor ~= nil then
        return pawn.ChildActorComponent.ChildActor.Mesh
        -- mhur
    elseif pawn._mesh ~= nil then
        return pawn._mesh
        -- Infinity nikki (bastards think they're clever)
    elseif
        pc.ControlPawn ~= nil
        and pc.ControlPawn.BP_PlayerAnimStatesComponent ~= nil
        and pc.ControlPawn.BP_PlayerAnimStatesComponent.X6CharacterOwner ~= nil
    then
        local meshes = pc.ControlPawn.BP_PlayerAnimStatesComponent.X6CharacterOwner:K2_GetComponentsByClass(
            api:find_uobject("Class /Script/Engine.SkeletalMeshComponent")
        )
        for idx, val in ipairs(meshes) do
            if val:get_short_name() == "CharacterMesh0" then
                return val
            end
        end
        -- Fullmetal School Girl
    elseif pawn.MainMesh ~= nil then
        return pawn.MainMesh
    -- any other games with weird main character meshes?
    else
        for idx, val in ipairs(api:find_uobject("Class /Script/Engine.SkinnedMeshComponent"):get_objects_matching(false)) do
            if val:get_fname():to_string() == "CharacterMesh0" then
                -- Generally every game should have their mesh named as CharacterMesh0 and sitting at a distance of 82 from the pawn
                if (val:get_outer() == pawn) or val.K2_GetComponentLocation and (val:K2_GetComponentLocation() - pawn:K2_GetActorLocation()):length() < 85 then
                    return val
                end
            end
        end
    end
end


local function toggle_bone(mesh, bone)
    if mesh:IsBoneHiddenByName(bone) then
        mesh:UnHideBoneByName(bone)
    else
        mesh:HideBoneByName(bone)
    end
end

local function does_socket_exist(mesh, bone)
    local bone_idx = mesh:GetBoneIndex(bone)
    if bone_idx == 0 or bone_idx == nil then
        return mesh:DoesSocketExist(bone)
    else return true
    end
end


-- actual sockets, not bones
-- typically most functions calling for one or the other accept either
local function get_skeletal_mesh_sockets(mesh)
    local all_sockets, bone_sockets = {}, {}
    local sockets = mesh.AnimScriptInstance.CurrentSkeleton.Sockets
    for idx, val in ipairs(sockets) do
        local t = {
            socket_name = val.SocketName:to_string(),
            RelativeLocation = val.RelativeLocation,
            RelativeRotation = val.RelativeRotation,
            RelativeScale = val.RelativeScale,
            always_animated = val.bForceAlwaysAnimated,
        }
        local bone_name = val.BoneName:to_string()
        bone_sockets[bone_name] = bone_sockets[bone_name] or {}
        table.insert(bone_sockets[bone_name],  t)
        t.bone_name = bone_name
        all_sockets[val] = t

    end
    return all_sockets, bone_sockets
end




local function get_bone_transform(mesh, bone, space)
    return mesh.GetBoneTransform and
        mesh:GetBoneTransform(bone, space or 0) or
        mesh:GetSocketTransform(bone, space or 0)
end


local function get_bone_transforms(bones, mesh, transform_space, tostring)
    local t = {}
    for idx, val in ipairs(bones) do
        local trans = get_bone_transform(mesh, val, transform_space or 0)
        if tostring then t[val] = Kismet.String:Conv_TransformToString(trans)
        else t[val] = trans
        end
    end
    t.__ordered_index = bones
    return t
end

local function get_bone_screen_space(bones, mesh)
    local t = {}
    for name, val in pairs(bones) do
        t[name] = (get_location_from_transform(val):world_to_screen())
    end
    return t
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



function dump_bone_info(mesh)
    local _numbones =  mesh:GetNumBones()
    local bone_names = {}
    local bone_parents = {}

        for i = 0, _numbones do
            local bone_name = mesh:GetBoneName(i)
             table.insert(bone_names, bone_name:to_string())
            bone_parents[bone_name] = mesh:GetParentBone(bone_name):to_string()
        end


        json.dump_file("Bones\\"..mesh:get_fname():to_string()..".json", bone_names, 4)
        json.dump_file("Bones\\"..mesh:get_fname():to_string().."_parents.json", bone_parents, 4)

        return bone_names, bone_parents
end

local function find_attachments(comp)
    local t = {}
    local attach_children = comp.AttachChildren
    if attach_children then
        for i,v in ipairs(attach_children) do
            t[v] = v.AttachSocketName:to_string()
        end
        return t
    end
    return nil
end

local generics = {
    Light = "PointLightComponent",
    Camera = "CameraComponent",
    SpringArm = "SpringArmComponent",
    Sphere = "SphereComponent",
    Arrow = "ArrowComponent",
    StaticMesh = "StaticMeshComponent",
    Widget = "WidgetComponent"
}

local selected_obj = "Light"
local function attach_generic_object(mesh, bone)
    local c, n = imgui.combo(imgui.get_id("Attachments"), selected_obj, generics)
    if c then selected_obj = n end
    if imgui.button("Attach") then
        local comp_class = api:find_uobject("Class /Script/Engine."..generics[selected_obj])
        local comp = mesh:get_outer():add_component(comp_class)
        comp:K2_AttachToComponent(mesh, bone, 2, 0, 2, false)
    end
end

local function bone_widget(mesh, bone, data)
    if data.ref_pose then imgui.text(Kismet.String:Conv_TransformToString(data.ref_pose)) end
    if data.sockets then
        for i, socket in ipairs(data.sockets) do
           if imgui.tree_node_ptr_id(i, socket.socket_name) then
                imgui.text("Relative Location") imgui.same_line() imgui.text(Kismet.String:Conv_VectorToString(val.RelativeLocation))
                imgui.text("Relative Rotation") imgui.same_line() imgui.text(Kismet.String:Conv_VectorToString(val.RelativeRotation))
                imgui.text("Relative Scale") imgui.same_line() imgui.text(Kismet.String:Conv_VectorToString(val.RelativeScale))
                imgui.text("Always Animated"..tostring(val.bForceAlwaysAnimated))
                imgui.tree_pop()
            end
        end
    end
    if imgui.button("Toggle Bone") then
        toggle_bone(mesh, bone)
    end
    if data.attach_children then
        for i, object in ipairs(data.attach_children) do
            imgui.text(object:get_full_name())
        end
    end
    attach_generic_object(mesh, bone)
end


local function build_bone_data()
    local mesh = GetCharacterMesh()
    if not mesh then mesh = api:get_local_pawn().CharacterMesh0 end
    local bone_names, bone_parents = dump_bone_info(mesh)
    local ref_poses = get_ref_poses(mesh)
    local all_sockets, bone_sockets = get_skeletal_mesh_sockets(mesh)
    local data = {}
    for i, bone in ipairs(bone_names) do
        data[bone_name] = {
            ref_pose = ref_poses[bone],
            sockets = bone_sockets and bone_sockets[bone] or nil,
        }
    end

    -- local attach_children = find_attachments(mesh)
    -- if attach_children then
    --     for object, socket in pairs(attach_children) do
    --         if socket and data[socket] then
    --             data[socket].attach_children = data[socket].attach_children or {}
    --             table.insert(data[socket].attach_children, object)
    --         elseif all_sockets and all_sockets[socket] then
    --             local bone = all_sockets[socket].bone_name
    --             data[bone_name].attach_children = data[bone_name].attach_children or {}
    --             table.insert(data[bone_name].attach_children, object)
    --         end
    --     end
    -- end

    local args = {
        label = "Bone",
        keys = bone_names,
        parents = bone_parents,
        data = data,
        widget = bone_widget,
        root_key = "Root",
        widget_default_args = {mesh}

    }
    return args
end





local root_name = nil
local TestBones = require("testbones")
local bone_parents = TestBones.bone_parents
local bone_names = TestBones.bones
local bone_chains = TestBones.bone_chains
local nodes


local root_node

local function test_imgui_tree_table()
    nodes = nodes or {}

    if #nodes == 0 then
        -- First create node objects for every bone
        for _, bone in ipairs(bone_names) do
            if bone ~= "None" then
                nodes[bone] = {
                    id = bone,
                    name = bone,
                    children = {},
                    value = true
                }
            end
        end
        for _, bone in ipairs(bone_names) do
            local node = nodes[bone]
            if node then
                local children = node.children or {}
                -- Attach children to their parents
                for child, parent in pairs(bone_parents) do
                    if parent and parent == bone then
                        if nodes[child] then
                            table.insert(children, nodes[child])
                            nodes[parent].children = children
                        end
                    end
                end
            end
        end
    end
    local real_root = nodes["Root"] or nodes["None"]
    root_node = {
        name = "Bones",
        value = true,
        id = "virtual_root",
        children = {
            real_root
        }
    }

   TreeTable(root_node)
end

local args
uevr.lua.add_script_panel("Tree Table Test", function()
local s,r = pcall(function()
     -- test_imgui_tree_table()
     args = args or build_bone_data()
     if args then
        CreateTreeNode(args)
    end
end) if not s then print(r) end

end)


local res
local no_inputs = false
local menu_bar = true
local no_nav = true
local set_pos = false
local set_size = false
local window_size = Vector2f.new(1000, 500)
local window_pos = res and res * 0.5 or Vector2f.new(0,0)
uevr.sdk.callbacks.on_frame(function()
    res = res or imgui.get_display_size()
    local colorcount=0
    local stylecount=0
    if functions.is_drawing_ui() then
        imgui.push_font(imgui.load_font("Comic.ttf", 16))
        for i,v in ipairs(colors) do
                colorcount = colorcount + 1
            imgui.push_style_color(i-1, VecToU32(v))
        end
        for i,v in ipairs(stylevar) do
            stylecount = stylecount +1
            imgui.push_style_var(i-1,v)
        end
        no_inputs = imgui.is_key_pressed(571)

        imgui.begin_window(UEVR_NAME, true, 0 + (no_inputs and 197120 or 0) + (menu_bar and 1024 or 0) + (no_nav and 196608 or 0))
        if imgui.begin_menu_bar() then
            if imgui.begin_menu("HACKS") then
                imgui.menu_item("Placeholder")
                imgui.end_menu()
            end
            imgui.end_menu_bar()
        end
        imgui.end_window()
        imgui.pop_style_color(colorcount)
        imgui.pop_style_var(stylecount)
        imgui.pop_font()
    end
end)


