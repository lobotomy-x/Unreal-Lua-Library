-- The original table
local data = { a = 10, b = 20, ext = {} }

-- The metatable
local mt = {}
    -- __index handles reading missing keys
    mt.__index = function(table, key)
        for _, ex in ipairs(table.ext) do
            if type(ex) == "table" then
                if ex[key] then 
                    return ex[key]
                end
            end
        end
        return 0
        -- Return 0 for any missing key
    end
    -- -- __tostring customizes how the table is printed
    mt.__tostring = function(table)
        return "Data: a=" .. table.a .. ", b=" .. table.b
    end


-- Attach the metatable to the table
setmetatable(data, mt)
data.__mt = mt

local subdata =  class("subdata", data)
print(subdata)
-- function data.__mt.__len(table)
--      local i = 1
--      for k,v in pairs(table) do
--          i = i + 1
--      end
--      return i
--  end

-- print(data.a)     -- Output: 10
-- print(data.c)     -- Output: 0 (uses __index)
-- print(data)       -- Output: Data: a=10, b=20 (uses __tostring)
-- print(#data)
 local newfunc_chunk = [[
 return {
     d = 15,
     e = function(b)
         return 1+b
     end
 }
 ]]
 
 local newfunc_chunk2 = [[
    __mt.__len =  function(table)
          local i = 1
          for k,v in pairs(table) do
              i = i + 1
          end
          return i
      end
     return __mt
]]

-- adding new keys to a table via chunk
 local function test_chunk_load()
-- no custom env set therefore it will use current scripts env
  local chunk, error = load(newfunc_chunk)
  data.ext[#data.ext+1] = chunk()
  print(data.d)
  print(data)
  -- this has to be returned 
  -- and the outer scope object has to be set to this function
  -- or else the changes will
  -- only be present within the same function
  return data
 end
data = test_chunk_load()
print(data.d)
 -- Patching metatable by passing custom env with current metatable
 local function test_chunk_load2()
     -- literally anything you want available has to be passed
     -- even things like print
      local custom_env = {
          __mt = mt,
          pairs = pairs
          }
    local chunk, error = load(newfunc_chunk2, "Chunk", "t", custom_env)
    -- this does not need to return to affect the outer object
   setmetatable(data, chunk())
    print(#data)
end

test_chunk_load2()
print(#data)