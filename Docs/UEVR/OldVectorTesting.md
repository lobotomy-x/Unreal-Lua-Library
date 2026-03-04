There are many ways to represent a vector in our api. You could load the actual vector struct

local vector_c = api:find_uobject("ScriptStruct /Script/Engine.Vector")
local vec = StructObject.new(vec)

Do not do this. Its needlessly verbose and prone to error. UEVR allows automatically creating ScriptStructs from tables and vice versa. This is very useful and this is how you should interact with most plain old data (POD) structs, e.g. to get a reusable hitresult instead of using StructObject.new, either make a table with all the properties you need or even better pass an empty table to a function that returns a hitresult and literally just reuse it. However you should not do this with vectors, rotators, or quats. Instead use Vector2f, Vector3f, and Vector4f. These have direct bindings setup to the underlying values and are directly compatible as inputs for any function or properties taking UE Vectors or Rotators as well as ImGui functions.

UE5 made a major change in switching to double precision floats. To be accurate you should be using the VectorXd versions however in practice there isn't a huge issue with most transformations if you use the lower precision option. You could also probably be okay with using Vector3d even in ue4 games, it shouldn't cause you to lose any data.

However there is an easy fix available and if you use my API library you can use Vector2, Vector3, Vector4, or Quat anywhere and they will automatically be handled as doubles in UE5 and floats in UE4. This is done by checking the engine version with Kismet System Library and assigning these names as global aliases for the appropriate metatables.

This is far simpler than it probably sounds:

```lua
Vector3 = UE5 and Vector3d or Vector3f

```
This allows access to all the normal functions because its literally just a pointer to the same data structure.



if you're only modding a few games at most you may not have encountered this issue, but one small but very annoying issue with universal UE scripts is that some games will randomly have inconsistent case for the axes on rotators, e.g. roll instead of Roll. That seems easy enough to fix at first glance by just checking for "roll" or "Roll" but there's a problem, UEVR automatically renames it to Roll when reading from the game so you'll never actually get the wrong case to check (even though you can see it in the GUI) which means you would need to either fetch the base rotator scriptstruct class or make a function with exception handling and cache the result. Either way its pretty pointless when you can just use Vector3f(Pitch, Yaw, Roll)

There are also the UEVR_Vector, UEVR_Rotator, etc. types available. These are also able to receive game data and I believe you get VR device data as these types so its fine to use them but you should convert them to Vectors with :as_full_binding() or :cast_to_vector()

You can access vector components with x,y,z,w or X,Y,Z,W or Pitch,Yaw,Roll regardless of the underlying type. The one downside is that they don't support automatic conversion to tables so if dumping to json you will need to use a wrapper function

Compatibility aside, the biggest reason to use vectors is that they have math functions already set up with C++ bindings. Using custom lua functions is not only redundant but also slower if doing repeated calculations on a large number of objects. Arithmetic functions work exactly as you could hope, just keep in mind lhs and rhs matter with vector math


vector1 + vector2

vector1 - vector2

vector1 * scalar

I'm not sure if you can actually use division, as its not explicitly defined but since multiplication is only supported against a scalar you can just do

vector1 * (1 / scalar)



Several functions can take a self/this operator using a colon to invoke them
i.e. v:func() = Vector3f.func(this)

dotproduct = Vector3f.dot(vector1, vector2)
dotproduct = vector1:dot(vector2)

crossproduct = vector1:cross(vector2)

v1 = Vector3f.new(3, 0, 4)

v2 = v1:clone()

local v3 = v2:normalized() -- gives you a new vector

v3 == v1:normalize() -- modifies original



vlen = v1:length()

v2:set(0, 0)

vreflected = Vector3f.reflect(v1, v2:normalize())

vrefracted = Vector3f.refract(v1, v2:normalize(), eta)

blend = Vector3f.lerp(v1, v2, blendfactor)

local v2vec = Vector2f.new(0, 1)

local v4vec = v2vec:to_vec4()

local v3vec = v2vec:to_vec3()

v4vec == v3vec:to_vec4()


You can easily test these for yourself, here's a bit of sample code for testing the difference between normalize and normalized, just call test_vectors from a script table

local v1, v2, v3 = nil
local function tostring_vecXYZ(name, vec)
if vec == nil then return end
imgui.text(string.format("X: %.2f, Y: %.2f, Z: %.2f", vec.x, vec.y, vec.z))
end

local function test_vectors()
if imgui.collapsing_header("v1 = Vector3f.new(3, 0, 4)") then
v1 = Vector3f.new(3, 0, 4)
tostring_vecXYZ("v1", v1)
end


if imgui.collapsing_header("v2 = v1:clone()") then
v2 = v1:clone()
tostring_vecXYZ("v2", v2)
end

if imgui.collapsing_header("v3 = v2:normalized()") then
v3 = v2:normalized()
tostring_vecXYZ("v3", v3)
end

if imgui.collapsing_header("v1:normalize()") then
v1:normalize()
tostring_vecXYZ("v1", v1)
imgui.text("v3 == v1")
imgui.text(tostring(v3 == v1))

end
end

Note that if you want to do similar testing with imgui instead of printing to the console, collapsing header is a great choice as it automatically persists its open/closed state but won't evaluate anything until its opened

