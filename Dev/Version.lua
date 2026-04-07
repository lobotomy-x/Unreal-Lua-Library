

local function Version()
    local text = Kismet("System"):GetEngineVersion()
    if text:contains("-") then
        text = text:split("-")[1]
    end
    local nums = text:split(".")
    local version = {
        major = tonumber(nums[1]),
        minor = tonumber(nums[2]),
        patch = tonumber(nums[3]),
    }

    return version
end


local UE_Version = Version()
UE5 = UE_Version.major == 5 or false
UE4 = UE_Version.major == 4 or false


UE_Version_Minor = tonumber(tostring(UE_Version.minor)..tostring(UE_Version.patch))
NEW_MESH_API = (UE5 and UE_Version_Minor >= 1) or false


Vector3 = UE5 and Vector3d or Vector3f
Vector4 = UE5 and Vector4d or Vector4f
Vector2 = UE5 and Vector2d or Vector2f

Quat = UE5 and Quaterniond or Quaternionf