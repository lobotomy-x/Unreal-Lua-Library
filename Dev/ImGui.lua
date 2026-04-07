local ImGui = {}
local changed = false
local selection_start, selection_end = 0,0
local functions = uevr.params.functions

local onframe = uevr.sdk.callbacks.on_frame




local vector = _G.vector
local UEVR_NAME = _G.UEVR_NAME or function()
    local UEVR_TAG = functions.get_tag()
    local UEVR_COMMITS_PAST_TAG = functions.get_commits_past_tag()
    local UEVR_COMMIT_HASH = functions.get_commit_hash()
    return "UEVR ["..tostring(UEVR_TAG).."+"..tostring(UEVR_COMMITS_PAST_TAG).."-"..(tostring(UEVR_COMMIT_HASH):sub(1,8)).."]"
end

local ImGuiFlags = require("ImGuiFlags")
local ImGuiThemes = require("ImGuiThemes")
local vr = uevr.params.vr
local api = uevr.api
local functions = uevr.params.functions
local draw_inputs = true
local current_pressed_keys = {}
local current_released_keys = {}
local last_key_time = {}
local double_pressed_keys = {}
local double_press_period = 0.5
local ids = {}
local apply_main_gui = false
local use_menu_bar = true
local ImGuiCol = {
    array = {"Text", "TextDisabled", "WindowBg", "ChildBg", "PopupBg",
    "Border", "BorderShadow", "FrameBg", "FrameBgHovered",
    "FrameBgActive", "TitleBg", "TitleBgActive", "TitleBgCollapsed",
    "MenuBarBg", "ScrollbarBg", "ScrollbarGrab", "ScrollbarGrabHovered",
    "ScrollbarGrabActive", "CheckMark", "SliderGrab", "SliderGrabActive",
    "Button", "ButtonHovered", "ButtonActive", "Header", "HeaderHovered",
    "HeaderActive", "Separator", "SeparatorHovered", "SeparatorActive",
    "ResizeGrip", "ResizeGripHovered", "ResizeGripActive", "Tab",
    "TabHovered", "TabActive", "TabUnfocused", "TabUnfocusedActive",
    "PlotLines", "PlotLinesHovered", "PlotHistogram", "PlotHistogramHovered",
    "TableHeaderBg", "TableBorderStrong", "TableBorderLight", "TableRowBg",
    "TableRowBgAlt", "TextSelectedBg", "DragDropTarget", "NavHighlight",
    "NavWindowingHighlight", "NavWindowingDimBg", "ModalWindowDimBg"},
}

local ImGuiDir =
{
    None    = -1,
    Left    = 0,
    Right   = 1,
    Up      = 2,
    Down    = 3,
}

local imguiarrow = imgui.arrow_button
function imgui.arrow_button(str_id, dir)
    dir = (type(dir) == "string" and ImGuiDir[dir]) or dir
    return imguiarrow(str_id, dir)
end

function ImGui.Begin(id, open, flags)
    local changed = imgui.begin_window(imgui.get_id(id), open, flags)
    if changed then open = not open end
    if not open then imgui.end_window()
    end
end

local defaults = {
    scroll_speed = 0.5,
    scroll_distance = imgui.calc_text_size("A").y * 1.5
}

function ImGui.CanvasWindow(name, inputs, mouse)

        name = name or "Canvas"
        res = res or imgui.get_display_size()
        imgui.set_next_window_size(res)
        imgui.set_next_window_pos(Vector2f.new(0, 0 ))
        local flags ={"NoBackground", "NoNav", "NoScrollbar", "NoScrollWithMouse", "NoMove",
    "NoFocusOnAppearing", "NoCollapse", "NoTitleBar", "NoResize", "NoBringToFrontOnFocus"}
        if not inputs and not mouse then table.insert(flags, "NoMouseInputs")
        elseif not inputs then table.insert(flags, "NoInputs")  end
        imgui.begin_window("Canvas", true, ImGui.CalcFlags(flags, "Window"))
end



-- Get enum/int value of style colors by name (omit the ImGuiCol_)
-- initially searches an array but builds lookup table as its used
-- this is done largely out of laziness/incompetence but I've turned it into a lesson
-- you're welcome
function ImGui.Col(str)
    if ImGuiCol[str] ~= nil then
        return ImGuiCol[str]
    else
        for i = 1, 53 do
            if str == ImGuiCol.array[i] then
                ImGuiCol[str] = i-1
                return ImGuiCol[str]
            end
        end
    end
end

local res = nil


local res
-- using this for caching and to allow querying imgui from callbacks that can't run imgui code
function ImGui.Resolution()
    if not res then
            uevr.sdk.callbacks.on_frame(function()
            res = imgui.get_display_size()
        end)
    end
    return res or Vector2f.new(1920, 1080)
end
    local error_pos = nil
    local error_color = nil


ImGui.U32toV = u32_to_v
local uint = 0
local prev_vec = nil

-- These are just cases of me being lazy and not wanting to find and replace everywhere I may have used the ImGui version
ImGui.VecToU32 = vec_to_u32



ImGui.VectoHexStr = VecToHexStr


ImGui.StrToU32 = StrToU32
local char_height = imgui.calc_text_size("H").y

local char_width = imgui.calc_text_size("W").x

-- "Static" function to get flags programmatically
-- If you want interactive flag setting check the commented out panel below
-- flags here should be an array of strings but you can also submit a flags "object" to sum up the active flags
-- and just for thoroughness if you don't include the item type we can still find it but don't do that...
-- example usage: imgui.begin_window("Menu Host", true, ImGui.CalcFlags({"AlwaysAutoResize"}, "Window"))
function ImGui.CalcFlags(flags, itemType)
    if itemType ~= nil and not itemType:contains("Flags") and itemType ~= "Cond" then
        itemType = itemType.."Flags"
    end
    local result = 0
    for k, v in pairs(flags) do
        if type(v) == "string" then
            if itemType ~= nil and  ImGuiFlags[itemType] ~= nil and  ImGuiFlags[itemType][v] ~= nil then

                result = result + ImGuiFlags[itemType][v].value
            else
                for name, val in pairs(ImGuiFlags) do
                    for _name, _val in pairs(val) do
                        if _name == k then result = result + _val.value end
                    end
                end
            end
        else
            if type(v) == "table" and v.active then
                result = result + v.value
            end
        end
    end
    return result
end



-- Apply ImGui style to a group of items contained in a function
-- This can be anything from a single line of text to entire windows
-- StyleColors must be a table with {name = Vector4f} or {name = {r, g, b, a}} format
-- If you need to pass args you can either use the parameter here
-- or you can define a local value to call your function with the args
--      function myCoolWidget(parm1, parm2) dothing(parm1,parm2) end
--      local parm1, parm2 = 1,2
--      local evalwidget = function() myCoolWidget(parm1, parm2) end

function ImGui.GroupStyle(widget, StyleColors, StyleVars, width)
    local count = 1
    if type(widget) ~= "function" then return end
    local varCount = 0
    width = math.min(width or math.min(imgui.get_display_size().x * 0.25, math.max(imgui.get_window_size().x * 0.75)), imgui.get_window_size().x)
    imgui.push_item_width(width)
    if StyleColors ~= nil then
        for name, val in pairs(StyleColors) do
            local color = coerce_color_type(val)
            if color then
            imgui.push_style_color(ImGui.Col(name), color)
            count = count + 1
         end
        end
    end
    if StyleVars ~= nil then
        for name, val in pairs(StyleVars) do
            imgui.push_style_var(name, val)
            varCount = varCount + 1
        end
    end
    local s,r = pcall(function()
           widget()

    end)
    if not s then print(r) end
    imgui.pop_style_color(count)
    imgui.pop_style_var(varCount - 1)
    imgui.pop_item_width()
end

function ImGui.BeginStyle(StyleColors, StyleVars, width, font)
    local colorCount = 1
    local varCount = 1
    local pushedFont = font ~= nil
    if font then imgui.push_font(font) end
    width = math.min(width or math.min(imgui.get_display_size().x * 0.5, imgui.get_window_size().x * 0.75))
    imgui.push_item_width(width)
    if StyleColors ~= nil then
        for name, val in pairs(StyleColors) do
            local color = coerce_color_type(val)
            if color then
            imgui.push_style_color(ImGui.Col(name), color)
             colorCount = colorCount + 1
         end
        end
    end
    if StyleVars ~= nil then
        for name, val in pairs(StyleVars) do
            imgui.push_style_var(name, val)
            varCount = varCount + 1
        end
    end
    return colorCount, varCount, pushedFont
end

local warnings = {}
local results = {}

function ImGui.EndStyle(colorCount, varCount, pushedFont)
    imgui.pop_style_color(colorCount)
    imgui.pop_style_var(varCount-1)
    if pushedFont then imgui.pop_font() end
    imgui.pop_item_width()
end

-- Essentially doing it like this you "instantiate" a flags object of the specified type
-- and make use of the "active" property for persistent storage that can easily be jsonified
local bflags = ImGuiFlags.ButtonFlags
local calcedflags = 0


-- modal windows have a dedicated function in normal imgui but they actually are just windows with certain flags
-- these windows are popups that capture input and go to the top layer. they can't be closed by clicking outside
-- you can have input passthrough on the background canvas and spawn modals that capture input temporarily, this is probably the best use
-- currently you do need to ensure that this window stays open somehow
-- normally they also fade out the background a bit however we are NOT using real modals and that feature is not present here
-- These are just normal windows but I'm passing the internal use only modal flag
local open_modals = {}
function ImGui.ModalWindow(label, window_content, param, pos, size, styles, fade_bg)

        if fade_bg then
            imgui.push_style_color(ImGui.Col("WindowBg"), Vector4f.new(0.2, 0.2, 0.2, 0.8))
            if imgui.begin_window("fakemodalbg", true, ImGui.CalcFlags({"NoNav", "NoScrollbar", "NoScrollWithMouse", "NoMove", "NoFocusOnAppearing", "NoCollapse", "NoTitleBar", "NoResize", "NoBringToFrontOnFocus"}, "Window"))
            then imgui.end_window() end
            imgui.pop_style_color(1)
        end

        if pos == nil then pos = ImGui.Resolution() * 0.4 end
        imgui.set_cursor_screen_pos(pos) imgui.set_next_window_pos(pos)
        if size ~= nil then imgui.set_next_window_size(size) end

        local function window_func()
            if imgui.begin_window(label, nil, ImGui.CalcFlags({"Modal"}, "Window")) then
            -- if imgui.small_button("Close") then close = true end
                window_content(param)
                imgui.end_window()
            end
        end

        if styles ~= nil then
            ImGui.GroupStyle(window_func, styles)
        else
            window_func(param)
        end

end


local bg_flags = {}
local default_active_flags = {
    "NoBackground",
    "NoBringToFrontOnFocus",
    "NoCollapse",
    "NoFocusOnAppearing",
    "NoMouseInputs",
    "NoMove",
    "NoNav",
    "NoNavFocus",
    "NoResize",
    "NoScrollWithMouse",
    "NoScrollbar",
    "NoTitleBar"
}
local flags = ImGui.CalcFlags(default_active_flags, "Window")
local function setup_bg_flags()
    if not fs.exists("window_flags.json") then
        bg_flags = {}
        for k, v in pairs(ImGuiFlags.WindowFlags) do
            bg_flags[k] = v
            for i, val in ipairs(default_active_flags) do
                if k == val then bg_flags[k].active = true end
            end
        end
        json.dump_file("window_flags.json", bg_flags, 4)
    else
        bg_flags = json.safe_read("window_flags.json")
    end
end
setup_bg_flags()


-- function ImGui.menu_item()

local font_cache = {}
local function load_font(name)
    if not font_cache[name] then
        font_cache[name] = imgui.load_font(name)
    end
    return font_cache[name]
end

local object_search_box = {}
object_search_box.input = 0
object_search_box.found_object = UEVR_UObject.new()
object_search_box.results = {}





local time, clock, max, min = os.time, os.clock, math.max, math.min
local obj_data = {}

local active_object, cursor = 0, 0
local open_pack, class_names, class_short_names, class_paths, class_count, package_names, package_classes, open_classes, class_objects
local class_functions, class_structs, class_filter, package_filter, property_search, function_search

local function instance_menu(instance)

end
local function class_node(obj, class_data)
    if not class_data then
        local uclass = find_fast(obj)
        local pack = uclass:get_outer():get_full_name()
        local jsonname = "UObjects\\"..uclass:get_full_name()..".json"
        local s,r = pcall(function()

            local t = json.load_file(jsonname)
            if t ~= nil then return t
            end
        end)
        if s then class_data = r
        else
            class_data = {}
            class_data.uclass = uclass
            class_data.properties = class:get_property_data()
            class_data.functions = class:get_function_data()
            json.dump_file(jsonname, class_data)
        end
    end
    local function class_instance_view(open, class_instances)
        class_instances = class_instances or class:find_all_instances(true)
        imgui.text(#class_instances.." Instances") imgui.same_line()
        if imgui.small_button("Refresh") then
              class_instances = class:find_all_instances(true)
        end
        imgui.separator()
        if open then
            for i, v in ipairs(class_instances) do
                local cursorscreen = imgui.get_cursor_screen_pos()
                if cursorscreen.y < imgui.get_display_size().y and -1 < cursorscreen.y then
                    if imgui.menu_item(v:get_short_name()) then
                        instance_menu(v)
                    end
                end
            end
        end
    end
    imgui.push_id(obj)
    if imgui.tree_node(obj)
        then
        imgui.indent(2)
        imgui.text("Properties")
        imgui.separator()
        for key, value in orderedPairs(class_data.properties) do
            if imgui.tree_node(key) then
                imgui.text(inspect(value))
                imgui.tree_pop()
            end
        end
        imgui.text("Functions")
        imgui.separator()
        for key, value in orderedPairs(class_data.functions) do
            if imgui.tree_node(key) then
                imgui.text(inspect(value))
                imgui.tree_pop()
            end
        end
        imgui.unindent()
        imgui.tree_pop()
    end
    imgui.pop_id()
end

local function show_all_objects_of(uclass)
    imgui.separator()
    imgui.push_id(uclass)
    class_node(uclass)
    imgui.pop_id()
end

local function all_classes_menu(all_classes, all_packages)


    imgui.begin_window("All Classes")
  --  all_classes = all_classes or api:find_uobject("Class /Script/CoreUObject.Class"):get_objects_matching()
    class_names = class_names or json.load_file("class_short_names.json")
    if not class_short_names then
        class_short_names, class_paths = break_table(class_names)
        class_count = #class_short_names
        if fs.exists("package_classes.json") then
            package_classes = json.load_file("package_classes.json")
            package_names, _ = break_table(package_classes)
        end
        package_names = package_names or {}
        if #package_names == 0 then
            for k,v in orderedPairs(class_names) do
                local class = find_fast(v)
                print(class:get_full_name())
                local pack = class:get_outer()
                local pack_name = pack:get_full_name()
                if not pack_name:is_in(package_names) then
                    package_names[#package_names+1] = pack_name
                end
                package_classes = package_classes or {}
                package_classes[pack_name] = package_classes[pack_name] or {}
                package_classes[pack_name][#package_classes[pack_name] + 1] = k
            end
            json.dump_file("package_classes.json", package_classes, 4)
        end
    end


    for i = max(1, cursor - 500),  min(cursor + 500,  #package_names + ((open_pack ~= nil and #package_classes[open_pack]) or 0)) do
        local pack = package_names[i]
        if pack then
            cursor = i
            local ct = #package_classes[pack]
        if imgui.get_cursor_screen_pos().y <= (imgui.get_display_size().y + 400) and
            imgui.get_cursor_screen_pos().y >= (-200)
            then
                imgui.separator()
                imgui.begin_group()
                imgui.push_id(pack)

                if imgui.tree_node(pack) or open_pack == pack then
                    open_pack = pack
                    active_object = i
                    for ii = cursor, ct + cursor do
                        cursor = ii
                        local packclasses = package_classes[pack]
                        if packclasses then
                            local uclass = packclasses[ii]
                            if uclass then
                                show_all_objects_of(uclass)
                            end
                        end
                    end
                    imgui.tree_pop()
                end
                imgui.same_line()
                imgui.text(ct.." Classes")
                imgui.pop_id()
                imgui.end_group()
            end
        else
            imgui.new_line()
        end
    end
    imgui.end_window()
end


local sk
local allpacks, allclasses
local showclasses = false
function ImGui.AllClasses()
    if ImGui.ToggleButton("Show All Packages and Classes", showclasses) then
        showclasses = not showclasses
    end
    if showclasses then
            all_classes_menu(allpacks, allclasses)
    end

end
local function tree_child(obj)
    local props = obj:get_property_info()
    imgui.push_id(imgui.get_id(obj))
    if imgui.tree_node(obj:readable_name()) then
        for i,v in ipairs(props) do
            imgui.push_id(i)
            if imgui.tree_node(v.name) then
            imgui.text(v.type)
            imgui.text(inspect(v:check_flags()))
                local val = inspect(v.Value)
                    local c,nv, s1,s2 = imgui.input_text(i, val)
                    if c then
                    val = nv
                    end
                    if ImGui.is_key_pressed("Enter") and imgui.is_item_active() then
                        obj:set_property(v.name, tonumber(val))
                    end
                    imgui.tree_pop()
                end
            imgui.pop_id()
            end
        imgui.tree_pop()
    end
    imgui.pop_id()
end


function ImGui.ObjectContextItem(object)
    local name = object:get_full_name()
    local c = imgui.menu_item(name)
    if imgui.begin_popup_context_item(name) then
        ImGui.ObjectContextMenu(object)
        imgui.end_popup()
    end
end


function ImGui.ObjectContextMenu(object)
    local location, rotation, scale, attachparent, attachchildren, properties, functions, inputtext, components
    local actor, root, actorcomp
    local visible
    local function getdata(engine, dt)
        local class = object.as_class and object:as_class() or object:get_class()
        location = object:get_location()
        rotation = object:get_rotation()
        scale = object:get_scale()
        properties = properties or class:get_properties()
        functions = functions or class:get_functions()
        inputtext = inputtext or ""
        if not components then
            local s,r = pcall(function()
                return object:get_components()
            end)
            if s then components = r end
        end
        root = root or object:as_component()
        if root then
            attachparent = attachparent or root:get_attach_parent()
            attachchildren = attachchildren or root:get_attached_components()
        end
        actorcomp = actorcomp or nil
        if not actorcomp then
            if object:is_component() then
                actorcomp = object
            end
        end
        actor = actor or object:as_actor()
    end
    uevr.sdk.callbacks.on_post_engine_tick(getdata)
    uevr.sdk.callbacks.on_frame(function()
        imgui.text(object:get_full_name())
        imgui.text(root and root:get_full_name() or "")
        imgui.text(actor and actor:get_full_name() or "")
        imgui.text(actorcomp and actorcomp:get_full_name() or "")

        imgui.separator()
        if actorcomp then
            if ImGui.ToggleButton("Active", actorcomp.bIsActive) then
                actorcomp:toggle_active()
            end
            imgui.same_line()
        end
        if root then
            visible = visible or root.bRenderInMainPass
            if ImGui.ToggleButton("Visible", visible) then
                visible = root:toggle_visibility()
            end
                imgui.same_line()
        end

            if attachparent ~= nil then
                imgui.text("Attach Parent "..tostring(attachparent))
                imgui.same_line()
                if imgui.button("Detach") then
                    root:detach()
                end
            end




                if imgui.collapsing_header("Unattached Components") then



                    for i, v in ipairs(components) do
                         tree_child(v)
                    end
                end


            if imgui.collapsing_header("Attachments") then



            for i, v in ipairs(attachments) do
                 tree_child(v)
            end
        end
    end)


end


function ImGui.ObjectSearchBox(id)
    imgui.text("Object Path or Address: ")
    imgui.separator()
    local c, t, s1, s2 = imgui.input_text(imgui.get_id(id or math.random()*1024),
            object_search_box.input,
            ImGui.CalcFlags({
            "AllowTabInput",
            "AutoSelectAll",
            "CallbackHistory"},
            "InputText"))
    if c then object_search_box.input = t end
    local clicked = imgui.button("Get Object")
    if ImGui.EnterOrClicked(clicked) then
        local temp = nil
        local address = object_search_box.input:to_address()
        if address then
            temp = api:to_uobject(address)
        else
            temp = api:find_uobject(object_search_box.input)
        end
        if temp ~= nil and temp:is_valid() then
            found_object = temp
            table.insert(object_search_box.results, found_object)
            return found_object
        end
    end
end





local show_ue_mouse_cursor = false
local enable_ue_click_over = true


ImGui.bg = true
function ImGui.toggle_draw_inputs()
    draw_inputs = not draw_inputs
end

local last_delta = 0


function ImGui.ReadOnlyInputTable(label, data)
    if imgui.begin_table(label, 2, ImGui.CalcFlags({"BordersInnerV","BordersOuterH","ContextMenuInBody","NoHostExtendX","SizingFixedFit","RowBg"},"Table")) then
    imgui.table_setup_column("Name", 8)
    imgui.table_setup_column("Value", 8)
    imgui.indent()
    for k,v in orderedPairs(data) do
        imgui.table_next_row()
        imgui.table_set_column_index(0)
        imgui.text(k)
        imgui.table_next_column()
        imgui.push_id(k)
        ImGui.ReadOnlyInputText(v)
        imgui.pop_id()
    end
    imgui.unindent()
    imgui.end_table()
    end
end


function ImGui.ObjectTable(label, objects)
    if imgui.begin_table(label, 4, ImGui.CalcFlags({"BordersInnerV","BordersOuterH","ContextMenuInBody","NoHostExtendX","SizingFixedFit","RowBg"},"Table")) then
    imgui.table_setup_column("Name", 8)
    imgui.table_setup_column("Outer", 8)
    imgui.table_setup_column("Type", 8)
    imgui.indent()
    for k,v in orderedPairs(objects) do
        imgui.table_next_row()
        imgui.table_set_column_index(0)
        imgui.push_id(imgui.get_id(k))
        if imgui.tree_node(k:get_fname():to_string()) then
            if k.as_struct and k:as_struct() ~= nil then
                imgui.indent()
                local props = k:get_props()
                if props then
                    for name, utype in orderedPairs(props) do
                        imgui.text(name) imgui.same_line() imgui.text(utype)
                        if k:is_instance() then
                            imgui.text(inspect(k[name]))
                        end
                    end
                end
                imgui.unindent()
            end

            imgui.tree_pop()
        end
        imgui.table_next_column()
        imgui.text(k:get_outer():get_fname():to_string())
        imgui.table_next_column()
        imgui.text(k.get_class and k:get_class():to_string())
        imgui.table_next_column()
        if imgui.button("X") then
            objects[k] = nil
        end
        imgui.pop_id()
    end
    imgui.unindent()
    imgui.end_table()
    end
end


-- Aside from the obvious, this has the benefit of autosizing for multiline
function ImGui.ReadOnlyInputText(text, width, multi, label)
    text = (type(text) == "string" and text) or (text.to_string and text:to_string()) or tostring(text)

    local len = imgui.calc_text_size(text)
    if multi and (len.y / imgui.calc_text_size("A").y) < 2 then multi = false
    elseif not multi and (len.y / imgui.calc_text_size("A").y) > 2 then multi = true end
    local size = Vector2f.new(width or len.x, len.y)
    if width == nil then
        local available_width = math.min(imgui.get_display_size().x * 0.5, math.max(imgui.get_window_size().x * 0.75))
        local lines = (len.x * (len.y / imgui.calc_text_size("A").y)) % available_width
        size.x = available_width
        size.y = math.max(len.y, math.min(lines, 800))
    end
    imgui.push_id(label or ("###"..text:letters():sub(1, 12)))
    if multi then
        if imgui.begin_child_window(label or "###"..text:sub(1, 5), size * 1.15, true, ImGui.CalcFlags({"AlwaysAutoResize", "NoScrollbar", "NoBackground", "NoResize"}, "Window")) then
            local c, n, s1, s2 = imgui.input_text_multiline("", text, size, 16384)
            imgui.end_child_window()
        end

    else
        local c, n, s1, s2 = imgui.input_text("", text, size, 16384)
    end
    imgui.pop_id()
end

local slider_vals = {}

-- define an upvalue to provide persistence
-- don't worry about multiple calls, each call to ImGui.slider will make a new closure with its own local temp
local temp = nil
function ImGui.slider(label, val, min, max, num_type)
    temp = val
    local changed, newval
    if num_type ~= nil and num_type == "int" then
        changed, newval = imgui.slider_int(label, temp, min, max)
    else
        changed, newval = imgui.slider_float(label, temp, min, max)
    end
    if changed then
        temp = newval
        val = temp
    end
    return temp
end



function ImGui.vecsliders(vec, vectorName, range, offset, width)
    local slider = ImGui.slider
    imgui.push_id(vectorName)
    imgui.begin_group()
    if not vec then vec = vector(0,0,0) end
    offset = offset or 0
    if width == nil then width = math.min(imgui.get_display_size().x * 0.25, math.max(imgui.get_window_size().x * 0.75)) end
    imgui.push_item_width(width)
    imgui.push_id(vectorName.."x")
    vec.x = slider(vectorName .. ".X", vec.x, (-1 * range) + offset, range + offset)
    imgui.pop_id()
    imgui.push_id(vectorName.."y")
    vec.y = slider(vectorName .. ".Y", vec.y, (-1 * range) + offset, range + offset)
    imgui.pop_id()
    imgui.push_id(vectorName.."z")
    vec.z = slider(vectorName .. ".Z", vec.z, (-1 * range) + offset, range + offset)
    imgui.pop_id()
    imgui.pop_item_width()
    imgui.end_group()
    imgui.pop_id()
    return vec
end


    function ImGui.in_text(label, current)
        local text = current
        local c, nt, ss, se = imgui.input_text(label, current)
        if c then text = nt end
        return text
    end



    function ImGui.RepeatableButton(label)
        imgui.push_id(label)
        imgui.begin_rect()
        local pos = imgui.get_cursor_screen_pos()
        local size = imgui.calc_text_size(label) * 1.2

        local c = imgui.invisible_button(label, size, ImGui.CalcFlags({"Repeat", "AllowOverlap"}, "Button"))
        local end_pos = imgui.get_cursor_screen_pos()
        -- end_pos.y = imgui.get_cursor_screen_pos().y
        imgui.set_cursor_screen_pos(pos)
        imgui.text(label)

        local end_pos = pos + size

        imgui.end_rect()
        imgui.pop_id()
        return c
    end



     function ImGui.RepeatableArrowButton(label, dir)
        imgui.push_id(label)
        imgui.begin_group()
        local pos = imgui.get_cursor_screen_pos()

        local c = imgui.invisible_button(label, Vector2f.new(20,20), ImGui.CalcFlags({"Repeat", "AllowOverlap"}, "Button"))

        local end_pos = imgui.get_cursor_screen_pos()
        imgui.set_cursor_screen_pos(pos)
        imgui.arrow_button(label, dir)
        imgui.end_group()
        imgui.pop_id()
        return c or ImGui.IsClicked(pos, Vector2f.new(20,20))
    end

    local function click_impl(hold_click, label)
        if hold_click then
            return ImGui.RepeatableButton(label)
        else
            return imgui.small_button(label)
        end
    end

    function ImGui.incrementer(value, min, max, str)
        if str ~= nil then
            imgui.text(str)
            imgui.separator()
        else str = "incrementer"..tostring(math.random())
        end
        if imgui.small_button("-") then
            value = (value > min) and (value - 1) or value
        end
        imgui.same_line()
        -- if ImGui.is_key_pressed("LeftCtrl") then
        --     local ct, nt, s1,s2 = imgui.input_text("###"..str, tostring(value), 5006)
        --     if ct then value = tonumber(nt) end
        -- else
        --
        -- end
        imgui.push_item_width(#tostring(value) * char_width * 2)
        imgui.push_id(str)

        -- This almost works but
        -- imgui.push_style_color(ImGui.Col("SliderGrab"), Vector4f.new(0,0,0,0))
        -- imgui.push_style_color(ImGui.Col("SliderGrabActive"), Vector4f.new(0,0,0,0))
        -- -- imgui.text(tostring(value))
        -- local c, nv = imgui.slider_int("###"..str, value, value, value)
        -- if c then value = nv end
        -- imgui.pop_style_color(2)
        local valuestr = tostring(value)
            local ct, nt, s1,s2 = imgui.input_text("###"..str, valuestr, 5006)
            if ct then
             value = tonumber(nt) ~= nil  and tonumber(nt) end

        imgui.pop_item_width()
        imgui.pop_id()
        imgui.same_line()
        if imgui.small_button("+") then
            value = (value < max) and (value + 1) or value
        end

        return value
    end

    function ImGui.incrementer_combo(label, items, selection)
        if imgui.small_button("-") then selection = selection - 1 end
        imgui.same_line()
        local c, ni = imgui.combo(label, selection, items)
        if c then selection = ni end
        imgui.same_line()
        if imgui.small_button("+") then selection = selection + 1 end
        if selection + 1 == 0 then selection = min end
        if selection - 1 == #items then selection = #items end
    end

    function ImGui.incrementer2(value, min, max, str, step, display_type, hold_click)
        if step == nil or type(step) ~= "number" then step = 1 end
        imgui.begin_group()
        if str == nil then str = "incrementer" end
        if click_impl(hold_click, "  -  ") then value = value - step end
        imgui.same_line()
        local width = math.min(imgui.get_display_size().x * 0.25, math.max(imgui.get_window_size().x * 0.75))
        imgui.push_item_width(width)
        if display_type == nil or display_type == 1 then
            ImGui.ReadOnlyInputText(tostring(value))
        elseif display_type == 2 then
            local c, nt, s1, s2 = imgui.input_text(str, tostring(value), 0)
            if c then value = tonumber(nt) end
        elseif display_type == 3 then
            value = ImGui.slider(str, value, min, max)
        end
        imgui.pop_item_width()
        imgui.same_line()

        if click_impl(hold_click, "  +  ") then value = value + step end
        if value - step < min then value = min end
        if value + step > max then value = max end

        imgui.end_group()
        return value
    end

    local value = 1.0
    local function TestWidget()
        -- local changed, newprogress = ImGui.HoldButtonWidget("TEST", Vector2f.new(120, 15), false, progress)
        -- if changed then progress = newprogress end
        local newvalue = ImGui.incrementer2(value, -43, 12, "Test", 1.5, 3, true)
        value = newvalue
        imgui.text(tostring(value))
    end




local step = 0
local invert = false
function ImGui.BlinkingCircle(pos, normal_size, max_size, color, interval, fill, smoothing)
    local step_value = 1
    if smoothing ~= nil  then
        smoothing = math.max(0.1, math.min(smoothing, 1.0))
        local progress = step / interval
        if invert then
            step_value = 0 + (progress * smoothing)
        else step_value = 1 - (progress * smoothing) end
        if step_value < smoothing then invert = not invert end
    end
    if step % interval == 0 then
        invert = not invert
    end
    if invert then step = step - step_value else step = step + step_value end
    if pos == nil then pos = imgui.get_mouse() end
    local size =  normal_size + math.abs((max_size - normal_size) * (interval / step))
    local segments = 16 + (size / 50) % 1
    local draw_fn = fill and draw.filled_circle or draw.outline_circle
    draw_fn(pos.x, pos.y, size, color, segments)
end



-- cb should usually be a button (just has to return a bool), e.g.
--   local clicked = imgui.button("Get Object")
--   if ImGui.EnterOrClicked(clicked) then
-- I haven't even tried this but I'm sure you could even use my ImGui.IsClicked
-- in case you don't know if the item is interactable
-- TODO: full VR controller integration
function ImGui.EnterOrClicked(cb)
    local entered = (ImGui.is_key_pressed("Enter") or ImGui.is_key_pressed("GamepadFaceDown")) and (imgui.is_item_active() or imgui.is_item_focused())
    local clicked = cb
    return entered or clicked
end

local keys = {
    --512
    "Tab", "LeftArrow", "RightArrow", "UpArrow", "DownArrow", "PageUp", "PageDown", "Home", "End",
    "Insert", "Delete", "Backspace", "Space", "Enter", "Escape", "LeftCtrl", "LeftShift", "LeftAlt", "WindowsKey",
    "RightCtrl", "RightShift", "RightAlt", "RightSuper", "Menu", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A",
    "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X",
    "Y", "Z", "F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9", "F10", "F11", "F12", "Apostrophe", "Comma", "Minus",
    "Period", "Slash", "Semicolon", "Equal", "LeftBracket", "Backslash", "RightBracket", "GraveAccent", "CapsLock",
    "ScrollLock", "NumLock", "PrintScreen", "Pause", "Keypad0", "Keypad1", "Keypad2", "Keypad3", "Keypad4", "Keypad5",
    "Keypad6", "Keypad7", "Keypad8", "Keypad9", "KeypadDecimal", "KeypadDivide", "KeypadMultiply", "KeypadSubtract",
    "KeypadAdd", "KeypadEnter", "KeypadEqual", "GamepadStart",
    "GamepadBack", "GamepadFaceLeft", "GamepadFaceRight", "GamepadFaceUp", "GamepadFaceDown", "GamepadDpadLeft",
    "GamepadDpadRight",
    "GamepadDpadUp", "GamepadDpadDown", "GamepadL1", "GamepadR1", "GamepadL2", "GamepadR2", "GamepadL3", "GamepadR3",
    "GamepadLStickLeft",
    "GamepadLStickRight", "GamepadLStickUp", "GamepadLStickDown", "GamepadRStickLeft", "GamepadRStickRight",
    "GamepadRStickUp", "GamepadRStickDown",
    --641
    "MouseLeft", "MouseRight", "MouseMiddle", "MouseX1", "MouseX2", "MouseWheelX", "MouseWheelY"

}

ImGui.keys_down = {}
ImGui.keys_prev = {}
ImGui.keys_pressed = {}
ImGui.keys_released = {}
ImGui.double_pressed_keys = {}
ImGui.mouse_history = {}
ImGui.mouse_delta = {x = 0, y = 0}


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

-- Our imgui bindings don't offer a way to set mouse position or enable warping
-- So calculating real delta made mouse controls for the freecam unusable
-- To compensate I first setup a constant value
-- we can continue applying when we're at the very edge of the screen
-- I also felt like for the camera controls I was envisioning we needed a bit of smoothing
-- and acceleration rather than precision since we have other ways to be more precise
-- if you need to use this hook for anything else you might need to toy with these
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

        ImGui.mouse_delta.x = dx
        ImGui.mouse_delta.y = dy

        smoothed_mouse = avg_now
    else
        ImGui.mouse_delta.x = ImGui.mouse_delta.x
        ImGui.mouse_delta.y = ImGui.mouse_delta.y
        smoothed_mouse = mouse
    end

    if math.abs(ImGui.mouse_delta.x) > 0 then last_delta.x = ImGui.mouse_delta.x end
    if math.abs(ImGui.mouse_delta.y) > 0 then last_delta.y = ImGui.mouse_delta.y end

    for i, axis in ipairs({"x", "y"}) do
        if (res[axis] - mouse[axis]) <= 2 then ImGui.mouse_delta[axis] = sustained_value
        elseif mouse[axis] <= 2 then ImGui.mouse_delta[axis] = -1 * sustained_value
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

function ImGui.drawinputs()

    imgui.push_id("InputOverlay")
    local text = "Keys: "
    for name, v in pairs(current_pressed_keys) do
        if v then text = text.." "..name end
    end

    imgui.text(text)
    local mouse = imgui.get_mouse()

    imgui.text("Mouse X:" .. string.format("%.2f", mouse.x)) imgui.same_line()
    imgui.text(", Y: "..string.format("%.2f", mouse.y))
    imgui.text("MouseDeltaX: " .. string.format("%.2f", ImGui.mouse_delta.x))
    imgui.text("MouseDeltaY: " .. string.format("%.2f", ImGui.mouse_delta.y))
    ue_hook_mouse()
    imgui.pop_id()
end
function ImGui.key_names(range)
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
function ImGui.update_keys()

    -- check everything all at once for low cost using the real enum values
    -- our bindings provide keys as "Key_{Name}" but these are only suitable for checking one at a time
    for i = 512, 647 do
        local key_name = keys[i - 511]
        if last_key_time[key_name] == nil then last_key_time[key_name] = -1 end
        if i ~= 530 then -- windows key
            local prev = current_pressed_keys[key_name] or false
            if imgui.is_key_down(i) then
                current_pressed_keys[key_name] = true
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

local function in_circle(p, center, radius)
    if (p.x > center.x + radius) or (p.x < center.x - radius) or (p.y < center.y - radius) or (p.y > center.y + radius) then return false end
    local dx = p.x - center.x
    local dy = p.y - center.y
    local sqD = (dx - dy) + (dy * dy)
    return sqD <= (radius * radius)
end

function ImGui.IsHovered(start_pos, end_pos, center, radius)

    local mouse_pos = imgui.get_mouse()
    -- no test case yet, intent is to allow gaze interaction with uevr main ui disabled
    if VR.checkVR() and not functions.is_drawing_ui() then mouse_pos = ImGui.Resolution() * 0.5 end

    if start_pos == nil and end_pos == nil and center ~= nil and radius ~= nil
        -- then return in_circle(mouse_pos, center, radius)
        then return ((mouse_pos - center):length() < radius)
    else
        if mouse_pos.x > start_pos.x and mouse_pos.x < end_pos.x then
                if mouse_pos.y > start_pos.y and mouse_pos.y < end_pos.y then
                    return true
                end
            end
        end
    return imgui.is_item_hovered(2048) or false
end

-- If you don't want to or can't allow inputs to imgui just fake them!
-- Actually no need to limit this to imgui widgets if you have screen coords for a game widget
-- TODO: add test cases for the above
function ImGui.IsClicked(widget_pos, widget_size, button)
    if button == nil then button = "MouseLeft"
    elseif type(button) == "number" then
        local buttons = {"MouseLeft", "MouseRight", "MouseMiddle", "MouseX1", "MouseX2"}
        local temp = buttons[button + 1]
        button = temp
    end
    return ImGui.IsHovered(widget_pos, widget_pos + widget_size) and ImGui.is_key_toggled(button)
end

local key_prev = {}

function ImGui.is_key_toggled(key)
    local now = current_pressed_keys[key]
    local was = key_prev[key] or false
    key_prev[key] = now
    return now and not was
end
local key_state = {}
local double_press_limit = 0.3 -- seconds

function ImGui.is_double_pressed(key)
    if current_pressed_keys[key] and
         last_key_time[key] > 0 then
            print(last_key_time[key])
            local diff = os.clock() - last_key_time[key]
            if diff <= 1.0 then
            last_key_time[key] = 0
            print("Double clicked "..key)
    return diff end
     end
end


-- this combo allows for hold-repeat buttons that can affect scroll in a separate window/child-window

local scroll_vars
function ImGui.ScrollButtons(window_id)

    local choice = 0

    if imgui.button("Top") then
            choice = 1
    end
    imgui.same_line()
    if ImGui.RepeatableArrowButton("up", "Up") then
           choice = 2
    end
    imgui.same_line()
    if imgui.button("Center") then
        choice =3
    end
    imgui.same_line()
    if ImGui.RepeatableArrowButton("down", "Down") then
            choice = 4
    end
    imgui.same_line()
    if imgui.button("Bottom") then
         choice = 5
    end
    return choice
end

function ImGui.SetScroll(c, speed)
        local t = {
                imgui.set_scroll_y(0),
                imgui.set_scroll_y(imgui.get_scroll_y() - speed or 2.0),
                imgui.set_scroll_y(imgui.get_scroll_y() + speed or 2.0),
                imgui.set_scroll_y(imgui.get_scroll_max_y()),
        }
        local func = t[c]
        func()
end

function ImGui.reset_keys()
    current_pressed_keys = {}
    current_released_keys = {}
    for idx, val in ipairs(keys) do
        current_pressed_keys.val = false
        current_released_keys.val = false
    end
end

function ImGui.dump_keys()
    local time = os.time()
    json.dump_file("key_dump"..tostring(time) .. ".json", {current_released_keys, current_pressed_keys, last_key_time}, 4)
end

function ImGui.get_current_keys()
    return current_pressed_keys, current_released_keys
end

function ImGui.is_key_pressed(bind)
    return current_pressed_keys[bind:upper()]
end

function ImGui.is_key_released(bind)
    return current_released_keys[bind]
end

ImGui.bg_flags = flags

local font = ""

function ImGui.tooltip(id, text, active)
    imgui.push_id(imgui.get_id(id or text))
    if active or imgui.is_item_hovered(0) then
        imgui.set_tooltip(text)
    end
    imgui.pop_id()
end

draw_inputs, draw_ue_inputs = false, false


function ImGui.edit_window_flag(flag, enable)
    local any_changed = false
    pcall(function()
    for name, v in pairs(bg_flags) do
        if name == flag or (type(flag) == "number" and flag == v.value) then
            if enable ~= nil then
                if v.active ~= enable then
                    any_changed = true
                    v.active = enable
                end
            else
                v.active = not v.active
            end
        end
    end
    if any_changed then json.dump_file("window_flags.json", bg_flags, 4) end
end)
end

function ImGui.check_flag(flags, flag_name, flag_type)
    flags = flags & ~ ImGui.CalcFlags({flag_name}, flag_type)
    return flags
end

function ImGui.check_window_flag(flag)
    bg_flags = bg_flags or json.load_file("window_flags.json")
    for name, v in pairs(bg_flags) do
        if name == flag or (type(flag) == "number" and flag == v.value) then return v.active end
    end
end

local draw_registry = {}
local disabled_draw_callbacks = {}
ImGui.draw_callbacks = {

}

function ImGui.string_table(name, stable)
    if stable == nil then return end
    imgui.text(Name..": ")
    for k, v in pairs(stable) do
        if type(v) ~= "string" then return end
        imgui.same_line() imgui.text(k..": "..v)
    end
end

-- simple data only (e.g. vector, rotator)
function ImGui.tostring_numbertable(name, ntable)
    if ntable == nil then return end
    local temp = nil
    if type(ntable) ~= "table" then
        temp = {}
    else temp = ntable end
    imgui.text(name..": ")
    for k, v in pairs(temp) do
        if type(v) ~= "number" then return end
        imgui.same_line() imgui.text(k..": "..tostring(v))
    end
end

ImGui.window_callbacks = {}

ImGui.named_windows = {}

local function named_window_host()
    imgui.set_next_window_size(Vector2f.new(0.1, 0.1))
    imgui.set_next_window_pos(ImGui.Resolution())
    imgui.begin_window("window_host", true, 0)
    local id = 124814
    for name, cb in orderedPairs(ImGui.named_windows) do
        imgui.push_style_var("Alpha", 1.0)
        imgui.push_id(id)
        cb()
        imgui.pop_id()
        id = id + 1
        imgui.pop_style_var(1)
    end
    imgui.end_window()
end


local shared_window_open = true
local function shared_window()
     imgui.push_style_var("Alpha", 0.5)
    imgui.begin_window("shared_window", nil, 0)

    -- local id = 12412412
    for _, cb in ipairs(ImGui.window_callbacks) do
        imgui.push_style_var("Alpha", 1.0)
        -- imgui.push_id(id)
        imgui.push_id(imgui.get_id(tostring(cb)))
        imgui.begin_rect()
        cb()
        imgui.end_rect()
        imgui.pop_id()

        -- id = id + 1
        imgui.pop_style_var(1)
    end

    imgui.end_window()

    imgui.pop_style_var(1)
end

ImGui.menu_callbacks = {}

-- pass a label and a bool, get back the changed result and draw an indicator
-- e.g. if imgui.button(ImGui.toggle_text("Toggle Joystick", joystick_init)) then joystick_init = not joystick_init end
-- would be better with utf symbols but it gets the job done, maybe look into custom fonts
function ImGui.toggle_text(text, var, symbol)
    if symbol == nil then symbol = "o" end
    local out = ""
    if type(text) == "string" then
        if text:startswith(symbol.." ") then
            if var then
                return text
            else
                out = text:sub(#symbol)
            end
        elseif var then
            out = symbol.." " .. text
        else
            out = text
        end
    elseif type(text) == "table" then
        if var then return text[1]
        else return text[2]
        end
    end
    return out
end


-- pass a label and a bool, get back the changed result and draw an indicator
-- text can instead be a table of two different texts
function ImGui.ToggleButton(text, var, symbol)
    return imgui.button(ImGui.toggle_text(text, var, symbol), var)
end

-- append content to the always active but invisible background canvas
-- crucial for draw api functions, great for info labels
-- you should make the background overlay pass through inputs
-- and avoid making interactive widgets for these callbacks
-- if needed you can use ImGui.IsClicked to fake a button interaction
-- you can also spawn modal windows which will be interactable
local draw_calls = nil
function ImGui.register_draw(func)

    draw_calls = draw_calls or {}
    draw_calls[func] = true

end

-- register and unregister in on frame if drawing a lot of dynamic data, e.g. from a table
function ImGui.unregister_draw(func)
    draw_calls = draw_calls or {}
    if draw_calls and draw_calls[func] then draw_calls[func] = nil end

end

ImGui.draw_callbacks = draw_calls


-- add to the main menu bar on the top of the window
-- note that drawing this bar is only possible with the background overlay
-- otherwise it would spawn an empty "Debug" window as its host
-- you are not limited to menu items in menus. all imgui widgets work
function ImGui.register_menu(cb)
    for _, existing in ipairs(ImGui.menu_callbacks) do
        if existing == cb then return end
    end
    if position ~= nil then
        table.insert(ImGui.menu_callbacks, position, cb)
    else
        table.insert(ImGui.menu_callbacks, cb)
    end
end
function ImGui.toggle_menu_bar(enable)

    if enable ~= nil then use_menu_bar = enable else use_menu_bar = false end
end

function ImGui.unregister_menu(cb)
    for idx, existing in ipairs(ImGui.menu_callbacks) do
        if existing == cb then table.remove(ImGui.menu_callbacks, idx) end
    end
end
local style_color_pushes = 0


local menu_pos = Vector2f.new(1920, 1080) * Vector2f.new(1,1)

if ImGui.bg_flags == 0 then ImGui.reset_flags() end

uevr.sdk.callbacks.on_frame(function()

    res = res or imgui.get_display_size()
    pc = pc or api:get_player_controller(0)
    if pc == nil then return end

    if draw_inputs then
        ImGui.register_draw(ImGui.drawinputs, nil, Vector2f.new(0, ImGui.Resolution() * 0.75))
    else ImGui.unregister_draw(ImGui.drawinputs)
    end


    -- if ImGui.bg then

    res =  imgui.get_display_size()
    imgui.set_next_window_size(res)
    imgui.set_next_window_pos(Vector2f.new(0, 0))
    ImGui.CanvasWindow(imgui.get_id("Background"), true, bg_flags)
    if ImGui.menu_callbacks ~= nil and #ImGui.menu_callbacks > 0 then
        ImGui.edit_window_flag("MenuBar", true)
    else
        ImGui.edit_window_flag("MenuBar", false)
    end

    ImGui.update_keys()


    if draw_calls then
        for func, _ in orderedPairs(draw_calls) do
            if type(func) == "function" then
                func()
            end
        end
    end
    -- if ImGui.draw_callbacks and #ImGui.draw_callbacks > 0 then
    --     for _, cb in ipairs(ImGui.draw_callbacks) do
    --         if cb.location ~= nil then
    --             imgui.set_cursor_screen_pos(cb.location)
    --         end
    --         local func = cb["func"]
    --         if func ~= nil then
    --             func()
    --         end
    --     end
    -- end

    imgui.end_window()
end)


local disabled_draw_calls = {}
function ImGui.toggle_bg()
    ImGui.bg = not ImGui.bg
    if not ImGui.bg then
        disabled_draw_calls = draw_cals
        draw_calls = {}
    else
        draw_calls = disabled_draw_calls
        disabled_draw_calls = {}
    end
end


local drag_point = nil
-- Centralized frame hook called by callbacks.lua
function ImGui.OnFrame()

end


function ImGui.ButtonSize(label)
    return imgui.calc_text_size(label) + Vector2f.new(2, 2)

end


function ImGui.button(label)
    imgui.push_id(imgui.get_id(label))
    local pos = imgui.get_cursor_screen_pos()
    local c = imgui.invisible_button(label, imgui.calc_text_size(label) + Vector2f.new(2, 1), ImGui.CalcFlags({"AllowOverlap"}, "Button"))
    imgui.set_cursor_screen_pos(pos)
    imgui.text(label)
    imgui.item_add(label, pos, imgui.calc_text_size(label) + Vector2f.new(2, 1))
    imgui.pop_id()
    return
end

function ImGui.Button(label)
    local c = ImGui.button(label)
    local pressed = c or ImGui.IsClicked(imgui.get_cursor_screen_pos(), imgui.calc_text_size(label) + Vector2f.new(2, 1))
    if pressed and vr.is_using_controllers() then
        vr.trigger_haptic_vibration(0.1, 0.5, 1000, 1.0, 1)
    end
    return pressed
end


local function hold_button(label, size, progress, text_color)
    if text_color == nil then text_color = 0xD4D9E080 end
    local screen_pos = imgui.get_cursor_screen_pos()
    imgui.push_id(label)
    imgui.begin_group()
    screen_pos = imgui.get_cursor_screen_pos()
    local c = imgui.invisible_button(label, size, ImGui.CalcFlags({"AllowOverlap", "Repeat"}, "Button"))
    -- imgui.progress_bar(progress, size, nil)
            ImGui.ColoredProgressBar(Vector4f.new(0.0, 1.0, 1.0, 1.0),  Vector4f.new(1.0, 0.0, 0.0, 1.0), progress, size, label )

    imgui.end_group()
    imgui.set_cursor_screen_pos(Vector2f.new(screen_pos.x + (size.x / 2), screen_pos.y))
    imgui.text(label)

    local hovered  = imgui.is_item_hovered(0)
    imgui.pop_id()
    return hovered, c

end

-- Button/progress bar combo
-- For actions that need confirmation (and maybe later some gaze tracking)
-- need_click can be nil or false in which case simply hovering will activate it
-- keep in mind step will be frame dependeent
function ImGui.HoldButton(label, size, need_click, progress, step)
    if step == nil then step = 2.5 end
    local hovered, clicked = hold_button(label, size, progress)
    for k,v in pairs({clicked, (hovered and not need_click)}) do
        if v then
            progress = progress + step / (10 * size.x)
        end
    end
    return clicked or (hovered and not need_click), progress

end



function ImGui.HoldButtonWidget(label, size, need_click, progress, step)
    local r = false
    if progress == nil then progress = 0 end
    local changed, newprogress = ImGui.HoldButton(label, size, need_click, progress, step)
    if changed then progress = newprogress end
    if progress == 1 then
        r = true
    end
    if r == true then progess = 0 return r end
end

local progress = 0

-- content to display on completion
local function testWidget()

    imgui.text("Colored text")
    if imgui.button("Ok") then progress = 0 end
end

local function testGroupStyle()
    styles = {
        Text = {0.5, 1.0, 1.0, 0.6},
        Border = {1.0, 1.0, 1.0, 1.0},
        Button = {0.2, 0.0, 0.2, 0.4},
        ButtonHovered = {1.0, 1.0, 1.0, 0.6},
        ButtonActive = {0.0, 0.5, 0.6, 0.6},
    }
    ImGui.GroupStyle(testWidget, styles)
end

-- function ImGui.incrementer2(value,str, min, max, step, display_type, hold_click)

-- Complete example of HoldButton
--label, window_content, param, pos, size, styles)
local function TestWidget2()

    local changed, newprogress = ImGui.HoldButton("TEST", Vector2f.new(120, 15), false, progress, 5)
    if changed then progress = newprogress end
    -- function ImGui.ModalWindow(label, window_content, param, pos, size, styles, fade_bg)

    if progress >= 1 then ImGui.ModalWindow("Test", testWidget, nil, ImGui.Resolution() * 0.5, nil, nil, true)
    end
end

-- takes transformed text from inspect.lua (basically just json syntax)
function ImGui.TextToTreeNodes(text)


end

local excluded_colors = {Tab = true, TabHovered = true, TabActive = true, TabUnfocused = true, TabUnfocusedActive = true, PlotLines = true, PlotLinesHovered = true, PlotHistogram = true, PlotHistogramHovered = true, ModalWindowDimBg = true}
local color_edit = true
local temp_styles = {}
local jsonstyles = {}
local style_name = ""
local colors_to_pop = 0
local color_flags = ImGui.CalcFlags({"NoSidePreview", "AlphaBar", "NoBorder"}, "ColorEdit")
function ImGui.ColorStylesMenu(colorStyles)

    if colorStyles == nil then colorStyles = ImGuiThemes.default_dark.colors end
    temp_styles = temp_styles or colorStyles
    for k, v in pairs(temp_styles) do imgui.push_style_color(ImGui.Col(k), v)
                        colors_to_pop = colors_to_pop + 1

        end
        if imgui.begin_menu("Color Style Editor") then
         local available_width = math.min(imgui.get_display_size().x * 0.55, math.max(imgui.get_window_size().x * 0.85))

        -- local c, nn, s1, s2 = imgui.input_text("Style Name", style_name, 0)
        -- if c then style_name = nn end
        -- imgui.begin_disabled(style_name == nil or #style_name == 0 )
        -- if imgui.menu_item("Save") then json.dump_file("CustomThemes\\"..style_name..".json", jsonstyles, 4)

        -- end
        -- imgui.end_disabled()
        if ImGui.ToggleButton({"Use color picker widget","Use color edit widget"}, color_edit) then color_edit = not color_edit end
        if imgui.menu_item("Reset all") then temp_styles = ImGuiThemes.default_dark.colors end
        local func = color_edit and imgui.color_edit4 or imgui.color_picker4
        imgui.push_item_width(available_width)
        for idx, val in ipairs(ImGuiCol) do
                if not excluded_colors[val] then
                    imgui.push_id(idx)
                    local tcolor = temp_styles[val] or Vector4f.new(0.5, 0.5, 0.5, 1.0)
                    -- imgui.text(val) imgui.same_line()
                    local c, v = func(val, tcolor, color_flags)
                    if c then tcolor = v
                        temp_styles[val] = tcolor
                        -- imgui.push_style_color(ImGui.Col(v), tcolor)
                        -- colors_to_pop = colors_to_pop + 1

                    end
                    jsonstyles[val] = {tcolor.x, tcolor.y, tcolor.z, tcolor.w}

                    imgui.pop_id()
                end

            end
            imgui.pop_item_width()
            imgui.end_menu()
        end
        if colors_to_pop ~= 0 then imgui.pop_style_color(colors_to_pop )
        colors_to_pop = 0
    end
    colorStyles = temp_styles
    return (colorStyles ~= temp_styles), temp_styles
end


function ImGui.ColorStyleEditor(colorStyles)
    if colorStyles == nil then colorStyles = ImGuiThemes.default_dark.colors end
    if ImGui.ToggleButton({"Use color picker widget","Use color edit widget"}, color_edit) then color_edit = not color_edit end

    imgui.same_line() if imgui.small_button("Reset all") then return ImGuiThemes.default_dark.colors end
    if imgui.collapsing_header("Style Editor") then
        for idx, val in ipairs(ImGuiCol) do

            if not excluded_colors[val] then
                imgui.push_id(val)
                local tcolor = colorStyles[val] or Vector4f.new(0.5, 0.5, 0.5, 1.0)
                imgui.text(val) imgui.same_line()
                if color_edit then
                    local c, v = imgui.color_edit4(val, tcolor, 0)
                    if c then tcolor = v
                        colorStyles[val] = tcolor
                    end
                else
                    local c, v = imgui.color_picker4(val, tcolor, 0)
                    if c then tcolor = v
                        colorStyles[val] = tcolor
                    end
                end
                imgui.pop_id()
            end
        end
    end
    return colorStyles
end

local styles = ImGuiThemes.default_dark.colors
local size = nil

local defaultStyleVars = {
    Alpha = 1.0,
    DisabledAlpha = 1.0,
    WindowPadding = Vector2f.new(8.0, 8.0),
    WindowRounding = 0.0,
    WindowBorderSize = 1.0,
    WindowMinSize = Vector2f.new(32.0, 32.0),
    WindowTitleAlign = Vector2f.new(0.0, 0.5),
    ChildRounding = 0.0,
    ChildBorderSize = 1.0,
    PopupRounding = 0.0,
    PopupBorderSize = 1.0,
    FramePadding = Vector2f.new(4.0, 3.0),
    FrameRounding = 0.0,
    FrameBorderSize = 0.0,
    ItemSpacing = Vector2f.new(8.0, 4.0),
    ItemInnerSpacing = Vector2f.new(4.0, 4.0),
    IndentSpacing = 21.0,
    CellPadding = Vector2f.new(4.0, 2.0),
    ScrollbarSize = 14.0,
    ScrollbarRounding = 9.0,
    GrabMinSize = 10.0,
    GrabRounding = 0.0,
    TabRounding = 4.0,
    ButtonTextAlign = Vector2f.new(0.5, 0.5),
    SelectableTextAlign = Vector2f.new(0.0, 0.0),
    SeparatorTextBorderSize = 0.0,
    SeparatorTextAlign = Vector2f.new(0.0, 0.0),
    SeparatorTextPadding = Vector2f.new(0.0, 0.0),
}

function ImGui.StyleVarEditor(styleVars)
    if styleVars == nil then styleVars = defaultStyleVars end
    if imgui.small_button("Reset all") then return defaultStyleVars end
    if imgui.collapsing_header("Style Var Editor") then
        for name, val in pairs(styleVars) do
            imgui.push_id(name)
            imgui.text(name) imgui.same_line()
            if type(val) == "number" then
                local c, v = imgui.slider_float(name, val, 0.0, 20)
                if c then styleVars[name] = v end
            else
                local c, v = imgui.drag_float2(name, val, 0.1, 0.0, 20)
                if c then styleVars[name] = v end
            end
            imgui.pop_id()
        end
    end
    return styleVars
end

-- Honestly kind of wish I had published my initial implementation because what do you mean I intentionally memleaked every frame without any performance issues or crashes and made it a core feature lol
-- alas it will never see release because I realized I can just do this
local styleVars = defaultStyleVars
local count = 0
local live_edit = false
local styles_table = {}
local function MainGUIStyle()
    -- if size == nil then
    --     size  = Vector2f.new(imgui.get_scroll_max_x(), imgui.get_scroll_max_y())
    -- end
    if imgui.small_button("Toggle Live Edit") then live_edit = not live_edit end
    if count > 0 then
        -- print("Popping last style colors "..tostring(count))
        imgui.pop_style_color(count - 1)
        count = 0
    end
    imgui.push_style_color(ImGui.Col("Text"),  Vector4f.new(1.0, 1.0, 1.0, 1.0))
    imgui.push_style_color(ImGui.Col("ChildBg"),  Vector4f.new(0.2, 0.2, 0.2, 0.5))
    if imgui.begin_child_window("ProtectedPanel", Vector2f.new(600, 600), false, 64) then
        imgui.text("This panel allows you to style the main UEVR GUI!")
        if imgui.collapsing_header("Wait how does this work?") then
            imgui.text("Normally you're supposed to use pop_style_color for each usage.\n Popping too many times will 100% crash your game.\nBut failing to pop the style actually carries over to the next frame allowing you to effect items out of scope.\nIts 100% outside intended usage and arguably a bug but there's no actual harm")
            imgui.text("You can still style individual widgets as needed. Do not attempt to pop previous stacked colors because you will have no way to know how many there are")
        end
        if imgui.button("Save") then
                json.dump_file("MaterialStyle.json", materialStyle,4)

            json.dump_file("MainStyleColors.json", styles_table, 4)
        end imgui.same_line()
       if imgui.button("Load") then
          local temp = json.safe_read("MainStyleColors.json")
          for k, v in pairs(temp) do
            styles.k = Vector4f.new(v[1],v[2],v[3],v[4])
           end
        end
        styles = ImGui.ColorStyleEditor(styles)
        -- styleVars= ImGui.StyleVarEditor(styleVars)
        imgui.end_child_window()

    end
    imgui.pop_style_color(2)
    -- if live_edit or imgui.button("Push Changes") then
        for name, val in pairs(styles) do
            imgui.push_style_color(ImGui.Col(name),  val)
                local tablecolor = {}


                styles_table[name] = {val.x, val.y, val.z, val.w}
                -- print(name)
                -- print(val)
            count = count + 1
        end
         json.dump_file("MainStyleColors.json", styles_table, 4)

    -- end
    -- for name, val in pairs(styleVars) do
    --     imgui.push_style_var(name,  val)
    -- end

end


function ImGui.TextBox(start_pos, width, text, text_color, outline_color, background_color)
    if outline_color == nil then outline_color = vec_to_u32(Vector4f.new(0.1, 0.1, 0.1, 0.9)) end
    if background_color == nil then background_color = vec_to_u32(Vector4f.new(0.2, 0.2, 0.2, 0.4)) end
    if text_color == nil then text_color = vec_to_u32(Vector4f.new(0.96, 0.95, 0.95, 1.0)) end
    local text_size = imgui.calc_text_size(text)
    width = width or text_size.x + (2 * char_width)
    local margin = (width - text_size.x) / 2

    draw.filled_rect(
        start_pos.x - margin, start_pos.y - (char_height % 4), width, text_size.y + (char_height % 4),
        background_color
    )
    draw.filled_rect(
        start_pos.x - margin, start_pos.y - (char_height % 4), width, text_size.y + (char_height % 4),
        outline_color
    )
    draw.text(text, start_pos.x, start_pos.y, text_color)
end
local joystickX = 150
local joystickY = 250
local centerX = 200
local centerY = 200
local maxRadius = 100 -- Maximum distance the joystick can travel from the center

-- more of a general lua method
local function radial_distance(x, y, cx, cy, r)
    local dx = x - cx
    local dy = y - cy
    local magnitude = 0.01 + math.sqrt(dx ^ 2 + dy ^ 2)
    return (Vector2f.new(dx, dy) * (1 / magnitude)), (math.min(magnitude, r) / r)
end

-- taking advantage of our glm bindings, these should be equal
-- return our output control vector and the scaled magnitude
local function radial_distance_vec(vec, center, r)
    return (vec - center) * (1 / (vec - center):length()), (math.min((vec - center):length(), r) / r)
end


function ImGui.ControlStick(screen_pos, size, fill_color, control_method, sensitivity, range)
    imgui.push_id(control_method)
    local method = ""
    local methods = {}
    local range_mult = 0.25
    local sens_mult = 0.15
    if sensitivity ~= nil then sens_mult = sensitivity end
    if range ~= nil then range_mult = range end
    local _methods = {"ImGuiGamepadLeft", "ImGuiGamepadRight", "WASD", "ArrowKeys", "Mouse", "XInput"}
    if control_method ~= nil and type(control_method) == "table" then methods = control_method
    elseif type(control_method) == "string"
        then methods = {control_method=true}
    elseif type(control_method) == "number" then
        methods = {}
        local cm = _methods[control_method]
        methods[cm] = true
    end

    if size == nil then size = 100 end
    local stick_pos = Vector2f.new(screen_pos.x, screen_pos.y)
    draw.outline_circle(screen_pos.x, screen_pos.y, 100, 0xFFFFFFFFF, 12)
    local hovered = ImGui.IsHovered(nil, nil, stick_pos, size)
    if hovered or stick_pos ~= screen_pos then
        fill_color = 0xB1A3D9D8
    else
        fill_color = 0xA59DBB17
    end
    local input_keys = {}
    if methods["ImGuiGamepadLeft"] then input_keys = {"GamepadLStickLeft",
    "GamepadLStickRight", "GamepadLStickUp", "GamepadLStickDown"}
elseif methods["ImGuiGamepadRight"] then input_keys = {"GamepadRStickLeft",
    "GamepadRStickRight", "GamepadRStickUp", "GamepadRStickDown"}
elseif methods["WASD"] then input_keys = {"A", "D", "W", "S"}
elseif methods["ArrowKeys"] then input_keys = {"LeftArrow", "RightArrow", "UpArrow", "DownArrow"}
end
if #input_keys > 0 then
    for i, v in ipairs(input_keys) do
        if ImGui.is_key_pressed(v) then
            if i == 1 then
                stick_pos.x = math.min(screen_pos.x - (range_mult * size), stick_pos.x - (sens_mult * size))
            elseif i == 2 then
                stick_pos.x = math.max(screen_pos.x + (range_mult * size), stick_pos.x + (sens_mult * size))
            elseif i == 3 then
                stick_pos.y = math.min(screen_pos.y - (range_mult * size), stick_pos.y - (sens_mult * size))
            elseif i == 4 then
                stick_pos.y = math.max(screen_pos.y + (range_mult * size), stick_pos.y + (sens_mult * size))
            else
                stick_pos = screen_pos
            end
        end
    end
elseif methods["Mouse"] then
    local mouse_down = ImGui.is_key_pressed("MouseLeft")
    if mouse_down and ImGui.IsHovered(nil, nil, stick_pos, size * 1.25) then
        local mouse_pos = imgui.get_mouse()
        if mouse_pos.x < stick_pos.x then
            stick_pos.x = math.max(screen_pos.x - (range_mult * size), mouse_pos.x)
        else
            stick_pos.x = math.min(screen_pos.x + (range_mult * size), mouse_pos.x)
        end
        if mouse_pos.y < stick_pos.y then

            stick_pos.y = math.max(screen_pos.y - (range_mult * size), mouse_pos.y)
        else
            stick_pos.y = math.min(screen_pos.y + (range_mult * size), mouse_pos.y)
        end
    end
    if not mouse_down then stick_pos = screen_pos end
end
draw.filled_circle(stick_pos.x, stick_pos.y, size * 0.75, fill_color, 24)

imgui.pop_id()
-- local diff = stick_pos - screen_pos
-- local newvec, mag = radial_distance(stick_pos.x, stick_pos.y, screen_pos.x, screen_pos.y, size)
local newvec, mag = radial_distance_vec(stick_pos, screen_pos, size)
if stick_pos ~= screen_pos then newvec = newvec:normalized() end
if newvec == nil then newvec = Vector2f.new(0, 0) end
return newvec
end



-- I gave the control stick function that I wrote by hand to an AI and asked it to make a knob
-- it needed a few fixes and may still have some issues which is shockingly good for an aI generated function

function ImGui.Knob(screen_pos, size, fill_color, steps, labels, control_method)
    imgui.push_id(screen_pos.x + screen_pos.y)

    if size == nil then size = 100 end
    if steps == nil or steps < 2 then steps = 8 end -- default to 8 steps
    if fill_color == nil then fill_color = 0xA59DBB17 end

    -- State: current step index
    if ImGui._knob_state == nil then ImGui._knob_state = {} end
    local id = tostring(screen_pos.x) .. "_" .. tostring(screen_pos.y)
    if ImGui._knob_state[id] == nil then ImGui._knob_state[id] = 0 end
    local current_step = ImGui._knob_state[id]

    -- Draw base knob
    draw.filled_circle(screen_pos.x, screen_pos.y, size, fill_color, 32)
    draw.outline_circle(screen_pos.x, screen_pos.y, size, 0xFFFFFFFF, 32)

     local method = ""
    local range_mult = 0.25
    local sens_mult = 0.15
    if sensitivity ~= nil then sens_mult = sensitivity end
    if range ~= nil then range_mult = range end
    local methods = {"ImGuiGamepadLeft", "ImGuiGamepadRight", "WASD", "ArrowKeys", "Mouse", "XInput"}
    if control_method ~= nil and type(control_method) == "string"
        then method = control_method
    elseif type(control_method) == "number" then
        method = methods[control_method]
    end

   local input_keys = {}
    if method == "ImGuiGamepadLeft" then input_keys = {"GamepadLStickLeft",
    "GamepadLStickRight", "GamepadLStickUp", "GamepadLStickDown"}
elseif method == "ImGuiGamepadRight" then input_keys = {"GamepadRStickLeft",
    "GamepadRStickRight", "GamepadRStickUp", "GamepadRStickDown"}
elseif method == "WASD" then input_keys = {"A", "D", "W", "S"}
elseif method == "ArrowKeys" then input_keys = {"LeftArrow", "RightArrow", "UpArrow", "DownArrow"}
end
if #input_keys > 0 then
    for i, v in ipairs(input_keys) do
        if ImGui.is_key_pressed(v) then
            if i == 1 then
                stick_pos.x = math.min(screen_pos.x - (range_mult * size), stick_pos.x - (sens_mult * size))
            elseif i == 2 then
                stick_pos.x = math.max(screen_pos.x + (range_mult * size), stick_pos.x + (sens_mult * size))
            elseif i == 3 then
                stick_pos.y = math.min(screen_pos.y - (range_mult * size), stick_pos.y - (sens_mult * size))
            elseif i == 4 then
                stick_pos.y = math.max(screen_pos.y + (range_mult * size), stick_pos.y + (sens_mult * size))
            else
                stick_pos = screen_pos
            end
        end
    end
end
    -- Handle mouse drag
    local mouse_down = ImGui.is_key_pressed("MouseLeft")
    if mouse_down and ImGui.IsHovered(nil, nil, screen_pos, size * 1.25) then
        local mouse_pos = imgui.get_mouse()
        stick_pos  = mouse_pos
    end
    if not stick_pos == screen_pos then
        local dx = stick_pos.x - screen_pos.x
        local dy = stick_pos.y - screen_pos.y
        local angle = math.atan(dy, dx) -- radians

        -- Normalize angle to [0, 2π)
        if angle < 0 then angle = angle + (2 * math.pi) end

        -- Map angle to discrete step
        local step_angle = (2 * math.pi) / steps
        local new_step = math.floor((angle + step_angle / 2) / step_angle) % steps
        current_step = new_step
        ImGui._knob_state[id] = current_step
    end


    -- Draw indicator line
    local step_angle = (2 * math.pi) / steps
    local indicator_angle = current_step * step_angle - math.pi / 2 -- start at top
    local line_length = size * 0.8
    local x2 = screen_pos.x + math.cos(indicator_angle) * line_length
    local y2 = screen_pos.y + math.sin(indicator_angle) * line_length
    draw.line(screen_pos.x, screen_pos.y, x2, y2, 0xFFFFFFFF)

    -- Draw labels if provided
    if labels ~= nil and type(labels) == "table" then
        for i = 0, steps - 1 do
            local angle = i * step_angle - math.pi / 2
            local lx = screen_pos.x + math.cos(angle) * (size + 20)
            local ly = screen_pos.y + math.sin(angle) * (size + 20)
            local label = labels[i + 1] or tostring(i)
            draw.text(label, lx - 8, ly - 6, 0xFFFFFFFF)
        end
    end

    imgui.pop_id()

    return current_step
end










local ScriptPanels = {}
local world_render = true
local test_vars = {
    interval = 60,
    max_size = 60,
    min_size = 20,

}


local function search_boxed_items(start_pos, end_pos)
    if collection == nil or #collection == 0 then
        collection = Cache.FindAllInstances("Class /Script/Engine.SkinnedMeshComponents", false)
    end
    for idx, val in ipairs(collection) do
        local op = Cache.get_component_screen_pos(obj)
        if (start_pos.x <= op.x) and (op.x <= end_pos.x) and (start_pos.y <= op.y) and (op.y <= end_pos.y) then
            table.insert(found, val)
            print(val:get_short_name())
        end
    end
    json.dump_file("searchres.json", found, 4)
    return found
end
local function testBoxSelect()
    if imgui.is_mouse_down(0) and start_pos == nil then
        start_pos = imgui.get_mouse()
    end
    local start_pos, end_pos = ImGui.BoxSelect(start_pos, true)
    if end_pos ~= nil and end_pos.x ~= 0 and end_pos.y ~= 0 then
        print(start_pos.x .. " " .. start_pos.y)
        print(end_pos.x .. " " .. end_pos.y)
        -- return search_boxed_items(start_pos, end_pos)
    end
end

local can_select = false

local function table_test()

    imgui.begin_table("Test", "SortMulti", Vector2f.new(0,0), 0.5 )
    local names = {"a", "b", "c"}
    local text = {"test1","test2","test3"}
    for i,v in ipairs(names) do
        imgui.table_setup_column(v,0,0,0)
    end
    imgui.table_headers_row()
    imgui.table_header("Header")
    imgui.table_next_row()
    for i,v in ipairs(text) do
        imgui.text(v)
        imgui.table_next_column()
    end
    imgui.end_table()

end


local function box_select_test()
    if imgui.button("toggle") then can_select = not can_select end
    if can_select then testBoxSelect() end
    -- if #found > 0 then
    --     can_select = false
    --     json.dump_file("Selection.json", found,4)
    -- end
end
local knob_value = nil
local function knob_test()
    knob_value = ImGui.Knob(Vector2f.new(300, 300), 60, 0xFF444444, 6, {"0","1","2","3","4","5"})
    draw.text("Knob Value: " .. tostring(knob_value), 400, 300, 0xFFFFFFFF)

end

local frames = 0
ScriptPanels["Widget Tester1"] = function()
 TestWidget()
    end

ScriptPanels["Widget Tester2"] = function()
    TestWidget2()

end
ScriptPanels["Widget Tester"] = function()
    frames = frames + 1
    if frames % 120 then frames = 0 end
    res = res or imgui.get_display_size()
    imgui.set_next_window_size(res)
    imgui.set_next_window_pos(Vector2f.new(0, 0))

    -- imgui.push_style_color(2, Vector4f.new(0.2, 0.2, 0.2, 0.2))

    imgui.begin_window("TesterCanvas", true, ImGui.CalcFlags({"NoMove","NoResize","NoBringToFrontOnFocus","NoNav","NoScrollbar"}, "Window"))

    if  ImGui.ToggleButton("World render", world_render) then world_render = not world_render end
       if  imgui.begin_window("test", nil,0) then



         -- knob_test()
         imgui.end_window()
            pc = pc or api:get_player_controller(0)
    pawn = pawn or api:get_local_pawn(0)
    world =  world or pc:get_outer():get_outer()
     Statics:SetEnableWorldRendering(world, world_render)
        end--[[
        --incrementer2(value,str, min, max, step, display_type, hold_click)
    local s,r = pcall(function()
        squares(Vector2f.new(200, 200), Vector2f.new(400,400), Vector2f.new(30,30))
        -- draw.add_rect_filled(Vector2f.new(200,500), Vector2f.new(30, 30), 0xB1A3D9D)
        end)
    if not s then print(r) end
    -- ImGui.BlinkingCircle(nil, 12, 18, vec_to_u32(Vector4f.new(1.0, 1.0, 1.0, 1.0)), 40, false)

    -- ImGui.BlinkingCircle(nil, 12, 16, vec_to_u32(Vector4f.new(0.67, 1.0, 0.5, 0.60)), 40, true)
    imgui.set_cursor_screen_pos(600, 600)
    imgui.end_window()

    imgui.pop_style_color(1)]]
end

ScriptPanels["Background Overlay"] = BackgroundOverlay

 -- ScriptPanels["Main GUI Styler"] = MainGUIStyle
function ImGui.GetScriptPanels()
    return ScriptPanels
end
test_value = 0


-- takeaways:
-- you can have on_frame embedded within a function and call it from literally anywhere
-- appending to windows works great
-- you can have a userdata as an imgui_id
local close
function ImGui.TestWindows()
    local function test1()
        imgui.begin_window(imgui.get_id("Test1"), not close)
        close = close or imgui.button("Close")
        imgui.text("I didn't use if then end")
        imgui.end_window()
    end

    local function test2()
        if imgui.begin_window(imgui.get_id("Test1")) then
            imgui.text("This time I did use it")
            imgui.begin_child_window(imgui.get_id("Test child"), Vector2f.new(0,0), true, 64)
            imgui.text("test child content")
            imgui.end_child_window()
            imgui.end_window()
        end
    end

        local function test3()
         local open = true
         open = imgui.begin_window(imgui.get_id("Test1"), open)
            imgui.text("This time I used end_window in a different scope")
            if not open then imgui.end_window() end
        end

    uevr.sdk.callbacks.on_frame(function()
                                test_value = 5
        test1()
        test2()
        test3()
        imgui.end_window()
        local id1 = imgui.get_id(pc)
        imgui.push_id(id1)
        test2()

            if imgui.begin_child_window(imgui.get_id("Test child")) then
            imgui.text("test child content")
            imgui.end_child_window()
        end
        imgui.pop_id()
        imgui.text(id1)
    end)


end

-- ImGui.TestWindows()
return ImGui