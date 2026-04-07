
local function draw_motion_path(object, path, maxpt, color, alt_method)
    local screen_location
    local last_screen_location
    local vmag = object:get_outer():velocity():length()
    local vel = object:get_outer():velocity():to_string()
    path = path or {}
    if #path >= maxpt or vmag == 0  then
        while #path > maxpt do
            table.remove(path, 1)
        end
    end

    table.insert(path, object:location())
    canvas_window("MotionCanvas")
    -- imgui.draw_list_path_clear()
    if alt_method then
        if #path >= 2 then
        for i = 2, #path do
            local v = path[i]
            last_screen_location  = path[i-1]:world_to_screen()
            if last_screen_location.x + last_screen_location.y ~= 0 then
                screen_location = v:world_to_screen()
                if screen_location.x + screen_location.y ~= 0 then
                    local _color = color
                    _color.w = math.max(1.0 - (i / #path), 0.25)
                    draw.line(last_screen_location.x, last_screen_location.y, screen_location.x, screen_location.y, _color)
                        if #path > 10 and i % 10 == 0 then
                            draw.filled_circle(screen_location.x, screen_location.y, _color.w * 13, _color, 8)
                        end
                    end
                end
            end
        end
    else
        for i,v in ipairs(path) do
            screen_location = v:world_to_screen()
            if screen_location.x + screen_location.y == 0 then
                imgui.draw_list_path_clear()
            else
                imgui.draw_list_path_line_to(screen_location)
                if #path > 100 and i % 10 == 0 then
                    local alpha  = math.max(1.0 - (i / #path), 0.25) * 13
                    draw.filled_circle(screen_location.x, screen_location.y, alpha , Vector4f.new(color.x, color.y, color.z, alpha), 8)
                end
            end
        end
        imgui.draw_list_path_stroke(color, false, 8)
    end
    if screen_location and vmag ~= 0 then
        imgui.set_cursor_screen_pos(screen_location - Vector2f.new(0, 200))
        imgui.text("velocity: "..vel)
        imgui.set_cursor_screen_pos(screen_location)
        imgui.text("velocity length: "..tostring(vmag))
    end
    imgui.end_window()
end


 local scene_objects =  ("SceneComponent"):find_all_instances(false)
    for i = #scene_objects, 1 -1 do
        local v = scene_objects[i]
        if UEVR_UObjectHook.exists(v) then

            if v:velocity():length() > 4 or (scpt[v] and v:velocity():length() ~= 0) then
                trackercolors[v] = trackercolors[v] or get_semi_random_bright_color()
                scpt[v] = scpt[v] or {}
                draw_motion_path(v, scpt[v], 20, trackercolors[v])
            end
        else
            table.remove(scene_objects, i)
        end
    end

    if mesh then
        trackercolors[mesh] = trackercolors[mesh] or get_semi_random_bright_color()
        draw_motion_path(mesh, points, 500, trackercolors[mesh])
    end