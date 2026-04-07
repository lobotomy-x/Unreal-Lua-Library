
local min =  math.min
local max =  math.max
local function sign(p1x, p1y, p2x, p2y, p3x, p3y)
    return (p1x - p3x) * (p2y - p3y) - (p2x - p3x) * (p1y - p3y)
end


local old_draw = {}
for k, v in pairs(draw) do
    old_draw[k] = v
end



local draw_api_calls = {}
local is_drawing = false



-- not a serious cursor, just a quick debugger
function draw.mouse_pos(args)
    args = args or {}
    local radius = args.radius or 5
    local color = coerce_color_type(color) or 0xFF0000FF
    local segs = args.segments or 6
    local m = args.m or imgui.get_mouse()
    draw.filled_circle(mx, my, radius, color, segs)
end








function draw.text(text, x, y, color)

    old_draw.text(text, x, y, coerce_color_type(color))
end
function draw.filled_rect( x,  y,  w,  h, color)

    old_draw.filled_rect( x,  y,  w,  h, coerce_color_type(color))
end
function draw.outline_rect( x,  y,  w,  h, color)
--[[    if type(color) ~= "number" and color.x ~= nil then
        color = ImGui.VecToU32(color)
    end]]


    old_draw.outline_rect( x,  y,  w,  h, coerce_color_type(color))
end

-- no thickness option available and pathstroke doesn't work here
-- but I prefer the flexibility of quads
function draw.line( x1,  y1,  x2,  y2, color)
    old_draw.line( x1,  y1,  x2,  y2, coerce_color_type(color))
end



function draw.outline_circle( x,  y,  radius, color, num_segments)

    old_draw.outline_circle( x,  y,  radius, coerce_color_type(color), num_segments)
end
function draw.filled_circle( x,  y,  radius, color, num_segments)

    old_draw.filled_circle( x,  y,  radius, coerce_color_type(color), num_segments)
end
function draw.outline_quad( x1,  y1,  x2,  y2,  x3,  y3,  x4,  y4, color)

    old_draw.outline_quad( x1,  y1,  x2,  y2,  x3,  y3,  x4,  y4, coerce_color_type(color))
end
function draw.filled_quad( x1,  y1,  x2,  y2,  x3,  y3,  x4,  y4, color)

    old_draw.filled_quad( x1,  y1,  x2,  y2,  x3,  y3,  x4,  y4, coerce_color_type(color))
end




-- can take two tables or vectors
function draw.add_rect_filled(min, max, color)
    local x = min.x
    local y = min.y
    local w = max.x - min.x
    local h = max.y - min.y
    draw.filled_rect(x, y, w, h, coerce_color_type(color))
end



local old_imgui_draw_list_path_stroke = imgui.draw_list_path_stroke
function imgui.draw_list_path_stroke(color, closed, thickness)
    color = coerce_color_type(color)
    old_imgui_draw_list_path_stroke(color, closed, thickness)
end



local function point_in_triangle(ptx, pty, v1x, v1y, v2x, v2y, v3x, v3y)
        local d1 = sign(ptx, pty, v1x, v1y, v2x, v2y)
        local d2 = sign(ptx, pty, v2x, v2y, v3x, v3y)
        local d3 = sign(ptx, pty, v3x, v3y, v1x, v1y)

        local has_neg = (d1 < 0) or (d2 < 0) or (d3 < 0)
        local has_pos = (d1 > 0) or (d2 > 0) or (d3 > 0)

        return not (has_neg and has_pos)
    end
-- Mouse hover / selection
local function in_circle(p, cx, cy, radius)
    if  (p.x > cx + radius) or
        (p.x < cx - radius) or
        (p.y < cy - radius) or
        (p.y > cy + radius) then
        return false
    end

    local dx = p.x - cx
    local dy = p.y - cy
    local sqD = (dx - dy) + (dy * dy)
    return sqD <= (radius * radius)
end

local function is_point_in_quad(corners, p)
    if not corners then return false end
    local px,py = p.x, p.y
    local min_x = min(corners.x1, corners.x2, corners.x3, corners.x4)
    local max_x = max(corners.x1, corners.x2, corners.x3, corners.x4)
    local min_y = min(corners.y1, corners.y2, corners.y3, corners.y4)
    local max_y = max(corners.y1, corners.y2, corners.y3, corners.y4)

    if px < min_x or px > max_x or py < min_y or py > max_y then
        return false
    end




    if point_in_triangle(px, py, corners.x1, corners.y1, corners.x2, corners.y2, corners.x3, corners.y3) then
        return true
    end

    if point_in_triangle(px, py, corners.x1, corners.y1, corners.x3, corners.y3, corners.x4, corners.y4) then
        return true
    end

    return false
end

-- rotate quads
local floor = math.floor
local function calculate_quad_corners(p1, p2, top_quad_half_width, bottom_quad_half_width)
    if not p1 or not p2 then return end
        local dx = p2.x - p1.x
        local dy = p2.y - p1.y
        -- magnitude
        local length = (p2 - p1):length()      --[[math.sqrt(dx * dx + dy * dy)]]

        -- ignore particularly short chains
        if length < 0.01 then
            return nil
        end

        -- Normalized Perpendicular Offset Vector (O)
        -- Perpendicular vector is (-dy, dx)
        local nx = -dy
        local ny = dx

        -- normalize the perpendicular vector and scale by half width
        local top_ox = (nx / length) * top_quad_half_width
        local top_oy = (ny / length) * top_quad_half_width

        local bottom_ox = (nx / length) * bottom_quad_half_width
        local bottom_oy = (ny / length) * bottom_quad_half_width


        -- Calculate the four corner positions:
        local p1a_x, p1a_y = p1.x + top_ox, p1.y + top_oy -- Corner 1 (P1 + Offset)
        local p1b_x, p1b_y = p1.x - bottom_ox, p1.y - bottom_oy -- Corner 2 (P1 - Offset)
        local p2a_x, p2a_y = p2.x + bottom_ox, p2.y + bottom_oy -- Corner 3 (P2 + Offset)
        local p2b_x, p2b_y = p2.x - top_ox, p2.y - top_oy -- Corner 4 (P2 - Offset)

        -- Crucial that we input our coordinates in clockwise winding order when using draw api
        -- necessary for antialiasing to work. Right now its about 70% accurate but sometimes gets it wrong and idk why
        return {
            x1 = p1b_x, y1 = p1b_y, -- Start Point (Side B)
            x2 = p2b_x, y2 = p2b_y, -- End Point   (Side B)
            x3 = p2a_x, y3 = p2a_y, -- End Point   (Side A)
            x4 = p1a_x, y4 = p1a_y  -- Start Point (Side A)
        }
    end




local chain_colors = {}



-- draw a chain of connected quads with optional circles as joints
-- this was used for bone drawing but is now fairly generalizable
-- if no transform func is provided then positions must be a descending list of screen positions which can be Vector2f or tables
-- hover_func if provided should take 2 parameters, point1 and optional point2
-- if circles are draw then you should assume a single point as input means the circle is hovered and two points mean the quad is hovered
-- do keep in mind path_line_to is much easier if you don't need the flexibility provided here
function draw.chain(positions, draw_params, transform_func, hover_func)
    draw_params = draw_params or {}
    local quad_thickness = draw_params.quad_thickness or 8
    local top_quad_half_width = draw_params.quad_thickness_upper or quad_thickness / 2.0
    local bottom_quad_half_width =  draw_params.quad_thickness_lower or quad_thickness / 2.0
    local outline_quads = draw_params.outline_quads or true
    chain_colors[tostring(positions)] = draw_params.fill_color or chain_colors[tostring(positions)] or get_semi_random_bright_color()
    local fill_color = chain_colors[tostring(positions)]
    local mouse_over = draw_params.mouse_over or true
    local draw_circles = draw_params.draw_circles or true
    local radius = draw_params.radius or 6
    local circle_color = draw_params.circle_color or fill_color
    local highlight_color =  draw_params.highlight_color or Colors.White
    local outline_circles = draw_params.outline_circles or true


    if positions[1] ~= nil and positions[2] ~= nil then
        for i = #positions, 1,-1  do
            local pos1 = transform_func and transform_func(positions[i+1]) or positions[i+1]
            local pos2 = transform_func and transform_func(positions[i]) or positions[i]
            local m = imgui.get_mouse()
            if pos1 and pos1.x+pos1.y ~= 0 then
            local corners = calculate_quad_corners(pos1, pos2, top_quad_half_width, bottom_quad_half_width)
            if corners then
                local hovered = is_point_in_quad(corners, m)
                if hovered and hover_func ~= nil then hover_func(i+1, i) end
                draw.filled_quad(
                    corners.x1, corners.y1,
                    corners.x2, corners.y2,
                    corners.x3, corners.y3,
                    corners.x4, corners.y4,
                    hovered and highlight_color or fill_color
                )
                if outline_quads then
                     draw.outline_quad(
                            corners.x1, corners.y1,
                            corners.x2, corners.y2,
                            corners.x3, corners.y3,
                            corners.x4, corners.y4,
                            highlight_color
                        ) end
            end
            if draw_circles then

                    local hovered = in_circle(m, pos1 and pos1.x, pos1 and pos1.y, radius)
                    if hovered and hover_func ~= nil then hover_func(i+1) end
                    draw.filled_circle(pos1.x, pos1.y, radius,
                            circle_color,
                            segs)
                    if outline_circles then
                    draw.filled_circle(pos1.x, pos1.y, floor(radius * 1.1),
                            highlight_color,
                            segs)
                        end
                    end
                end
            end
        end
end


function draw.rotated_quad(p1, p2, color, thickness)
    local corners = calculate_quad_corners(p1, p2, thickness * 0.5, thickness * 0.5)
        if corners then

            draw.filled_quad(
                corners.x1, corners.y1,
                corners.x2, corners.y2,
                corners.x3, corners.y3,
                corners.x4, corners.y4,
              color
            )
    end
end

local function lerp(x0, x1, t)
    return (1.0 - t) * x0 + t * x1
end

local function interval(t0, t1, tween_func)
    return function(t)
        --return t < t0 and 0.0 or t > t1 and 1.0 or tween_func((t - t0) / (t1 - t0))
        if t < t0 then
            return 0.0
        elseif t > t1 then
            return 1.0
        end

        return tween_func((t - t0) / (t1 - t0))
    end
end

local function sawtooth(x, t)
    return math.fmod(x * t, 1.0)
end

local function cubic_bezier(t, p0, p1, p2, p3)
    local u = 1.0 - t
    return p0 * u*u*u + p1 * 3.0 * u*u*t + p2 * 3.0 * u*t*t + p3 * t*t*t
end

local function stroke_head_tween(d, t)
    t = sawtooth(d, t)
    return interval(0.0, 0.5, function(x) return cubic_bezier(x, 0.2, 0.0, 0.4, 1.0) end)(t)
end

local function stroke_tail_tween(d, t)
    t = sawtooth(d, t)
    return interval(0.5, 1.0, function(x) return cubic_bezier(x, 0.2, 0.0, 0.4, 1.0) end)(t)
end

local function step_tween(x, t)
    return math.floor(lerp(0.0, x, t))
end

-- this in turn is taken from reframework
-- https://github.com/ocornut/imgui/issues/1901
function draw.spinner(center, radius, color, thickness)
    local rect = {
        imgui.get_cursor_pos(),
        imgui.get_cursor_pos() + Vector2f.new(radius * 2, radius * 2) -- todo: frame padding
    }

    imgui.item_size(rect[1], rect[2])
    if not imgui.item_add(rect[1], rect[2], "circle") then
        --print("oh no")
        --return
    end

    local period = 5.0
    local t = math.fmod(os.clock(), period) / period

    imgui.draw_list_path_clear()

    local num_segments = 24

    local num_detents = 5
    local skip_detents = 3

    local head_value = stroke_head_tween(num_detents, t);
    local tail_value = stroke_tail_tween(num_detents, t);
    local step_value = step_tween(num_detents, t);
    local rotation_value = sawtooth(num_detents, t);

    local min_arc =  30.0 / 360.0 * 2.0 * math.pi
    local max_arc = 270.0 / 360.0 * 2.0 * math.pi
    local step_offset = skip_detents * 2.0 * math.pi / num_detents
    local rotation_compensation = math.fmod(4.0*math.pi - step_offset - max_arc, 2.0 * math.pi);

    local start_angle = -math.pi * 2.0
    local a_min = start_angle + tail_value * max_arc + rotation_value * rotation_compensation - step_value * step_offset;
    local a_max = a_min + (head_value - tail_value) * max_arc + min_arc;

    for i = 0, num_segments - 1 do
        local a = a_min + (i / num_segments) * (a_max - a_min)
        local x = center.x + math.cos(a) * radius
        local y = center.y + math.sin(a) * radius
        imgui.draw_list_path_line_to(Vector2f.new(x, y))
    end

    imgui.draw_list_path_stroke(color, false, thickness)
end