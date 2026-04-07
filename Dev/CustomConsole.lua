
local console = api:get_console_manager()
local cvars = {}
local input_query = ""
local command = ""
local output_value = ""
local default_value = ""
local good_func = ""
panels["Custom Console"] = function()
    pc = pc or api:get_player_controller(0)
    imgui.push_item_width(imgui.get_window_size().x * 0.5)
    imgui.begin_group()
    local c, new_query, s1, s2 = imgui.input_text("ConsoleVarTester", command)
    if c then
        command = new_query
        input_query = new_query:match("^%S+")
    end
    imgui.pop_item_width()
    local send_to_console = imgui.button("Send to Console")
    if ImGui.EnterOrClicked(send_to_console) then
        pc:SendToConsole(input_query)
    end
    local entered = (ImGui.is_key_pressed("LeftShift") and ImGui.is_key_pressed("Enter"))
    and (imgui.is_item_active() or imgui.is_item_focused())
    local clicked = imgui.button("Submit to System Console")
    if entered or clicked then
        for idx, val in ipairs({"Int", "Float", "Bool", "String"}) do
            local func = "GetConsoleVariable" .. val .. "Value"
            local temp = sys:call(func, input_query)
            if temp ~= nil then
                default_value = temp
                good_func = func
                break
            end
        end
        -- sys:ExecuteConsoleCommand(world, command, pc)
        api:execute_command(command)
        output_value = sys:call(good_func, input_query)

        local entry = {}
        entry[command]["Default"] = default_value
        entry[command]["New"] = output_value
        local cvard = json.safe_read("ConsoleHistory.json")
        if cvard ~= nil then
            table.insert(cvard, entry)
        else
            cvard = {}
            table.insert(cvard, entry)
        end
        json.dump_file("ConsoleHistory.json", cvard, 4)
    end
    if imgui.collapsing_header("Console objects") then
        imgui.text(inspect(console:get_console_objects()))
    end
    if imgui.collapsing_header("Console objects2") then

        for k, v in pairs(console:get_console_objects()) do
            if imgui.tree_node(k) then
                if v:as_command() then imgui.text("COMMAND")
                    if imgui.button("Execute") then
                        v:execute(input_query)
                    end
                else
                    imgui.text(tostring(val:get_int()).."\n"..tostring(val:get_float()))
                end
            end
        end


    end

    -- if imgui.button("Use UEVR_GameViewPort exec") then
        -- UEVR_UGameViewportClient
    imgui.text(output_value .. " old: (" .. default_value .. ")")
end
