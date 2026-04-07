local t = {}
local once = true
local a = {}
function is_array(_table)
    if _table and type(_table) == "table" and _table[1] ~= nil then return true end
end

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

uevr.sdk.callbacks.on_frame(function()
   imgui.begin_window("env")


    local i = 1
    for k,v in orderedPairs(_ENV) do
      imgui.push_id(i)
      if imgui.tree_node(k) then
        a[i] = inspect(v)
        if imgui.button("dump##"..tostring(i)) then
            fs.write(k, a[i])
        end
        imgui.text(a[i])
        i = i + 1
        imgui.tree_pop()
      end
      imgui.pop_id()
    if once then fs.write("dump.txt", inspect(a)) once = false end
    end


    imgui.end_window()

        
end)