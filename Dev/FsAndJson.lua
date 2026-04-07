
-- literally just a pcall wrapper to avoid issues with loading bad jsons
local json_cache = {}
function json.safe_read(filepath, cache)
    if fs.exists(filepath) then 
        return json.load_file(file_path) 
    end
end


local old_json_dump_file = json.dump_file
-- convert anything we can to string so you dont end up with a file full of nulls
function json.safe_dump(filepath, tbl)
    local t = {}
    for k, v in orderedPairs(tbl) do
        local _k = (type(k) == "number" or type(k) == "string") and k or (k.to_string and k:to_string())
        t[_k] = type(v) == "string" and v or v.to_string and v:to_string()
    end
    json.dump_file(filepath, t, 4)
end


local oldjsonloadfile = json.load_file
local bad_files = {}
function json.load_file(filepath)
    if bad_files[filepath] ~= nil and os.time() - bad_files[filepath] < 10 then
        return nil 
    end

    local s,r = pcall(function()
        local t = oldjsonloadfile(filepath)
        if t ~= nil then 
            return t 
        end
    end)
    if s then 
        return r
    else
        print("Tried to read from bad file " ..filepath)
        bad_files[filepath] = os.time()
    end
end



-- FS extensions (fs itself being a custom table praydog provided)
-- These are mainly just string functions and may be redundant at times
-- The purpose is mainly to enhance readability and clarify you are working with files
-- It may also become confusing if you use colon syntax on path strings and then want to use
-- io functions to read files which also use colon syntax

fs.separator = "\\"


-- a little bit slow but the safest possible test since it actually opens the file
function fs.exists(filepath)
    local success, result = pcall(function()
        local f = assert(io.open(filepath, "rb"))
        local t = f:read("*l")
        f:close()
        return t ~= nil
    end)
    if success then return result end
end


-- just checks if there's an extension, use fs.exists for higher accuracy
function fs.isfile(path)
    return path:match("%.%w+$") ~= nil
end

-- get all parts
function fs.split(path)
    local dir, filename, extension = string.match(path, "(.-)([^/\\]-([^./\\]*))$")
    return dir, filename, extension
end

-- get everything before the last directory separator
function fs.dirname(path)
    local dir = path:match("(.+)" .. fs.separator .. "[^" .. fs.separator .. "]*$")
    if dir then
        return dir:sub(1, #dir - 1)
    else
        return "."
    end
end

-- filename + ext
function fs.basename(path)
    local name = path:match("[^" .. fs.separator .. "]*$")
    return name
end

-- equivalent to c++ fs:stem, i.e. returns basename without extension
function fs.stem(path)
    return fs.basename(path):split(".")[1]
end


function fs.find_in_folder(folder, ext)
    local t = {}
    -- remove . from extensions since it needs to be passed before the *
    if (ext:startswith(".") and not ext:startswith(".*")) then ext = ext:sub(2, #ext) end
    for idx, val in ipairs(fs.glob(folder..[[\\.*]]..ext)) do
        table.insert(t, val)
    end
    return t
end

function fs.load_data_dir(exts)
    local data_dir = fs.glob("*.txt")
    extend_table(data_dir, fs.glob("*.json"))
    return data_dir
end

function fs.user_dir()
    if Kismet and Kismet("System") then
        return Kismet("System"):GetPlatformUserDir()
    end
end



