-- not that good lol pretty old

local Repl = {}


local text = ""
local inspect  = require("inspect")
local selected_func = 0
local console_functions = {}
local live = false
local newfile = ""
local params = {}
local func_name = ""
local live_runs = {}
local ImGui = _G.ImGui or require("ImGui")
local current_func = nil
local keep = false
local selection = ""
local select_all = false
local function set_real_text(buf)
    return 'local _ENV = setmetatable({}, {__index=_G,__newindex=rawset})\napi = uevr.api\n'
        .. buf
end

function Repl.SetConsoleText(buf)
    text = buf
    if buf and #buf ~= 0 then
        text = buf
        buf = nil
    elseif selected_func and console_functions[selected_func] then
        text = console_functions[selected_func]
        selected_func = nil
    end
end


local address = 0
local repl_open = true
local input_query = ""
local found_object = nil
local found_objects = {}
local file_viewer_open = false
function Repl.Open()
    return repl_open
end
local selected_file = nil
local file_content = ""

local function parse_data_dir()
    local data_dir = fs.glob(".*txt")
    local jsons = fs.glob(".*json")
    if #jsons < 200 then
        extend_table(data_dir, jsons )
    end

    return data_dir
end

local                   data_dir = parse_data_dir()
local                           scripts_dir = fs.glob("$scripts\\.*")
print(inspect(scripts_dir))
local browser_open = false

local function file_browser(force_refresh)

    data_dir = (not force_refresh and data_dir) or fs.glob("*")
    scripts_dir =  (not force_refresh and scripts_dir) or fs.glob("$scripts\\.*")
    if imgui.begin_menu("Browser") then
        if scripts_dir and #scripts_dir > 0 and imgui.begin_menu("Scripts") then
            for idx, val in ipairs(scripts_dir) do
                imgui.push_id(idx)
                if imgui.menu_item(al) then
                    selected_file = val
                    file_content = fs.read(val)
                    file_viewer_open = true
                end
                imgui.pop_id()
            end
            imgui.end_menu()
        end
        if data_dir and #data_dir > 0 and imgui.begin_menu("Data") then
            for idx, val in ipairs(data_dir) do
                imgui.push_id(idx)
                if imgui.menu_item(al) then
                    selected_file = val
                    local text = fs.read(selected_file)
                    local s,r = pcall(function()
                        return selected_file:endswith(".json") and
                                    json.load_string(text)
                        end)
                    if s then file_content = r end
                    file_viewer_open = true
                end
                imgui.pop_id()
            end
            imgui.end_menu()
        end
    imgui.end_menu()
    end
end

local selection = ""
local selstart, selend = 1, 1


local function splice_text(newtext, pos)
    if text == nil or text == "" then text = newtext end
    if selection ~= nil and #selection ~= 0 then
        if text:sub(selstart, selend) ~= selection then
            print(selection, selstart, selend)
        else
            local t = text:sub(1, selstart)..newtext..text:sub(selend+1)
            text = t
        end
    elseif pos ~= nil then
        local t = text:sub(1, pos)..newtext..text:sub(pos)
        text = t
    else
        text = text..newtext
    end

 end

local included_mods = {}

local function include(mod, func)
    if included_mods[mod] and included_mods[mod][func] then return end
    if not included_mods[mod] then
        text = "local "..mod.." = require(\""..mod.."\")\n"..text
        included_mods[mod] = {}

    end
    table.insert(included_mods[mod], func)
    splice_text("local "..func.." = "..mod.."."..func)
end
local json_viewer = false
local has_selection = false

local terminal_line_history
-- @param code The current string buffer from the terminal
-- @return status "complete", "incomplete", or "error"
-- @return message The error message if status is "error"
local function check_repl_status(code)
    -- 1. Try to load the code as an expression first (handy for 'print' shortcuts)
    -- This allows typing "2 + 2" instead of "return 2 + 2"
    local chunk, err = load("return " .. code)

    -- 2. If it's not a valid expression, try loading it as a statement
    if not chunk then
        chunk, err = load(code)
    end

    if chunk then
        return "complete"
    end

    -- 3. Analyze the error message
    -- Lua's compiler appends '<eof>' to the error if it expected more code.
    if err:find("<eof>$") or err:find("'end' expected") then
        return "incomplete"
    else
        return "error", err
    end
end
local buffer = ""

-- Simulated user input event
local function on_enter_pressed(input_line)
    buffer = buffer .. "\n" .. input_line

    local status, msg = check_repl_status(buffer)

    if status == "complete" then
        local func = load(buffer)
        local success, result = pcall(func) -- Execute safely
        print(result)
        terminal_line_history[#terminal_line_history] = {
            text = buffer,
            result = result
        }
        buffer = "" -- Reset
    elseif status == "incomplete" then
        -- Do nothing, wait for next input
        print(">> ")
    else
        print("Syntax Error: " .. msg)
        terminal_line_history[#terminal_line_history] = {
            text = buffer,
            result = "syntax error"
        }
        buffer = "" -- Reset on hard error
    end
end


local terminal_text = ""
local terminal_line_count = 1
local terminal_line_last_count = 1
local end_stack = 0
local size
local function terminal()
    local width = math.min(imgui.get_window_size().x * 0.75, 250)
    imgui.push_item_width(width * 1.2)
    terminal_line_history = terminal_line_history or {}
    if #terminal_line_history > 256 then
        for i = #terminal_line_history, 128, -1
        do
            table.remove(terminal_line_history, i)
        end
    end
    local cursor_pos = imgui.get_cursor_pos()
    local cursor_screen_pos = imgui.get_cursor_screen_pos()
    size = (terminal_line_last_count == terminal_line_count and size) or Vector2f.new(
            width,
            imgui.calc_text_size("A").y * terminal_line_count)
    local c, n, s1, s2 = imgui.input_text_multiline(
            "##Terminal",
            terminal_text,
            size,
        ImGui.CalcFlags({"AllowTabInput", "AutoSelectAll"}, "InputText")
    )
    if c or imgui.is_item_active() or imgui.is_item_focused() then
        selstart, selend = s1, s2
        if select_all then
            s1 = 1
            s2 = #terminal_text
        end
        if n ~= terminal_text then
            terminal_text = n
        end
        cursor_pos = imgui.get_cursor_pos()
        cursor_screen_pos = imgui.get_cursor_screen_pos()

        if ImGui.is_key_pressed("MouseRight") then
            imgui.open_popup("Console Context Menu")
        end

        if ImGui.is_key_pressed("Enter") then
            on_enter_pressed(terminal_text)
        end
    end


    selection = terminal_text:sub(s1, s2)
    selstart, selend = s1, s2

    if imgui.begin_popup_context_item("Console Context Menu") then
        if imgui.menu_item("Copy") then
            imgui.set_clipboard(selection)
            imgui.close_current_popup()
        end
        if imgui.menu_item("Paste") then
            local temp = terminal_text:sub(1, s1) .. (imgui.get_clipboard() or selection) .. terminal_text:sub(s2, #terminal_text)
            terminal_text = temp or terminal_text
            imgui.close_current_popup()
        end
        if imgui.menu_item("Select All") then
            selection = text:sub(1, #terminal_text)
            select_all = true
            selstart =
            imgui.close_current_popup()
        end
        imgui.end_popup()
    end
    imgui.separator()

    if imgui.begin_table("###history", 2,
        ImGui.CalcFlags({"BordersInnerV","BordersOuterH",
        "ContextMenuInBody",
        "NoHostExtendX",
        "SizingFixedFit","RowBg"},"Table"))
    then
    imgui.table_setup_column("Chunk", 8)
    imgui.table_setup_column("Result", 8)

    for i = #terminal_line_history, 1, -1 do
        local entry = terminal_line_history[i]
        imgui.table_next_row()
        imgui.table_set_column_index(0)
        imgui.push_id(i)
        imgui.text(entry.text)
        if imgui.begin_popup_context_item("History Context Menu") then
            if imgui.menu_item("Select") then
                terminal_text = entry.text
                imgui.close_current_popup()
            end
            if imgui.menu_item("Save To file") then
                fs.write("Terminal/"..tostring(os.clock)..".txt", entry.text)
                imgui.close_current_popup()
            end
            if imgui.menu_item("Copy") then
                imgui.set_clipboard(entry.text)
                imgui.close_current_popup()
            end
            imgui.end_popup()
        end
        imgui.table_next_column()
        imgui.text(entry.result)
        imgui.pop_id()
    end
    imgui.end_table()
    end
    imgui.pop_item_width()
end


local function repl()

        if imgui.begin_menu_bar("REPL Menu") then
            local available_width = 400
            imgui.push_item_width(available_width)
            if imgui.menu_item("Refresh") then
                            data_dir = parse_data_dir()
                            scripts_dir = fs.glob("$scripts/.*")
                    end
            if imgui.begin_menu("Browse") then

                local s, r = pcall(function()
                            if imgui.begin_menu("Data") then
                                data_dir = data_dir or parse_data_dir()
                                if data_dir and #data_dir ~= 0 then
                                    for index, file in ipairs(data_dir) do
                                        imgui.push_id(index)
                                        if imgui.menu_item(file) then
                                            selected_file = file
                                            file_viewer_open = true
                                            file_content = fs.read(selected_file)
                                            if selected_file:endswith(".json") then
                                                file_content = json.load_string(file_content)
                                                json_viewer = true
                                            else json_viewer = false
                                            end
                                        end
                                        imgui.pop_id()
                                    end
                                end
                                imgui.end_menu()
                            end
                            if imgui.begin_menu("Scripts") then
                                if scripts_dir and #scripts_dir ~= 0 then
                                    for index, file in ipairs(scripts_dir) do
                                        imgui.push_id(index)
                                        if imgui.menu_item(file) then
                                            selected_file = file
                                            file_viewer_open = true
                                            file_content = fs.read(selected_file)
                                            if selected_file:endswith(".json") then
                                                file_content = json.load_string(file_content)
                                                json_viewer = true
                                            else json_viewer = false
                                            end
                                        end
                                        imgui.pop_id()
                                    end
                                end
                                imgui.end_menu()
                            end
                end) if not s then print(r) end
                imgui.end_menu()
                imgui.pop_item_width()
            end

            if imgui.menu_item("Close") then repl_open = false end
            imgui.end_menu_bar()
        end
local s,r = pcall(function()
        local pane_count = file_viewer_open and 3 or 2


                local size = imgui.get_window_size() * 0.65
                imgui.begin_child_window("Text Editor", size, false, ImGui.CalcFlags({"MenuBar",  "AlwaysAutoResize" , "AlwaysVerticalScrollbar"}, "Window"))
                local cursor_pos, cursor_screen_pos = Vector2f.new(0, 0), Vector2f.new(0, 0)
                local c, n, s1, s2 = imgui.input_text_multiline(
                    "###re",
                    text,
                     Vector2f.new(math.min(math.max(200, size.x), 400), math.min(math.max(200, size.y * 0.35), 200)),
            0   --ImGui.CalcFlags({ "AllowTabInput", "AutoSelectAll" }, "InputText")
            )
            if c or imgui.is_item_active() or imgui.is_item_focused() then
                selstart, selend = s1, s2
                if select_all then
                    s1 = 1
                    s2 = #text
                end
                if n ~= text then
                    text = n
                end
                cursor_pos = imgui.get_cursor_pos()
                cursor_screen_pos = imgui.get_cursor_screen_pos()
                local keychord = true
                for idx, val in ipairs({ "LeftCtrl", "LeftShift", "P" }) do
                    if not ImGui.is_key_pressed(val) then
                        keychord = false
                    end
                end
                if keychord or ImGui.is_key_pressed("MouseRight") then
                    imgui.open_popup("Console Context Menu")
                end
            end
            selection = text:sub(s1, s2)
            selstart, selend = s1, s2

            if imgui.begin_popup_context_item("Console Context Menu") then
                if imgui.menu_item("Copy") then
                    imgui.set_clipboard(selection)
                    imgui.close_current_popup()
                end
                if imgui.menu_item("Paste") then
                    local temp = text:sub(1, s1) .. (imgui.get_clipboard() or selection) .. text:sub(s2, #text)
                    text = temp or text
                    imgui.close_current_popup()
                end
                if imgui.menu_item("Select All") then
                    selection = text:sub(1, #text)
                    select_all = true
                    selstart =
                    imgui.close_current_popup()
                end
                imgui.end_popup()
            end
            imgui.end_child_window()

            imgui.begin_group()
            imgui.text("Object search")
            local c, t, s1, s2 = imgui.input_text("address or path", input_query, 0)
            if c then
                input_query = t
            end
            local clicked = imgui.button("Get Object")
            if ImGui.EnterOrClicked(clicked) then
                local address = input_query:to_address()
                if address == nil then
                    local temp = _G.Cache.get("input_query")
                    if temp ~= nil then
                        found_object = temp
                        table.insert(found_objects, found_object)
                        imgui.set_clipboard(
                            "local "
                                .. found_object:get_fname():to_string()
                                .. " = api:find_uobject("
                                .. tostring(input_query)
                                .. ")"
                        )
                    end
                else
                    local temp = api:to_uobject(address)
                    if temp ~= nil then
                        found_object = temp
                        table.insert(found_objects, found_object)
                        imgui.set_clipboard(
                            "local "
                                .. found_object:get_fname():to_string()
                                .. " = api:to_uobject("
                                .. tostring(address)
                                .. ")"
                        )
                    end
                end
            end

            if imgui.collapsing_header("Found objects") then
                for idx, val in ipairs(found_objects) do
                    if imgui.tree_node(val:full_name()) then
                        imgui.text(val:get_address())
                        imgui.tree_pop()
                    end
                end
            end

            imgui.end_group()

        -- imgui.table_next_column()
        if file_viewer_open and selected_file then
            file_content = file_content or fs.read(selected_file)
            if imgui.button("Close Viewer") then file_content = nil
                selected_file = nil
                file_viewer_open = false
                json_viewer = false
            end
            if file_content then
                if not json_viewer then
                    ImGui.ReadOnlyInputText(file_content, nil, true)
                else
                    local cycle = 1
                    local function recurse(t, cycle)
                        if t ~= nil then
                            if type(t) ~= "table" then
                                imgui.text(inspect(t))
                            else
                                for k,v in orderedPairs(t) do
                                    if v ~= nil and k ~= nil  then
                                        if type(v) == "table" then
                                            if imgui.tree_node_ptr_id(k, cycle) then
                                                cycle = cycle + 1
                                                recurse(v, cycle)
                                                imgui.tree_pop()
                                            end

                                            imgui.text(inspect(v))
                                        end
                                    end
                                end
                            end
                        end
                    end
                    recurse(file_content, cycle)
                end
                -- imgui.table_next_column()
            end
        end
end)
if not s then print(r) end

    local c2, n2, sel1, sel2 = imgui.input_text("Function Name", func_name, 0)
    if c2 then
        func_name = n2
    end
    if func_name and imgui.button("Add to function table") then
        console_functions[func_name] = text
        text = ""
    end
    select_all = false
    if imgui.button("Run now") then
        local temp = load(set_real_text(text))
        if type(temp) == "function" then
        local success, result = pcall(function() temp() end)
        if not success then warning_text = result

            if not warning_text:is_in(warnings) then
                table.insert(warnings, warning_text)
                print(warning_text)
            end
        end
            current_func = temp
        else
            print("Error: Invalid function or syntax in console input.")
        end
    end
    if current_func and type(current_func) == "function" then
        current_func()
    end


    if imgui.button("Save as file") then
        if type(set_real_text(temp)) == "function" then
            local wf = io.open("REPL_"..func_name..".lua", "w")
            wf:write(text)
            wf:close()

            local chunk, err = loadfile("REPL_"..func_name..".lua")

            if chunk then
                -- If loading was successful, execute the chunk
                local result = chunk()
                print("Script executed, result:", result)
            else
                -- Handle loading/compilation errors
                print("Error loading script:", err)
            end
        else
            print("Error: Invalid function or syntax in console input.")
        end
    end

    imgui.separator()
    imgui.begin_child_window(
            "Live Tester",
            Vector2f.new(0, 0),
            true,
            ImGui.CalcFlags({ "AlwaysVerticalScrollbar", "AlwaysAutoResize" }, "Window")
        )

        if live_runs and #live_runs > 0 then
            for key, val in pairs(live_runs) do
                imgui.push_id(key)
                imgui.begin_rect()
                imgui.text(key)
                pcall(val())
                imgui.end_rect()
                imgui.pop_id()
            end
        end
        imgui.end_child_window()


end

        uevr.sdk.callbacks.on_frame(function()
            imgui.begin_window("Console", true, ImGui.CalcFlags({ "MenuBar" }, "Window"))
            repl()
            imgui.end_window()
        end)

return Repl