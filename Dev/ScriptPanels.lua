local api = uevr.api
local ImGui = require("ImGui")
local Panels = {}
local begin_style = ImGui.BeginStyle
local end_style = ImGui.EndStyle
local world = nil
local script_panel = uevr.lua.add_script_panel
local panel_themes = json.safe_read(panel_themes_path) or {}
local ImGuiThemes = require("ImGuiThemes")
local themes, theme_names = {}, {}
local selected_theme = nil
local panel_themes_path = "panel_themes.json"
local chunked_panels = {}
local custom_themes =   {}
local panel_themes = json.safe_read("panel_themes.json") or {} -- per-panel overrides
local persisted_panel_windows = {} -- reopen on start/script reset
local panels = {}         -- name -> { panels = { [panel_name] = content }, window = handle }
local warnings = {}
local panel_fonts  = {}
local gameplay_menu = (_ENV.GamePlayMenu or require("UI.GamePlayMenu")).Menu


local cursor_pos
local selected_theme_index = 1
local selected_detach_target = 1



local custom_theme_names = {}
local function reload_themes()
    themes = {}
    theme_names = {}
    for k, v in pairs(ImGuiThemes) do
        themes[k] = v
        table.insert(theme_names, k)
    end

    local _custom_themes = fs.find_in_folder("CustomThemes", "json")
    if _custom_themes ~= nil and #_custom_themes > 0 then
        custom_themes = custom_themes or {}
        for i, v in ipairs(_custom_themes) do
            local name = fs.stem(v)
            local s,r = pcall(function()
                return json.safe_read(v)
            end)
            if s then custom_themes[name] = r end
            table.insert(theme_names, name)
        end
        extend_table(themes, custom_themes)
    end
end




local function load_font(panel_name,name, size)
    local font = imgui.load_font(name, size or 14)
    panel_fonts = panel_fonts or {}
    panel_fonts[panel_name] = panel_fonts[panel_name] or {}
    panel_fonts[panel_name].font = font
    return font
end


local function get_theme_by_name(name)
    if custom_themes and custom_themes[name] then
                return custom_themes[name]
    elseif themes[name] then
        return themes[name]
    end
end

local function save_panel_themes()
    json.dump_file(panel_themes_path, panel_themes, 4)
end

local function panel(panel_name, content)
    local style = panel_themes and panel_themes[name]
    style = style or ImGuiThemes.default_dark
    local selected_font
    if panel_fonts and panel_fonts[panel_name] then
        selected_font =  panel_fonts[panel_name]
    end

    local colorCount, varCount, pushedFont = begin_style(style.colors, style.vars or nil, math.max(width or 200, ImGui.Resolution().x * 0.4), selected_font or nil)
    if content and type(content) == "function" then content() end
    end_style(colorCount, varCount, pushedFont)
end

local adding_new = false
local style_name = ""
local font_size = 14
local color_styles = ImGui.ColorStylesMenu
local hold_progress = 0
local panel_style = nil
local tname = ""
local opened_menus = {}
local selected_items = {}
local function panel_theme_menu(module_name, panel_name)
    panel_themes = panel_themes or {}
    panel_themes[panel_name] = panel_themes[panel_name] or ImGuiThemes.default_dark
    panel_style = panel_style or panel_themes[panel_name]
    if adding_new then
            ImGui.ModalWindow("New Theme", function()
                local c, nn, s1, s2 = imgui.input_text("New Theme Name", style_name, 0)
                if c then style_name = nn end
                imgui.begin_disabled(style_name == nil or #style_name == 0 )
                if imgui.small_button("Save") then
                    json.dump_file("CustomThemes\\"..style_name..".json", panel_style, 4)
                    themes[style_name] = panel_style
                    table.insert(theme_names, style_name)
                    panel_themes[panel_name] = panel_style
                    style_name = ""
                    adding_new = false
                end

                    local cs, panel_style = color_styles(panel_style)
                    if cs then
                        -- panel_style = new_style
                        panel_themes[panel_name] = panel_style
                    end
            end, nil, ImGui.Resolution() * 0.5, nil, nil, true)
        end
        if imgui.begin_menu("Panel Styles") then
            local s, r = pcall(function()
                imgui.push_id(panel_name)
                if imgui.begin_menu("Themes") then
                    for idx, val in ipairs(theme_names) do
                        if imgui.menu_item(val) then
                            selected_theme = val
                            panel_themes[panel_name] = get_theme_by_name(selected_theme)
                            json.dump_file("panel_themes.json", panel_themes, 4)
                        end
                    end

                if imgui.menu_item("New theme") then
                    adding_new = true
                end

                imgui.end_menu()
            end
         end) if not s then print(r) end

            local s, r = pcall(function()
        if imgui.begin_menu("Fonts") then
            imgui.begin_group()
            local f_size = ImGui.incrementer(font_size, 11, 18, "Font Size")
            if f_size ~= font_size then
                font_size = f_size
            end
            imgui.end_group()
            imgui.end_menu()
        end
               if imgui.begin_menu("Fonts") then
            for i, font in ipairs({
                "arial.ttf",
                "bahnschrift.ttf",
                "calibri.ttf",
                "Candara.ttf",
                "CascadiaMono.ttf",
                "comic.ttf",
                "consola.ttf",
                "constan.ttf",
                "corbel.ttf",
                "cour.ttf",
                "ebrima.ttf",
                "Gabriola.ttf",
                "gadugi.ttf",
                "georgia.ttf",
                "himalaya.ttf",
                "impact.ttf",
                "lucon.ttf",
                "malgun.ttf",
                "marlett.ttf",
                "mstmc.ttf",
                "msyi.ttf",
                "mvboli.ttf",
                "ntailu.ttf",
                "pala.ttf",
                "Roboto-Regular.ttf",
                "RobotoMono-Regular.ttf",
                "segoeui.ttf",
                "tahoma.ttf",
                "times.ttf",
                "trebuc.ttf",
                "verdana.ttf",
                }) do
                if imgui.menu_item(font) then
                    load_font(panel_name, font, font_size)
                end
            end
            imgui.end_menu()
        end
    end) if not s then print(r) end

        local c, panel_style = color_styles(panel_style)
        if c then
            panel_themes[panel_name] = panel_style
        end
    imgui.pop_id()
    imgui.end_menu()
    end
end

local stat_text = nil


local gc_stat_display = false
local gc_info =  {
        collect     = {value = "", tip ="Performs a full garbage-collection cycle. This is the default action if no argument is provided."},
        stop        = {value = "", tip ="Stops the automatic execution of the garbage collector. \nThe collector will only run when explicitly invoked until collectgarbage(\"restart\") is called."},
        restart     = {value = "", tip ="Restarts the automatic execution of the garbage collector if it was stopped."},
        step        = {value = 0, tip ="Performs a single step of garbage collection.\nThe optional numerical argument controls the \"size\" of the step.A zero value performs one basic, indivisible step.\nNon-zero values simulate memory allocation for the collector to process. This function returns true if the step completed a full collection cycle."},
        setpause    = {value = 100, tip ="Sets the new value for the garbage collector's pause parameter. The numerical argument is divided by 100 to get the actual pause value.\nIt returns the previous pause value. The pause controls how long the collector waits before starting a new cycle. "},
        setstepmul  = {value = 100, tip ="Sets the new value for the garbage collector's step multiplier. The numerical argument is divided by 100 to get the actual step multiplier value.\nIt returns the previous step multiplier. The step multiplier influences how aggressively the collector runs. "},
    }
local function garbage_collection_menu()
    pc = pc or api:get_player_controller(0)
    if imgui.menu_item("PlayerController GarbageCollection") then pc:ClientForceGarbageCollection() end
    if imgui.menu_item("Clean UEVR UObjects") then
        wipe_table(_sol_lua_push_objects_Object)
        collectgarbage()
    end

    if imgui.menu_item(ImGui.toggle_text("Display Stats", gc_stat_display)) then gc_stat_display = not gc_stat_display end
    if gc_stat_display then
        imgui.text((text == nil or (os.time() % 5 == 0)) and ImGui.toggle_text({"Count: "..tostring(collectgarbage("count")), "Paused"}, collectgarbage("isrunning")))
    end

    for command, data in pairs(gc_info) do
        imgui.push_id(command)
        local s,r = pcall(function()
            if imgui.small_button(command) then
                local command_text = command
                if data.value and type(data.value) == "number" then
                    command_text = command_text.." "..tostring(data.value)
                end
                collectgarbage(command_text)
            end

            if data.value and type(data.value) == "number" then
                imgui.same_line()
                imgui.spacing()
                                imgui.same_line()

                imgui.push_id(command.."value")
                local value = data.value
                local c, nv = imgui.slider_float(command, value, 0, 10000)
                if c then gc_info[command]["value"] = nv end
                imgui.pop_id()
            end
        end)
        if not s then print(r) end
        ImGui.tooltip(command, data.tip)
        imgui.pop_id()
    end
end


-- shortcuts are not implemented
local panel_shortcuts = {}
local key_sets = {}
local function get_key_sets()
    if not key_sets or #key_sets == 0 then
        key_sets = {}
        key_sets["Mod Keys"] = ImGui.key_names({"LeftCtrl", "RightAlt"})
        key_sets["Function Keys"] = ImGui.key_names({"F1", "F12"})
        key_sets["Numpad Keys"] = ImGui.key_names({"Keypad0", "KeypadEqual"})
        key_sets["Arrow Keys"] = ImGui.key_names({"LeftArrow", "DownArrow"})
        key_sets["Symbol Keys"] = ImGui.key_names({"Apostrophe", "GraveAccent"})
        key_sets["Number Keys"] = ImGui.key_names({"0", "9"})
        key_sets["GamepadButtons"] = ImGui.key_names({"GamepadStart", "GamepadFaceDown"})
        key_sets["GamepadLeft"] = ImGui.key_names({"GamepadLStick", "GamepadLStickDown"})
        extend_table(key_sets["GamepadLeft"], {"GamepadL1","GamepadL2","GamepadL3"})
        key_sets["GamepadRight"] = ImGui.key_names({"GamepadLStick", "GamepadLStickDown"})
        extend_table(key_sets["GamepadRight"], {"GamepadR1","GamepadR2","GamepadR3"})
        key_sets["GamepadDpad"] = ImGui.key_names({"GamepadDpadLeft", "GamepadDpadDown"})
        key_sets["Mouse Keys"] = ImGui.key_names({"MouseLeft", "MouseWheelY"})
        key_sets["Letter Keys"] = ImGui.key_names({"A", "Z"})
    end
    return key_sets
end
repl_open = false
-- menu bar
local function menu_bar(panel_name)
    imgui.push_id("###menubar")
    if imgui.begin_menu_bar(panel_name.." menu") then
        if imgui.begin_menu("Module Themes") then
            local s,r = pcall(function() panel_theme_menu(module_name, panel_name) end)
            if not s then print(r) end
            imgui.end_menu()
        end
        if gameplay_menu ~= nil and imgui.begin_menu("Game") then
         gameplay_menu()

                 imgui.end_menu()
            end
        if imgui.begin_menu("Warnings") then

                if warnings and warnings[panel_name] then

                    if imgui.menu_item(inspect(warnings[panel_name])) then
                        imgui.set_clipboard(inspect(warnings[panel_name]))
                    end

                end
            -- end
            imgui.end_menu()
        end
        if imgui.begin_menu("Shortcut", need_shortcut) then
            imgui.text("Set a shortcut key/action to directly open the panel even if the UI is closed")
            for set, keys in orderedPairs(get_key_sets()) do
                if set ~= "Letter Keys" and set ~= "Number Keys" then
                    if imgui.begin_menu(set) then
                        for i, key in ipairs(keys) do
                            if imgui.menu_item(ImGui.toggle_text(key, panel_shortcuts and panel_shortcuts[panel_name] and panel_shortcuts[panel_name] == key)) then
                                panel_shortcuts[panel_name] = key
                            end
                        end
                      imgui.end_menu()
                    end
                end
            end
            imgui.end_menu()
        end

        if imgui.begin_menu("Garbage Collector") then
                pcall(function() garbage_collection_menu() end)
                imgui.end_menu()
        end
        detached_panels = detached_panels or {}
        local detach = detached_panels[panel_name]
        if imgui.menu_item(ImGui.toggle_text("Detach", detach)) then detach = not detach
            if detach then detached_panels[panel_name] = true
            end
        end
        imgui.end_menu_bar()
    end
    imgui.pop_id()
end

Panels.MenuBar = menu_bar

local scroll_y = 0

local warning_text = ""
local panel_vars = {}
local choice = 0

-- crash proof script panels with standardized menu bars and inapp error display
function Panels.ScriptPanel(panel_name, panel_data)
    local function func()
        panels[panel_name] = panel_data
        script_panel(panel_name, function()
           imgui.begin_child_window(
               "###menubar"..panel_name,
                Vector2f.new(0, 0),
                false,
                ImGui.CalcFlags({"MenuBar","NoMove","AlwaysAutoResize"}, "Window")
            )
            if imgui.is_item_hovered(2048)
            or imgui.is_item_focused() or imgui.is_item_active() then
                open_panel_name =  panel_name
            end
            menu_bar(panel_name)
            choice = ImGui.ScrollButtons(panel_name)
                imgui.begin_child_window(panel_name, Vector2f.new(0,0), false, 0)
                if imgui.is_item_hovered(2048) then
                    open_panel_name =  panel_name
                end

                 if choice and choice > 0 then
                        local scrolly = imgui.get_scroll_y()
                        local maxy = imgui.get_scroll_max_y()
                        local t = {0, scrolly - 20, maxy * 0.5, scrolly + 20, maxy}
                        pcall(function()
                              imgui.set_scroll_y(t[choice])
                            end)
                        choice = 0

                    end
                    local success, result = pcall(function()
                        panel(panel_name, panel_data)
                    end)
                    if not success then
                        warnings[panel_name] =  warnings[panel_name] or {}
                        warnings[panel_name][result] = true
                        printOnce(result)
                        end
            imgui.end_child_window()
            imgui.end_child_window()
            end)
    end
    imgui.push_id(imgui.get_id(panel_name))
    func()
    imgui.pop_id()
end

-- add theme support and menu bar to main gui
local mainguimod = true
function Panels.OnFrame(fn)
    imgui.push_id(UEVR_NAME)
    panel_name = UEVR_NAME
    panels[UEVR_NAME] = fn or true
    local style = panel_themes and panel_themes[UEVR_NAME]
    local selected_font
    style = style or ImGuiThemes.default_dark
    if panel_fonts and panel_fonts[UEVR_NAME] then
        selected_font = panel_fonts[UEVR_NAME]
    end

local colorCount, varCount, pushedFont = begin_style(style.colors, style.vars or nil, math.max(width or 400, ImGui.Resolution().x * 0.6), selected_font or nil)
 if uevr.params.functions.is_drawing_ui() then
    imgui.begin_window(UEVR_NAME, true, ImGui.CalcFlags({"MenuBar"},"Window"))
    menu_bar(UEVR_NAME)
    imgui.end_window()
    end
    end_style(colorCount, varCount, pushedFont)
end
return Panels