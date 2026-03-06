a = "C:\\Users\\lbatv\\AppData\\Roaming\\UnrealVRMod\\Aion2\\config.txt"
local fs = {}
local separator = "\\"

function string:split(delimiter)
	local result = {}
	-- allow passing without args for python style split
	delimiter = delimiter or "."
	for match in self:gmatch("([^" .. delimiter .. "]+)") do
		table.insert(result, match)
	end
	return result
end


function fs.isfile(path)
 	return path:match("%.%w+$") ~= nil
end

function fs.split(path)
    local dir, filename, extension = string.match(path, "(.-)([^/\\]-([^./\\]*))$")
    return dir, filename, extension
end

function fs.dirname(path)
    -- Pattern: match everything up to the last separator (.*)
    -- and capture it (wrapped in parens). The [^..] part matches any character
    -- that is NOT a separator, ensuring we capture the path *up to* the file name.
    -- The trailing separator is included in the captured group.
    local dir = path:match("(.+)" .. separator .. "[^" .. separator .. "]*$")
    if dir then
        -- Return the directory part without the trailing separator
        return dir:sub(1, #dir - 1)
    else
        -- If no separator found, it might be the current directory or a root
        return "."
    end
end

function fs.basename(path)
    -- Pattern: match everything up to the last separator ([^..]*)
    -- then everything after it (.*$) and capture only the part after the separator.
    local name = path:match("[^" .. separator .. "]*$")
    return name
end

function fs.stem(path)
	return fs.basename(path):split(".")[1]
end


print(fs.isfile(a))
print(fs.dirname(a))
print(fs.split(a))
print(fs.basename(a))
print(fs.stem(a))


--[[
true
C:\Users\lbatv\AppData\Roaming\UnrealVRMod\Aion
C:\Users\lbatv\AppData\Roaming\UnrealVRMod\Aion2\	config.txt	txt
config.txt
config
]]