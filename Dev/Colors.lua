local atan, abs, asin, acos, sin, cos, rad, deg, floor, max, min, random, sqrt = math.atan, math.abs, math.asin, math.acos, math.sin, math.cos, math.rad, math.deg, math.floor, math.max, math.min, math.random, math.sqrt



-- Converts HSV (0.0-1.0 range) to RGB (0.0-1.0 range)
local function hsv_to_rgb(h, s, v)
    local i = floor(h * 6)
    local f = h * 6 - i
    local p = v * (1 - s)
    local q = v * (1 - f)
    local t = v * (1 - (1 - f) * s)

    local r, g, b
    local mod_i = i % 6

    if mod_i == 0 then r, g, b = v, t, p
    elseif mod_i == 1 then r, g, b = q, v, p
    elseif mod_i == 2 then r, g, b = p, v, t
    elseif mod_i == 3 then r, g, b = p, q, v
    elseif mod_i == 4 then r, g, b = t, p, v
    else r, g, b = v, p, q
    end

    return r, g, b
end


local generated_colors
-- get a semi-random, bright, and saturated color (0.0-1.0 RGBA)
-- easy to use for debug shapes, e.y. with 800 or so colliders suddenly drawn
-- use VecToU32 with draw api
-- for UE linear colors you generally just multiply by 255
local function get_semi_random_bright_color(index, total_count, get_all)
     local function generate_one(i, count)
        -- convert to HSV since this is easiest to think of in terms of hue variation by index
        -- (math.xandom() * 0.1) adds a slight random jitter to prevent band-like colors
        local h = (i / count + random() * 0.1) % 1.0

        -- hsv also makes it easier to guarantee high saturation without bias towards a hue
        -- these two lines are basically just picking random numbers in the ranges 0.8-1.0 and 0.9 - 1.0 respectively
        local s = 0.8 + random() * 0.2

        -- same deal with brightness
        local v = 0.9 + random() * 0.1

        -- Convert HSV back to RGB
        local r, g, b = hsv_to_rgb(h, s, v)

        return Vector4f.new(r, g, b, 1.0)
    end



    total_count = (total_count and total_count > 255 and total_count) or 255
    index = index or random(total_count)
    generated_colors = generated_colors or {}
    if #generated_colors < total_count then
        for i = #generated_colors, total_count do
            generated_colors[i] = generate_one(i, total_count)
        end
    end

    if get_all then return generated_colors end
    local color = generated_colors[index]
    return color.x ~= nil and color or generate_one(index, total_count)
end



local function strobe()
    local color = get_semi_random_bright_color()
    uevr.sdk.callbacks.on_frame(function()
        color = get_semi_random_bright_color()
    end)
    return color
end




local function vec4_to_linear_color(color)
    return {
        R = color.x * 255.0,
        G = color.y * 255.0,
        B = color.z * 255.0,
        A = color.w * 255.0,
    }
end


local function random_linear_color()
    local color = get_semi_random_bright_color()
    return {
        R = color.x * 255.0,
        G = color.y * 255.0,
        B = color.z * 255.0,
        A = 255.0,
    }
end


function string:ToU32Color(mul)
    mul = mul or 1
    local r, g, b, a
    r, g, b = self:match("#(%x%x)(%x%x)(%x%x)")
    if r then
        r = tonumber(r, 16) / 0xff
        g = tonumber(g, 16) / 0xff
        b = tonumber(b, 16) / 0xff
        a = 1
    elseif self:match("rgba?%s*%([%d%s%.,]+%)") then
        local f = self:gmatch("[%d.]+")
        r = (f() or 0) / 0xff
        g = (f() or 0) / 0xff
        b = (f() or 0) / 0xff
        a = f() or 1
    else
        error(("bad color string '%s'"):format(str))
    end
    return r * mul, g * mul, b * mul, a * mul
end

local function vec_to_hex_str(vec)
    return string.format("%08X", vec_to_u32(vec))
end


-- ImGui expects 0xAABBGGRR
local function vec_to_u32(vec)
    local r = floor(max(0, min(255, vec.x * 255 + 0.5)))
    local g = floor(max(0, min(255, vec.y * 255 + 0.5)))
    local b = floor(max(0, min(255, vec.z * 255 + 0.5)))
    local a = floor(max(0, min(255, vec.w * 255 + 0.5)))
    return (a << 24) | (b << 16) | (g << 8) | r
end

local prev_uint = 0
local vec = nil
local function u32_to_v(color)
    if prev_uint ~= nil and prev_uint == color and vec ~= nil then
        return vec
    end
    prev_uint = color
    local r = color & 0xFF
    local g = (color >> 8) & 0xFF
    local b = (color >> 16) & 0xFF
    local a = (color >> 24) & 0xFF

    col = {
        r / 255.0,
        g / 255.0,
        b / 255.0,
        a / 255.0,
    }
    vec = Vector4f.new(r, g, b, a)
    return vec
end


local function coerce_color_type(color)
    return (type(color) == "number" and color)
        or (color.x ~= nil and vec_to_u32(color))
        or (type(color) == "table" and vec_to_u32(fcolor_to_v4(color)))
end

