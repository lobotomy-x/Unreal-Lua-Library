
local GLM_Types = {
    Vector2f, Vector2d,
    Vector3f, Vector3d,
    Vector4f, Vector4d,
    Quaternionf, Quaterniond
}


UE5 = _G.UE5
function string:to_table()
    local t = {}
    for char in self:gmatch(".") do
        t[#t + 1] = char
    end
    return t
end


Vector3 = UE5 and Vector3d or Vector3f

-- just keeping them like this since we literally never need the d versions with UE
Vector4 = Vector4f
Vector2 = Vector2f
local fquat = UE5 and Quaterniond or Quaternionf


local QuatMT = {
    __index = function(t, k)
        return fquat[k:lower()]
    end,
    __call = function(t, ...)
        return fquat.new(...)
    end
}


Quat = setmetatable({}, QuatMT)
local q = Quat(1.0, 1.0, 2.0, 3.0)
print(q.x)       -- Looks up fquat.identity

local fvec2d = UE5 and Vector2d or Vector2f
FVector2D = setmetatable({}, {
    __index = function(t, k)
        return fvec2d[k:lower()]
    end,
    __call = function(t, ...)
        local c = select("#", ...)
        if c == 1 then
            local n = select(1, ...)
            return fvec2d.new(n, n, n)
        elseif c == 3 then
            return fvec2d.new(...)
        end
    end
})

FVector = setmetatable({}, {
    __index = function(t, k)
        return Vector3[k:lower()]
    end,
    __call = function(t, ...)
        local c = select("#", ...)
        local n = select(1, ...)
        if c == 1 then
            local nt = type(n)
            if nt == "table" then
                return Vector3.new(table.unpack(n))
            elseif nt == "number" then
                return Vector3.new(n, n, n)
            elseif nt == "string" then
                local nn = tonumber(n)
                return Vector3.new(nn, nn, nn)
            elseif n and n.x then
                return n
            end
        elseif c == 3 then
            return Vector3.new(...)
        end
    end
})


local vfv = FVector(1.0)
print("fvector.y", vfv.y)



local UE_MATH_DEFINES = {}
UE_MATH_DEFINES.PI              =   3.1415926535897932
UE_MATH_DEFINES.TWO_PI              = 6.2831853071795864
UE_MATH_DEFINES.SMALL_NUMBER    = 1.e-8
UE_MATH_DEFINES.KINDA_SMALL_NUMBER = 1.e-4
UE_MATH_DEFINES.BIG_NUMBER      = 3.4e+38
UE_MATH_DEFINES.EULERS_NUMBER   = 2.71828182845904523536
UE_MATH_DEFINES.UE_GOLDEN_RATIO = 1.6180339887498948482045868343656381
UE_MATH_DEFINES.FLOAT_NON_FRACTIONAL = 8388608 -- All single-precision floating point numbers greater than or equal to this have no fractional value. ]]

-- Copied from float.h
UE_MATH_DEFINES.MAX_FLT =  3.402823466e+38

-- Aux constants.
UE_MATH_DEFINES.INV_PI     = 0.31830988618
UE_MATH_DEFINES.HALF_PI    = 1.57079632679

-- Common square roots
UE_MATH_DEFINES.UE_SQRT_2       = 1.4142135623730950488016887242097
UE_MATH_DEFINES.UE_SQRT_3       = 1.7320508075688772935274463415059
UE_MATH_DEFINES.UE_INV_SQRT_2   = 0.70710678118654752440084436210485
UE_MATH_DEFINES.UE_INV_SQRT_3   = 0.57735026918962576450914878050196
UE_MATH_DEFINES.UE_HALF_SQRT_2  = 0.70710678118654752440084436210485
UE_MATH_DEFINES.UE_HALF_SQRT_3  = 0.86602540378443864676372317075294


-- Magic numbers for numerical precision.
UE_MATH_DEFINES.DELTA = 0.00001
--[[
    Lengths of normalized vectors (These are half their maximum values
    to assure that dot products with normalized vectors don't overflow).
 ]]
UE_MATH_DEFINES.FLOAT_NORMAL_THRESH  = 0.0001


-- Magic numbers for numerical precision.

UE_MATH_DEFINES.THRESH_POINT_ON_PLANE = 0.10        --[[ Thickness of plane for front/back/inside test ]]
UE_MATH_DEFINES.THRESH_POINT_ON_SIDE = 0.20         --[[ Thickness of polygon side's side-plane for point-inside/outside/on side test ]]
UE_MATH_DEFINES.THRESH_POINTS_ARE_SAME = 0.00002  --[[ Two points are same if within this distance ]]
UE_MATH_DEFINES.THRESH_POINTS_ARE_NEAR = 0.015    --[[ Two points are near if within this distance and can be combined if imprecise math is ok ]]
UE_MATH_DEFINES.THRESH_NORMALS_ARE_SAME = 0.00002  --[[ Two normal points are same if within this distance ]]
UE_MATH_DEFINES.THRESH_UVS_ARE_SAME = 0.0009765625--[[ Two UV are same if within this threshold (1.0f/1024f) ]]
                                                    --[[ Making this too large results in incorrect CSG classification and disaster ]]
UE_MATH_DEFINES.THRESH_VECTORS_ARE_NEAR = 0.0004  --[[ Two vectors are near if within this distance and can be combined if imprecise math is ok ]]
                                                    --[[ Making this too large results in lighting problems due to inaccurate texture coordinates ]]
UE_MATH_DEFINES.THRESH_SPLIT_POLY_WITH_PLANE = 0.25     --[[ A plane splits a polygon in half ]]
UE_MATH_DEFINES.THRESH_SPLIT_POLY_PRECISELY  = 0.01     --[[ A plane exactly splits a polygon ]]
UE_MATH_DEFINES.THRESH_ZERO_NORM_SQUARED     = 0.0001   --[[ Size of a unit normal that is considered "zero", squared ]]
UE_MATH_DEFINES.THRESH_NORMALS_ARE_PARALLEL  = 0.999845 --[[ Two unit vectors are parallel if abs(A dot B) is greater than or equal to this. This is roughly cosine(1.0 degrees). ]]
UE_MATH_DEFINES.THRESH_NORMALS_ARE_ORTHOGONAL= 0.017455 --[[ Two unit vectors are orthogonal (perpendicular) if abs(A dot B) is less than or equal this. This is roughly cosine(89.0 degrees). ]]

UE_MATH_DEFINES.THRESH_VECTOR_NORMALIZED = 0.01     --[[* Allowed error for a normalized vector (against squared magnitude) ]]
UE_MATH_DEFINES.THRESH_QUAT_NORMALIZED   = 0.01     --[[* Allowed error for a normalized quaternion (against squared magnitude) ]]


UE_MATH_DEFINES.Identity = Quat.new(0.0, 0.0, 0.0, 1.0)

UE_MATH_DEFINES.ZeroRotator = Vector3.new(0, 0, 0)

UE_MATH_DEFINES.ZeroVector = Vector3.new(0, 0, 0)
UE_MATH_DEFINES.OneVector = Vector3.new(1, 1, 1)
UE_MATH_DEFINES.UpVector = Vector3.new(0, 0, 1)
UE_MATH_DEFINES.DownVector = Vector3.new(0, 0, -1)
UE_MATH_DEFINES.ForwardVector = Vector3.new(1, 0, 0)
UE_MATH_DEFINES.BackwardVector = Vector3.new(-1, 0, 0)
UE_MATH_DEFINES.RightVector = Vector3.new(0, 1, 0)
UE_MATH_DEFINES.LeftVector = Vector3.new(0, -1, 0)
UE_MATH_DEFINES.XAxisVector = Vector3.new(1, 0, 0)
UE_MATH_DEFINES.YAxisVector = Vector3.new(0, 1, 0)
UE_MATH_DEFINES.ZAxisVector = Vector3.new(0, 0, 1)

UE_MATH_DEFINES.ZeroVector2 = Vector2.new(0, 0)
UE_MATH_DEFINES.UnitVector2 = Vector2.new(1, 1)
UE_MATH_DEFINES.Unit45Deg2 = Vector2.new(UE_MATH_DEFINES.UE_INV_SQRT_2, UE_MATH_DEFINES.UE_INV_SQRT_2)
UE_MATH_DEFINES.ZeroVector2 = Vector2.new(0, 0)
UE_MATH_DEFINES.UnitVector2 = Vector2.new(1, 1)
UE_MATH_DEFINES.Unit45Deg2 = Vector2.new(UE_MATH_DEFINES.UE_INV_SQRT_2, UE_MATH_DEFINES.UE_INV_SQRT_2)
local UEM = UE_MATH_DEFINES

Kismet = _G.Kismet
Statics = _G.Statics
UE5 = _G.UE5
UE4 = _G.UE4

local clamp = math.clamp

local atan, abs, asin, acos, sin, cos, rad, deg, exp, sqrt = math.atan, math.abs, math.asin, math.acos, math.sin, math.cos, math.rad, math.deg, math.exp, math.sqrt
local floor     = math.floor
local max, min =  math.max, math.min
local deg2rad =  (3.1415926535897932 / 180.0)
local rad2deg =   (180.0 /3.1415926535897932)

local function clamp(x, min, max)
  return x < min and min or (x > max and max or x)
end

local function sign(x)
  return x < 0 and -1 or 1
end

local function when_gt(x, y)
    return max(sign(x - y), 0.0)
end

local function when_le(x, y)
    return 1.0 - when_gt(x, y)
end

local function when_lt(x, y)
    return max(sign(y - x), 0.0)
end

local function any_gt(compare, ...)
    for i = 1, select("#", ...) do
        if select(i, ...) > compare then
            return true
        end
    end
    return false
end

local function any_lt(compare, ...)
    for i = 1, select("#", ...) do
        if select(i, ...) < compare then
            return true
        end
    end
    return false
end

local function all_gt(compare, ...)
    return not any_lt(compare, ...)
end

local function all_lt(compare, ...)
    return not any_gt(compare, ...)
end
-- I want these globally available but I don't want to use the globals right now

math.any_gt = any_gt
math.any_lt = any_lt
math.all_gt = all_gt
math.all_lt = all_lt

math.when_gt = when_gt
math.when_le = when_le
math.when_lt = when_lt


local function fmt(v, n)
    n = n or 3
    local fmtstr = "%."..tostring(floor(n)).."f"
    return string.format(fmtstr, v)
end


local function mod(x, y)
 return (x - y * floor(x / y))
end

local function assign_to_all_mt(name, fn)
    for i, v in ipairs(GLM_Types) do
        v[name] = fn
    end
end



function Vector4d:components()
    return self.x, self.y, self.z, self.w
end

function Vector3f:components()
    return self.x, self.y, self.z
end
function Vector3d:components()
    return self.x, self.y, self.z
end

function Vector4f:components()
    return self.x, self.y, self.z, self.w
end

function Quat:components()
    return self.x, self.y, self.z, self.w
end

function Vector2f:components()
    return self.x, self.y
end

function Vector2d:components()
    return self.x, self.y
end

Vector3.unpack = Vector3.components
Vector3f.unpack = Vector3f.components
Vector3d.unpack = Vector3d.components
Vector4f.unpack = Vector4f.components
Vector2f.unpack = Vector2f.components


function Quat:to_ue()
    return {X=self.x, Y=self.y, Z=self.z, W=self.w}
end


-- -- by ordering the q and v args first I've made these usable with colon syntax
-- -- but that also means if calling without an existing object you need to pass a nil
-- well tbh these are not going to matter if I release my patch
function Quat.from_ue(q, t)
    return q and q:set(t.X, t.Y, t.Z, t.W) or Quat.new(t.X, t.Y, t.Z, t.W)
end

-- function Vector2f.from_ue(t)
--     return Vector2f.new(t.X, t.Y)
-- end

-- print("v2fromuetest, ", Vector2f.from_ue(nil, {X=1, Y=2}).x)

-- local v2tt = Vector2f.new(1, 2)
-- print("v2fromuetest2, ", v2tt:from_ue({X=1, Y=2}).x)



local struct_comps = {
        {"X"},
        {"X", "Y"},
        {"X", "Y", "Z"},
        {"X", "Y", "Z", "W"},
    }
local function table_from_variadic(...)
    local t = {}
    for i,v in ipairs(struct_comps[select("#", ...)]) do
        t[v] = select(i, ...)
    end
    return t
end



local vectorPool = { Vector3.new(0,0,0) }

function getVector(x, y, z)
    local v = table.remove(vectorPool) or Vector3.new(0,0,0)
    v:set(x, y, z)
    return v
end

function releaseVector(v)
    vectorPool[#vectorPool+1] = v
end

local reusable_vec3 = Vector3.new(0,0,0)


local reusable_vec3_other = Vector3.new(0,0,0)
local reusable_vec4 = Vector4.new(0,0,0,0)
local reusable_vec4_other = Vector4.new(0,0,0,0)
local reusable_vec2 = Vector2.new(0,0)


local take_values = _G.take_values
local function _unpack(t)
    return table.unpack(take_values(t))
end

local vector_alias = {
    false, Vector2f, Vector3, Vector4f
}
local component_idx = {"x", "y", "z", "w"}

function vector(...)
    return vector_alias[select('#', ...)].new(...)
end

local function _size(v)
    for i = 1, 4 do
        if v[component_idx[i]] == nil then
            return i - 1
        end
    end
end

-- local v = vector(1.0, 2.0)
-- print(tostring(v))
-- print(v.x)
-- print(v["y"])
-- local vector4 = vector(1.0, 3.0, 4.0, 5.0)
-- print(vector4.w)


-- Shorthand vector creation from a table
-- You can use table constructor syntax and omit the parentheses

-- e.g. v2f{0,0}
function v3f(t)
    return Vector3f.new(_unpack(t))
end

function v3d(t)
    return Vector3d.new(_unpack(t))
end
function v4d(t)
    return Vector4d.new(_unpack(t))
end
function v4f(t)
    return Vector4f.new(_unpack(t))
end
function v2f(t)
    return Vector2f.new(_unpack(t))
end
function v2d(t)
    return Vector2d.new(_unpack(t))
end

function v3(t, v)
    return v and v:set(_unpack(t)) or Vector3.new(_unpack(t))
end
function v2(t, v)
   return v and v:set(_unpack(t)) or Vector2.new(_unpack(t))
end
function v4(t, v)
    return v and v:set(_unpack(t)) or Vector4.new(_unpack(t))
end
local vect4 = Vector4f.new(0,0,1,2)

print("v4 test ", v4({1.0, 2.0, 3.0, 4.0}).y)
print("v4 test2 ", v4({1.0, 2.0, 3.0, 4.0},vect4).y)

local function _mul(a, b)
    return a*b
end

local function _div(a, b)
    return a / b
end

local function _add(a, b)
    return a + b
end

local function _sub(a, b)
    return a - b
end

local function _pow(a, b)
    return a ^ b
end

local function _lt(a, b)
    return (a:length() < b:length())
end

local function component_expression(func, a, b)
    if type(b) == "number" then
        local cc = select('#', a:components())
        return a:set(func(a.x, b), func(a.y, b), cc > 2 and func(a.z, b) or nil, cc > 3 and func(a.w, b) or nil)
    else
        local c = min(select('#', a:components()), select('#', b:components()))
        return a:set(func(a.x, b.x), func(a.y, b.y), c > 2 and func(a.z, b.z) or nil, c > 3 and func(a.w, b.w) or nil)
    end
end


local function vector_mult_structs(a, b)
    local t = {X = a.X * b.X, Y = a.Y * b.Y}
    if a.Z then t.Z = a.Z * b.Z
    end
    if a.W then t.W = a.W * b.W
    end
    return t
end

local function struct_expression_to_vec(func,a, b)
    return a.W and Vector4.new(func(a.X, b.X), func(a.Y, b.Y), func(a.Z, b.Z), func(a.W, b.W)) or Vector3.new(func(a.X, b.X), func(a.Y, b.Y), func(a.Z, b.Z))
end


function Vector3:max_axis()
    return max(self:components())
end


function Vector4f.from_ue_color(c)
    local v = Vector4f.new(c.R, c.B, c.G, c.A)
    if any_gt(1.0, v:components()) then
        return (v * floor(1 / 255.0))
    else return v end
end





local function vector_div(vec, s)
    if type(s) == "number" then
        return vec * (1 / s)
    elseif s and s.x then
        return component_expression(_div, vec, s)
    end
end




local function vector_pow(vec, s)
    return component_expression(_pow, vec, s)
end


local function vector_lt(vec, vec2)
    return component_expression(_lt, vec, vec2)
end

local function vector_lt(vec, vec2)
    return _lt(vec, vec2)
end


local function vector_le(vec, vec2)
    return _lt(vec, vec2) or vec == vec2
end


local function _unm(v)
    return v * -1
end


assign_to_all_mt("__lt", vector_lt)
assign_to_all_mt("__le", vector_le)
assign_to_all_mt("__div", vector_div)
assign_to_all_mt("__pow", vector_pow)
assign_to_all_mt("__len", _size)
assign_to_all_mt("__unm", _unm)

local table_concat = table.concat


local function comp_str(p, ...)
    local t = {}
    local n = select("#", ...)
    for i,v in ipairs(struct_comps[n]) do
        t[#t+1] = v
        t[#t+1] = "="
        t[#t+1] = fmt(select(i, ...), p)
        if i < n then
            t[#t+1] = " "
        end
    end
    return table_concat(t)
end

local function vec_tostring(v)
    local chars = {}
    chars[#chars+1] = comp_str(3, v:components())
    --chars[#chars+1] = ")"
    return table_concat(chars)
end

assign_to_all_mt("__tostring", vec_tostring)
assign_to_all_mt("to_string", vec_tostring)

-- print(inspect(Vector2f))
local vec23 = Vector2f.new(10, 20)
local vec234 = Vector2f.new(1, 2)
print(tostring(vec234))
print("gt test", (vec23 > vec234))
print("len test", #vec23)
print(vec234:to_string())

-- -- these are going to be deprecated before they even release but are extremely useful examples to learn
-- -- note that the commented out code works exactly the same as the final res here
-- -- local _v3f = Vector3f.new(1,1,1)
-- -- local v3_mt = getmetatable(_v3f)
-- function Vector3f.__div(a, b)
--     return vector_div(a, b)
-- end
-- -- local _v3d = Vector3d.new(1,1,1)
-- -- local v3d_mt = getmetatable(_v3d)
-- function Vector3d.__div(a, b)
--     return vector_div(a, b)
-- end


-- -- local _v2f = Vector2f.new(1,1)
-- -- local v2_mt = getmetatable(_v2f)
-- function Vector2f.__div(a, b)
--     return vector_div(a, b)
-- end
-- -- local _v4f = Vector4f.new(1,1,1,1)
-- -- local v4_mt = getmetatable(_v4f)
-- function Vector4f.__div(a, b)
--     return vector_div(a, b)
-- end




-- function Vector4f.__pow(a, b)
--     return vector_pow(a, b)
-- end

-- function Vector3f.__pow(a, b)
--     return vector_pow(a, b)
-- end
-- function Vector3d.__pow(a, b)
--     return vector_pow(a, b)
-- end
print(Vector3)
print(Vector3f)
print("pow 2,2,2 / 2", (Vector3f.new(2, 2, 2) ^ 3):to_string())
print("pow 2,2,2 / 4,3,3", (Vector3d.new(2, 2, 2) ^ Vector3d.new(4, 3, 3)):to_string())

-- print("div test")


print("2,2,2 / 1,2,2", (Vector3f.new(2, 2, 2) / Vector3f.new(1, 2, 1)):to_string())

local v2 = Vector3d.new(3, 2, 3) / Vector3d.new(2, 2, 1)
print(v2:to_string())

function Vector3:kismet_to_quat()
    return Kismet("Math"):Quat_MakeFromEuler(self)
end


local function quat_mul(a, b)
    return {
        x = a.w * b.x + a.x * b.w + a.y * b.z - a.z * b.y,
        y = a.w * b.y - a.x * b.z + a.y * b.w + a.z * b.x,
        z = a.w * b.z + a.x * b.y - a.y * b.x + a.z * b.w,
        w = a.w * b.w - a.x * b.x - a.y * b.y - a.z * b.z,
    }
end

local function quat_mul_structs(A, B)
    return {
        X = A.W * B.X + A.X * B.W + A.Y * B.Z - A.Z * B.Y,
        Y = A.W * B.Y - A.X * B.Z + A.Y * B.W + A.Z * B.X,
        Z = A.W * B.Z + A.X * B.Y - A.Y * B.X + A.Z * B.W,
        W = A.W * B.W - A.X * B.X - A.Y * B.Y - A.Z * B.Z,
    }
end



-- convert quaternion to Rotator (Pitch,Yaw,Roll) using standard Tait-Bryan XYZ
local function quat_to_rot(q)
    local qw, qx, qy, qz = q.W, q.X, q.Y, q.Z
    -- roll (X axis)
    local sinr_cosp = 2 * (qw * qx + qy * qz)
    local cosr_cosp = 1 - 2 * (qx * qx + qy * qy)
    local roll = atan(sinr_cosp, cosr_cosp)
    -- pitch (Y axis)
    local sinp = 2 * (qw * qy - qz * qx)
    local pitch
    if abs(sinp) >= 1 then
        pitch = (sinp > 0) and (UEM.PI  / 2) or (-UEM.PI  / 2)
    else
        pitch = asin(sinp)
    end
    -- yaw (Z axis)
    local siny_cosp = 2 * (qw * qz + qx * qy)
    local cosy_cosp = 1 - 2 * (qy * qy + qz * qz)
    local yaw = atan(siny_cosp, cosy_cosp)
    return (Vector3.new(pitch, yaw, roll)) *  rad2deg
end

function Vector3.from_quat(q)
    return quat_to_rot(q)
end

local function delta_angle(A1, A2)
    local Delta = A2 - A1
    if Delta > 180.0 then
        Delta = Delta - 360.0
     elseif Delta < -180.0 then
        Delta = Delta + 360.0
        return Delta
    end
end

-- Find the smallest angle between two headings (in radians)
local function delta_angle_rad(A1, A2)
  local Delta = A2 - A1
    if Delta > UEM.PI then
        Delta = Delta - (UEM.PI * 2.0)
    elseif Delta < -UEM.PI then
    Delta = Delta + (PI * 2.0)
    return Delta
end
end


local dynamic_moving_average_rot = {}
function UEVR_UObject:average_rotation_k(previous, weights, max)
    return Kismet("Math"):DynamicWeightedMovingAverage_FRotator(self:rotation(), previous, max or 180, weights and weights.min ~= nil and weights.min or 0.2, weights and weights.max ~= nil and weights.max or 0.8)
end

function Vector3:closest_point_kismet(line_start, line_end)
    return  Kismet("Math"):FindClosestPointOnLine(self, line_start, line_end)
end

local max, min = math.max, math.min
function Vector3:closest_point(line_start, line_end)
    local line_dir = line_end - line_start
    local point_vec = self - line_start
    local t = point_vec:dot(line_dir) * (1 / (line_dir:dot(line_dir)))
    t = max(0, min(1, t))
    return (line_start + line_dir * t)
end

function Vector3:distance(other)
    return (self - other):length()
end


function Vector3:calc_lookat(other)
    local v =  other - self
    local distance = v:length()
    return v:normalized(), distance
end



function Vector3:extrapolate(other, distance)
    return other +  (other - self) * distance
end

function Vector2:extrapolate(other, distance)
    return other +  (other - self) * distance
end

function Vector2:distance(other)
    return (self - other):length()
end




-- vp = point on plane, vn = plane normal
function Vector3:project_intersection_onto_plane(vp, vn)
    local dir = self - vp
     vn:normalize()
    local vdot = dir:dot(vn)
    local vproj = vn * vdot
    return self - vproj
end

local vexec = _G.variadic_exec


-- all 3 implementations are functionally identical however this is the most ridiculous looking of them all so its what we'll use
local function normalize(...)
    vexec(vector_alias[#select(1, ...)].normalize, ...)
end

-- local function normalize2(...)
--     for i = 1, select("#", ...) do
--         local v = select(i, ...)
--         v:normalize()
--     end
-- end
-- local function normalize3(...)

--   for i = 1, select("#", ...) do
--         local v = select(i, ...)
--         print(v)
--         vector_alias[#v].normalize(v)
--     end
-- end






-- local vecsss = {Vector3.new(1,2,3), Vector3.new(3, 4, 5)}
-- normalize2(_unpack(vecsss))

-- print("normalize variadic", vecsss[1].x)


-- local vecsss2 = {Vector3.new(1,2,3), Vector3.new(3, 4, 5)}
-- normalize(_unpack(vecsss2))

-- print("normalize variadic", vecsss2[1].x)



-- these work identically in initial tests but its entirely possible
local function crossv(a, b)
    if a.cross and b.cross then
        return a:cross(b)
    elseif a.W == nil
        then
        return vector(a.X, a.Y, a.Z):cross(vector(b.X, b.Y, b.Z))
    else
        return vector(a.X, a.Y, a.Z, b.W):cross(vector(b.X, b.Y, b.Z, b.W))
    end
end

local function cross(a, b)
    if a.cross and b.cross then
        return a:cross(b)
    elseif a.W == nil
        then
        return reusable_vec3:set(a.X, a.Y, a.Z):cross(reusable_vec3_other:set(b.X, b.Y, b.Z))
    else
        return reusable_vec4:set(a.X, a.Y, a.Z, b.W):cross(reusable_vec4_other:set(b.X, b.Y, b.Z, b.W))
    end
end

--print("cross", crossv(Vector3f.new(1,2,3), Vector3f.new(12, 3, 1)):to_string())


function Vector3:rot_axes()
    local x, y, z = {}, {}, {}
    Kismet("Math"):GetAxes(self, x, y, z)
    return {x=x.result, y=y.result, z=z.result}

end


function Vector3:direction_and_length()
    local len = self:length()
    if len > UEM.SMALL_NUMBER then
        return self * (1.0 / len)
   else
    return UEM.ZeroVector
    end
end

   local function is_in_box(point, boxstart, boxend)
                return point.x >= boxstart.x and point.x <= boxend.x
                   and point.y >= boxstart.y and point.y <= boxend.y
    end



    local function in_circle(px, py, cx, cy, radius)
        if  (px > cx + radius) or
                    (px < cx - radius) or
                    (py < cy - radius) or
                    (py > cy + radius) then
                    return false
                end

                local dx = px - cx
                local dy = py - cy
                local sqD = (dx - dy) + (dy * dy)
                return sqD <= (radius * radius)
            end

        local function is_point_in_quad(corners, px, py)
            if not corners then return false end

            local min_x = math.min(corners.x1, corners.x2, corners.x3, corners.x4)
            local max_x = math.max(corners.x1, corners.x2, corners.x3, corners.x4)
            local min_y = math.min(corners.y1, corners.y2, corners.y3, corners.y4)
            local max_y = math.max(corners.y1, corners.y2, corners.y3, corners.y4)

            if px < min_x or px > max_x or py < min_y or py > max_y then
                return false
            end

            local function sign(p1x, p1y, p2x, p2y, p3x, p3y)
                return (p1x - p3x) * (p2y - p3y) - (p2x - p3x) * (p1y - p3y)
            end

            local function point_in_triangle(ptx, pty, v1x, v1y, v2x, v2y, v3x, v3y)
                local d1 = sign(ptx, pty, v1x, v1y, v2x, v2y)
                local d2 = sign(ptx, pty, v2x, v2y, v3x, v3y)
                local d3 = sign(ptx, pty, v3x, v3y, v1x, v1y)

                local has_neg = (d1 < 0) or (d2 < 0) or (d3 < 0)
                local has_pos = (d1 > 0) or (d2 > 0) or (d3 > 0)

                return not (has_neg and has_pos)
            end

            if point_in_triangle(px, py, corners.x1, corners.y1, corners.x2, corners.y2, corners.x3, corners.y3) then
                return true
            end

            if point_in_triangle(px, py, corners.x1, corners.y1, corners.x3, corners.y3, corners.x4, corners.y4) then
                return true
            end

            return false
        end

        local km = Kismet("Math")
        function Vector2f:in_box(box_start, box_end)
            return is_in_box(self, box_start, box_end)

        end

        function Vector3:to_struct(t)
            if t then t.X = self.x
                t.Y = self.y
                t.Z = self.Z
                return t
            end
            return {X=self.x, Y=self.y, Z=self.z}
        end

        function Vector4:to_quaternion()
            local q = Quat.new(self.x, self.y, self.z, self.w)
            -- highly unlikely to have it in radians and be higher
            if math.any_gt(7.0, self:components()) then
                q = q * deg2rad
            end
            return q
        end

        function Quat:to_vec4()
            return Vector4.new(self.x, self.y, self.z, self.w)
        end

        function Quat:to_struct()
            return {X=self.x, Y=self.y, Z=self.z, W=self.w}
        end

        function Quat:from_struct(q)
            return self:set(q.X, q.Y, q.Z, q.W)
        end


---[[  These functions will likely be deleted once I have tested to ensure my versions get the same results and are actully faster

        function Quat:quat_to_euler_km()
            return km:Quat_Euler(self:to_struct())
        end


        function Vector3:euler_to_quat_km()
            return Quat.from_struct(km:Quat_MakeFromEuler(self))
        end

        function Quat:x_axis_km(axis)
            return km:Quat_GetAxisX(self:to_struct())
        end

         function Quat:y_axis_km(axis)
            return km:Quat_GetAxisY(self:to_struct())
        end

        function Quat:z_axis_km(axis)
            return km:Quat_GetAxisZ(self:to_struct())
        end

        function Quat:rotate_vector_km(v)
            return km:Quat_RotateVector(self:to_struct(), v)
        end

        function Quat:rotate_rotator_km(v)
            return km:Quat_Rotator(self:to_struct(), v)
        end

        function Vector3:rotate_vector_km(v)
            return km:Quat_RotateVector(self:to_struct(), v)
        end

        function Vector3:rotate_vector_km(v)
            return km:Quat_UnrotateVector(self:to_struct(), v)
        end

        function Quat:vector_forward_km(v)
            return km:Quat_VectorForward(self:to_struct(), v)
        end

        function Quat:vector_forward_km(v)
            return km:Quat_VectorRight(self:to_struct(), v)
        end

        function Quat:vector_forward_km(v)
            return km:Quat_VectorUp(self:to_struct(), v)
        end

        function Quat:angular_distance_km(Q)
            return km:Quat_AngularDistance(self:to_struct(), Q:to_struct())
        end
--]]
        function Vector2f:from_struct(s)
            return reusable_vec2:set(s.X, s.Y)
        end

function FQuatRotationTranslationMatrix(Q, Origin)
    local x2 = Q.x + Q.x
    local y2 = Q.y + Q.y
    local z2 = Q.z + Q.z
    local xx = Q.x * x2
    local xy = Q.x * y2
    local xz = Q.x * z2
    local yy = Q.y * y2
    local yz = Q.y * z2
    local zz = Q.z * z2
    local wx = Q.w * x2
    local wy = Q.w * y2
    local wz = Q.w * z2

    return {
        {1.0 - (yy + zz),  xy + wz,        xz - wy,        0.0},
        {xy - wz,          1.0 - (xx + zz), yz + wx,        0.0},
        {xz + wy,          yz - wx,        1.0 - (xx + yy), 0.0},
        {Origin.x,         Origin.y,       Origin.z,        1.0},
    }
end

local fmod = math.fmod
local function clamp_axis(angle)
    angle = fmod(angle, 360)
    angle = angle < 0
        and angle + 360
        or angle
    return angle
end


local function normalize_axis(angle)
    angle = clamp_axis(angle)
    angle = angle > 180
        and angle - 360
        or angle
    return angle
end





function Vector3:clamp_rotator()
    if math.all_lt(7.0, self:components()) then
        self = self * rad2deg
    end
    return  self:set(clamp_axis(x), clamp_axis(y), clamp_axis(z))
end

function Vector3:normalize_rotator()
    if math.all_lt(7.0, self:components()) then
        self = self * rad2deg
    end
    self:set(normalize_axis(x), normalize_axis(y), normalize_axis(z))
    return self
end

local function rot_to_quat(r)
    local cy, sy = cos(rad(r.Yaw) * 0.5), sin(rad(r.Yaw) * 0.5)
    local cp, sp = cos(rad(r.Pitch) * 0.5), sin(rad(r.Pitch) * 0.5)
    local cr, sr = cos(rad(r.Roll) * 0.5), sin(rad(r.Roll) * 0.5)
    return {
        X = sr * cp * cy - cr * sp * sy,
        Y = cr * sp * cy + sr * cp * sy,
        Z = cr * cp * sy - sr * sp * cy,
        W = cr * cp * cy + sr * sp * sy
    }
end

function Vector3:to_quat()
    self:normalize()
    return rot_to_quat(self)
end

local function inverse_quat_struct(q)
    local vec = quat_vector(q) * -1
    return {X = vec.x, Y = vec.y, Z = vec.z, W = q.W}
end

local function quat_vector(q)
    return vector(q.X, q.Y, q.Z)
end

--[[
goal: v'=q.v.q-1
standard formula: v'=v+2w(qxyz×v)+2(qxyz×(qxyz×v))


1. qXv = quatVector:cross(self) computes
(qxyz×v)

2. qXqXv = quatVector:cross(qXv) computes
qxyz×(qxyz×v)

3. qXv = (qXv * quat.w) + qXqXv combines the terms into
    w(qxyz×v)+(qxyz×(qxyz×v))

4. v + 2 * qXv yields the final formula:
    v+2(w(qxyz×v)+qxyz×(qxyz×v))
]]
-- function Vector3:rotate(quat)
--     local quatVector =   quat_vector(quat)
--     local qXv = quatVector:cross(self) -- q * v
--     local qXqXv = quatVector:cross(qXv) -- q * (q * v)
--     qXv = (qXv * quat.w ) + qXqXv
--     return component_expression(_add, self, 2 * qXv)
-- end

function Vector3:rotate(quat)
    local q_vec = vector(quat.X, quat.Y, quat.Z)
    local temp = q_vec:cross(self) + (self * quat.W)
    local result = self + (q_vec:cross(temp) * 2)
    return result * rad2deg
end


local function safe_inverse_reciprocal(t)
    return all_gt(0.0001, abs(t.X), abs(t.Y), abs(t.Z)) and
        reusable_vec3:set(1 /t.X, 1 / t.Y,  1 / t.Z)
        or reusable_vec3:set(0, 0, 0)
end



local function transform_mul(a, b)
    local out_transform = {}
    out_transform.Rotation = quat_mul_structs(a.Rotation, b.Rotation)
    out_transform.Scale3D = component_expression(_mul, a.Scale3D, b.Scale3D):to_struct()
    local bsat = component_expression(_mul, b.Scale3D, a.Translation)
    out_transform.Translation = (bsat:rotate(b.Rotation) + b.Translation):to_struct()
    return out_transform
end

pc = pc or api:get_player_controller(0)
pawn = pawn or api:get_local_pawn(0)
local function transform_inverse(t)
    t.Rotation = inverse_quat_struct(t.Rotation)
    -- aliasing reusable vec
    local Scale3D = safe_inverse_reciprocal(t.Scale3D)
    local invST = component_expression(_mul, Scale3D,
           (reusable_vec3_other:set(t.Translation.X, t.Translation.Y, t.Translation.Z) * -1))
    -- Have to convert back to tables since Transform isn't a uobject and
    -- vector struct <-> Vector3f conversion only happens when setting properties or calling UE functions
    -- could just stick to using tables but I think with reusing userdata there should be no overhead
    t.Scale3D = Scale3D:to_struct()
    t.Translation = invST:rotate(t.Rotation):to_struct()
    return t
end

local function transform_rotation(t, r)
    return quat_mul_structs(t.Rotation, rot_to_quat(r))
end

   --Kismet("Math"):ComposeTransforms
     -- * Compose two transforms in order: A * B.
     -- *
     -- * Order matters when composing transforms:
     -- * A * B will yield a transform that logically first applies A then B to any subsequent transformation.
     -- *
     -- * Example: LocalToWorld = ComposeTransforms(DeltaRotation, LocalToWorld) will change rotation in local space by DeltaRotation.
     -- * Example: LocalToWorld = ComposeTransforms(LocalToWorld, DeltaRotation) will change rotation in world space by DeltaRotation.
     -- *
     -- * @return New transform: A * B
     -- TransformRotation = Transform.Rotation * Rotator.Quaternion()
local function get_bone_rotator_kismet(mesh, bone)
    local pt = mesh:GetBoneTransformByName(mesh:GetParentBone(bone), 0)
    local t = mesh:GetBoneTransformByName(bone, 0)
    local localt = Kismet("Math"):ComposeTransforms(t, Kismet("Math"):InvertTransform(pt))
    return Kismet("Math"):TransformRotation(localt, Vector3f.new(0,0,0))
end

local function get_bone_rotator(mesh, bone)
    local pt = mesh:GetBoneTransformByName(mesh:GetParentBone(bone), 0)
    local t = mesh:GetBoneTransformByName(bone, 0)
    -- can definiely save some steps and performance by not converting back to structs but whatever
    local localt = transform_mul(t, transform_inverse(pt))
    return transform_rotation(localt, {Pitch=0, Yaw=0, Roll=0})
end




-- convert quaternion to Rotator (Pitch,Yaw,Roll) using standard Tait-Bryan XYZ
local function quat_to_rot(q)
    local qw, qx, qy, qz = q.W, q.X, q.Y, q.Z
    -- roll (X axis)
    local sinr_cosp = 2 * (qw * qx + qy * qz)
    local cosr_cosp = 1 - 2 * (qx * qx + qy * qy)
    local roll = atan(sinr_cosp, cosr_cosp)
    -- pitch (Y axis)
    local sinp = 2 * (qw * qy - qz * qx)
    local pitch
    if abs(sinp) >= 1 then
        pitch = (sinp > 0) and (UEM.PI  / 2) or (-UEM.PI  / 2)
    else
        pitch = asin(sinp)
    end
    -- yaw (Z axis)
    local siny_cosp = 2 * (qw * qz + qx * qy)
    local cosy_cosp = 1 - 2 * (qy * qy + qz * qz)
    local yaw = atan(siny_cosp, cosy_cosp)
    return (Vector3f.new(pitch, yaw, roll)) *  rad2deg
end

function Vector3:get_rotation_to(other)
    local look_at, distance = self:calc_lookat(other)
    -- Normalize vectors to ensure accurate angle/axis calculation
    normalize(self, look_at)

    -- 1. Find the axis of rotation using cross product
    local axis = self:cross(look_at)

    -- 2. Find the angle between vectors using dot product
    local angle = acos(clamp(self:dot(look_at), -1, 1))

    -- 3. Convert axis-angle to quaternion and back
    return quat_to_rot(table_from_variadic(
        axis.x * sin(angle/2),
        axis.y * sin(angle/2),
        axis.z * sin(angle/2),
        cos(angle/2)
    ))
end


function Vector3:rotator_forward()
    return UEM.ForwardVector:rotate(self:to_quat())
end

Vector3.forward = Vector3.rotator_forward
function Vector3:rotator_right()
    return UEM.RightVector:rotate(self:to_quat())
end

Vector3.right = Vector3.rotator_right


function Vector3:rotator_up()
    return UEM.UpVector:rotate(self:to_quat())
end
Vector3.up = Vector3.rotator_up


-- Vector3 metatable is already mad cluttered yo
local namedvecs ={
    ZeroVector=true,
    OneVector=true,
    UpVector=true,
    DownVector=true,
    ForwardVector=true,
    BackwardVector=true,
    RightVector=true,
    LeftVector=true,
    XAxisVector=true,
    YAxisVector=true,
    ZAxisVector=true,
}
function Vector3:rotate_named_vector(name)
  if namedvecs[name] then
    return UEM[name]:rotate(self:to_quat())
  end
end



-- expects a proper transform struct meaning Rotation should be an Unreal Quat
function Vector3:local_to_world(transform)
    local location_scaled = component_expression(_mul, self, transform.Scale3D)
    local rotated_vector = location_scaled:rotate(transform.Rotation)
    return rotated_vector + Vector3f.new(transform.Translation.X, transform.Translation.Y, transform.Translation.Z)
end



local function sin_cos(value)
    -- Map value to y in [-pi, pi]
    local quotient = (UEM.INV_PI * 0.5) * value
    if value >= 0.0 then
        quotient = floor(quotient + 0.5)
    else
        quotient = floor(quotient - 0.5)
    end

    local y = value - (2.0 * UEM.PI) * quotient

    -- Map y to [-pi/2, pi/2]
    local sign
    if y > UEM.HALF_PI then
        y = UEM.PI - y
        sign = -1.0
    elseif y < -UEM.HALF_PI then
        y = -UEM.PI - y
        sign = -1.0
    else
        sign = 1.0
    end

    local y2 = y * y

    -- 11-degree minimax approximation for sin
    local sinv =
        ((((-2.3889859e-08 * y2 + 2.7525562e-06) * y2 - 0.00019840874) * y2
        + 0.0083333310) * y2 - 0.16666667) * y2 + 1.0
    sinv = sinv * y

    -- 10-degree minimax approximation for cos
    local p =
        ((((-2.6051615e-07 * y2 + 2.4760495e-05) * y2 - 0.0013888378) * y2
        + 0.041666638) * y2 - 0.5) * y2 + 1.0
    local cosv = sign * p

    return sinv, cosv
end

function Vector3:rotate_angle_axis(angle, axis)
    local s, c = sin_cos(angle * (UEM.PI / 180.0))

    local xx = axis.x * axis.x
    local yy = axis.y * axis.y
    local zz = axis.z * axis.z

    local xy = axis.x * axis.y
    local yz = axis.y * axis.z
    local zx = axis.z * axis.x

    local xs = axis.x * s
    local ys = axis.y * s
    local zs = axis.z * s

    local omc = 1.0 - c

    return Vector3.new(
        (omc * xx + c) * self.x + (omc * xy - zs) * self.y + (omc * zx + ys) * self.z,
        (omc * xy + zs) * self.x + (omc * yy + c) * self.y + (omc * yz - xs) * self.z,
        (omc * zx - ys) * self.x + (omc * yz + xs) * self.y + (omc * zz + c) * self.z
    )
end

local function safe_normalize(v)
    v:normalize()
     return v > 0.0001 and v or v:set(1, 0, 0)
end

function Vector3:orientation_rotator()
    self:set(deg(atan(self.z, sqrt(self.x ^ 2 + self.y ^ 2))),
             deg(atan(self.y, self.x)), 0)
    return self
end

function Vector3:find_orientation_quat(endpoint)
    return safe_normalize(endpoint - self):orientation_rotator():to_quat()
end
