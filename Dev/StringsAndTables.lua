local math_floor = math.floor
local math_ceil = math.ceil
local math_max = math.max
local math_min = math.min
local string_find = string.find
local string_gsub = string.gsub
local string_upper = string.upper
local string_sub = string.sub
local table_concat = table.concat
local table_insert = table.insert
local tonumber = tonumber
local tostring = tostring
local type = type
local math_random = math.random
local string_byte = string.byte
local string_char = string.char
local string_format = string.format
local string_len = string.len
local string_lower = string.lower


function LazyRequire(name)
    local mod
    return setmetatable({}, {
        __index = function(_, k)
            mod = _G.mod or _G.mod or require(name)
            if mod[k] then
            return mod[k]
        end
        end,
    })
end



api = uevr.api


function variadic_exec(fn, ...)
    for i = 1, select("#", ...) do
        local v = select(i, ...)
        fn(v)
    end
end


function is_array(_table)
    if _table and type(_table) == "table" and _table[1] ~= nil then return true end
end

function printf(...) print(string.format(...)) end
-- print(string.format("Hello %s, the value of key %s is %s", name, k, v))


-- char array
function string:to_table()
    local t = {}
    for char in self:gmatch(".") do
        t[#t + 1] = char
    end
    return t
end

-- ins = case insensitive
-- Main purpose is to allow optional case insensitive handling with a single call
function string:equals(str, ins)
    str = (type(str) == "string" and str) or (str.to_string and str:to_string()) or tostring(str)
    return (ins and self:lower() == str:lower()) or self == str
end


-- if you prefer function syntax over .. style concatenation
-- note that we can't modify strings in place without using a proxy table
-- that feature is desirable but not worth the effort
function string:append(str)
    str = (type(str) == "string" and str) or (str.to_string and str:to_string()) or tostring(str)
    return self..str
end


-- remove trailing/leading whitespace
function string:trim()
    return self:match("^%s*(.-)%s*$")
end



function string:patternescape()
  return self:gsub("[%(%)%.%%%+%-%*%?%[%]%^%$]", "%%%1")
end

-- remove all whitespace
function string:strip()
    local s = self:gsub("%s+", "")
    return s
end

function string:letters()
    local s = self:gsub("%A", "")
    return s
end

function string:digits()
    local s = self:gsub("%D", "")
    return s
end

string.numbers = string.digits

function string:chars()
    local s = self:gsub("%W", "")
    return s
end

-- split a string at an index, returns two values
function string:sliceat(index)
    return self:sub(1, index), self:sub(index, #self)
end

function string:patternescape()
  return self:gsub("[%(%)%.%%%+%-%*%?%[%]%^%$]", "%%%1")
end
function string:split(delimiter)
   local result = {}
    -- allow passing without args for python style split

    delimiter = delimiter or "."
    local pattern = "([^" .. delimiter:patternescape() .. "]+)"
    for match in self:gmatch(pattern) do
        result[#result + 1] = match
    end
    return result
end

function string:rsplit(delimiter)
    local splits = self:split(delimiter)
    if splits and #splits > 1 then return splits[#splits] end
    return self
end



-- removes _2147... (the uobjectarray index) from spawned objects
function string:trim_uobject()
    local result = self:gsub("_%d+$", "")
    return result
end

-- ins = case insensitive
function string:contains(subword, ins, start)
    return ((ins and self:lower() or self):find((ins and subword:lower() or subword), start or 1, true) ~= nil)
end

function string:empty()
    return #self == 0
end

function string:startswith(prefix, ins)
    return self:sub(1, #prefix):equals(prefix, ins)
    -- return (ins and self:lower() or self):sub(1, #prefix) == (ins and prefix:lower() or prefix)
end

function string:endswith(suffix, ins)
    return self:sub(- #suffix):equals(suffix, ins)
    -- return (ins and self:lower() or self):sub(-#suffix) == (ins and suffix:lower() or suffix)
end

function string:insert(pos, text)
    local p1, p2 = self:sliceat(pos)
    return p1 .. text .. p2
end

-- equivalent to python if _str_ in _list_
-- if partial then its equivalent to if [_str_ in li for li in _list_]
-- ins = case insensitive
-- inv = invert condition of partial, i.e. check if the string contains any list items. set these separately
-- only searches VALUES, use break_table and pass the keys if you want to search in keys
-- I think that makes more sense than making it available as a parameter, lmk if you disagree
-- -- returns true, key/index or false, nil
-- function string:is_in(list, partial, ins, inv)
--  for k, v in pairs(list) do
--      if inv then
--          if self:contains(v, ins) then return true, v end
--      end
--      if partial then
--          if v:contains(self, ins) then return true, v end
--      elseif self:equals(v, ins) then
--          return true, v
--      end
--  end
--  return false
-- end

function string:is_in(list, partial_match, ins)
  if is_array(list) then
    for i, v in ipairs(list) do
      if v:equals(self, ins) or (partial_match and v:contains(self, ins)) then
        return i
      end
    end
    return false
  else
      for k, v in orderedPairs(list) do
        if v:equals(self, ins) or (partial_match and v:contains(self, ins)) then
          return k
        end
      end
    return false
  end
end


function string:has_any(list, ins)
  for i, v in ipairs(list) do
    if self:contains(v, ins) then return v end
  end
  return false
end

-- not perfect by any means, but can handle UObject:get_address and the copy address GUI function in UEVR
function string:to_address()
    if self:match("^%w+$") ~= nil then
        if self:sub(1, 2) == "0x" then
            return tonumber(self:sub(3, #self), 16)
        elseif #self:letters() ~= 0 then
            return tonumber(self, 16)
        else
            return tonumber(self, 10)
        end
    end
    return nil
end

function string:camel_to_snake()
    return self:gsub("([a-z])([A-Z])", "%1_%2") -- This adds underscore before a capital letter after a lowercase letter
        :gsub("([A-Z])([A-Z][a-z])", "%1_%2") -- This handles cases like HTTPRequest -> HTTP_Request
        :lower()
end

-- huh I forgot I already had this whewn I wrote the fs version
function string:stem(keep_extension)
    local filename = self:match("[^/\\\\]+$")
    if keep_extension then return filename end
    local stem = filename:gsub("%.[^%.]+$", "")
    return stem
end


function find_in_table(term, tbl, ins, exact, skip)
    if not is_array(tbl) then
        local keys, values = break_table(tbl)
        return find_in_table(values) or find_in_table(keys)
    else
        for i, value in ipairs(tbl) do
            local v = (type(value) == "string" and value) or (value.to_string ~= nil and value:to_string()) or tostring(value)
            if (not v:equals(skip)) and (exact and v:equals(term, ins)) or v:contains(term, ins) then
                return v
            end
        end
    end
end

-- usage: call api:to_uobject(Address(input))
-- e.g. with imgui.input_text
function Address(data)
    if type(data) == "string" then
        return data:to_address()
    elseif
        type(data) == "number"
    -- reuse the string function since it already handles determining dec/hex
    then
        return (tostring(data)):to_address()
    else
        return (data.get_address and data:get_address()) or nil
    end
end

function to_hex_string(num)
    return string.format("0x%x", num)
end

local once = true


function __genOrderedIndex(t)
  local orderedIndex = t.__orderedIndex or {}
  t.__keys = t.__keys or {}
  t.__lookup = t.__lookup or {}
    -- ensure correct sorting for rotator to Vector3 handling
  -- idk why its like this but it is
  if #t == 3 and (t.pitch or t.Pitch) then
    return {"Pitch", "Yaw", "Roll"}
  end
  for key in pairs(t) do
      table.insert(orderedIndex, type(key) == "string" and key or tostring(key))
        t.__lookup[t[key]] = key
  end
  table.sort(orderedIndex)

  return orderedIndex
end


function find_ordered_key(tbl, key)
  local index = tbl.__keys and tbl.__keys[key]
  return index or nil
end


function ordered_lookup(tbl, value)
  local key = tbl.__lookup and tbl.__lookup[value]
  return key or nil
end



-- pairs does not maintain order. maybe you heard this and like me thought it was no big deal and only matters for storage
-- but its actually borderline unusable. we are fixing that
-- normally this will generate a hidden table with the ordered index based on alphabetical order
-- but you can instead provide a table with the correct order in the orderedPairs function
-- this is crucial for dynamic param-building functions like BreakhitResult which requires empty table values with string keys
function orderedNext(t, state)
  if not t then return end

    t.__lookup = t.__lookup or {}
  local key = (t.__ordered_index ~= nil and state == nil) and t.__ordered_index[1] or nil
  --print("orderedNext: state = "..tostring(state) )
  if state == nil and t.__ordered_index == nil then
    -- the first time, generate the index
    t.__ordered_index = t.__orderedIndex or __genOrderedIndex(t)
      if not t.__keys then t.__keys = {}
        for i = 1, #t.__ordered_index do
                t.__keys[t.__ordered_index[i]] = i
            end
        end
    key = t.__ordered_index[1]

  else
    -- fetch the next value
    for i = 1, #t.__ordered_index do
      if t.__ordered_index[i] == state then
        key = t.__ordered_index[i + 1]
      end
    end
  end

  if key and key ~= "__lookup" and key ~= "__keys" then
      if t[key] then
        t.__lookup[t[key]] = key
      end
    return key, t[key]
  end
    t.ordered_index = nil
  return
end


-- this is how you actually iterate an ordered table
-- if no orderedIndex exists yet we construct it on the first try
-- if this is an array we just call ipairs so everything works as expected
-- you can prebuild your orderedIndex, directly assign it, or pass it here
-- if you want to you can override pairs with orderedPairs in a local variable in your own script
function orderedPairs(t, orderedIndex)
      if is_array(t) then return
        ipairs(t)
      end
    if orderedIndex ~= nil then
    t.__orderedIndex = orderedIndex
    end
  return orderedNext, t, nil
end

-- basically python zip
-- takes two arrays already in correct order and splices them into an orderedTable
function build_ordered_table(keys, values)
  local t = {}
  t.__lookup = {}
  assert(is_array(keys) and is_array(values))
  for i = 1, #keys do
    t[keys[i]] = values[i]
    t.__keys[keys[i]] = i
    t.__lookup[values[i]] = keys[i]
  end
  t.__orderedIndex = keys
  return t
end

-- this is what I use most of the time
-- very straight forward and simple to use
function ordered_insert(tbl, new_key, new_value)
  tbl.__orderedIndex = tbl.__orderedIndex or {}
  tbl.__lookup = tbl.__lookup or {}
  tbl.__keys = tbl.__keys or {}
  local t = tbl.__orderedIndex
  -- only update insertion order if its new
  if tbl[new_key] == nil then
    table.insert(t, new_key)
    tbl.__keys[new_key] = #t
  end
  tbl[new_key] = new_value
  tbl.__lookup[new_value] = new_key
  return tbl
end

function get_n(tbl)
  if is_array(tbl) then return #tbl
  elseif tbl.__orderedIndex == nil then
      __genOrderedIndex(tbl)
  end
  return #(tbl.__orderedIndex)
end


function extend_table(tbl1, tbl2)
  if is_array(tbl1) and is_array(tbl2) then
    for idx, val in ipairs(tbl2) do
      table.insert(tbl1, val)
    end
  else
    for k, v in orderedPairs(tbl2) do
      if v ~= nil then
        tbl1[k] = v
      end
    end
  end
end


function combine_tables(tbl1, tbl2)
  if is_array(tbl1) and is_array(tbl2) then
    for idx, val in ipairs(tbl2) do
      table.insert(tbl1, val)
    end
    for i = #tbl2, 1, -1 do
      table.remove(tbl2, i)
    end
  else
    for k, v in orderedPairs(tbl2) do
      if v ~= nil then
        tbl1[k] = v
        tbl2[k] = nil
      end
    end
  end
  tbl2 = nil
end



-- split table into keys and values so you can iterate key names as an array
function break_table(_table)
    local keys, values = {}, {}
    for k, v in orderedPairs(_table) do
        table.insert(keys, k)
        table.insert(values, v)
    end
    return keys, values
end
-- split table into keys and values so you can iterate key names as an array
function take_values(_table)
    if is_array(_table) then return _table end
    local values = {}
    for k, v in orderedPairs(_table) do
        table.insert(values, v)
            end
    return values
end



function can_index(lua_object)
    local mt = getmetatable(lua_object)
    return (not mt and type(lua_object) == "table") or (mt and not not mt.__index)
end




