```lua


local function base_types(coreuobjecttype)
     return  api:find_uobject("Class /Script/CoreUObject."..coreuobjecttype)
end
local all_classes, all_structs, all_func, all_script_struct, all_enum
local base_class, base_struct, base_script_struct, base_func, base_enum

function UniqueShortNames()

    local s,r = pcall(function()
        local t = json.load_file("class_short_names.json")
        if #t > 0 then return t end
    end)
    if s then return r end
    base_class = base_class or base_types("Class")
    all_classes = base_class:get_objects_matching(false)
    local short_names = {}
    for i, v in ipairs(all_classes) do
        if v.get_class and v:get_class() == base_class then
            local short_name = v:get_fname():to_string()
            local full_name = v:get_full_name()
            if short_names[short_name] ~= nil
                then

               log("Duplicate short name "..short_name.." will be "..v:get_outer():get_short_name().."."..short_name)
                    short_name = v:get_outer():get_short_name().."."..short_name
            end
            short_names[short_name] = full_name
        end
    end
    json.dump_file("class_short_names.json", short_names, 4)
    return short_names
end

 local _cache = setmetatable({}, {__mode = "v"})
function get(input)
    if not (type(input) == "string") then
            if type(input) == "number" then
                local temp = api:to_uobject(input)
                if temp ~= nil then
                    return temp
                end
            elseif type(input) == "userdata" then
            return input
            elseif input == nil then error("nil input")
        end
    end
    short_names = short_names or UniqueShortNames()
    if short_names and short_names[input] ~= nil then input = short_names[input]
    elseif input:sub(1, 5) ~= "Class" and input:sub(1, 12) ~= "ScriptStruct" then
        local engine_input =  "Class /Script/Engine.".. input
        if  _cache[engine_input] ~= nil and UEVR_UObjectHook.exists( _cache[engine_input]) then
            return  _cache[engine_input]
        else
            local temp = uevr.api:find_uobject(engine_input)
            if temp ~= nil and UEVR_UObjectHook.exists(temp) then
                _cache[engine_input] = temp
                return _cache[engine_input]
            end
        end
    end
    if _cache[input] ~= nil and UEVR_UObjectHook.exists( _cache[input])  then
       return _cache[input]
    else
        local temp = uevr.api:find_uobject(input)
          _cache[input] = UEVR_UObjectHook.exists(temp) and temp or nil
    end
   return _cache[input]
end
function M.GetActorFromHitResult(HitResult, actor_data)
    if HitResult == nil then
        return nil
    end
    local t = M.BreakHitResult(HitResult)
    return t.HitActor or nil
end

function M.DumpHitResult(hitresult, tojson)
    local results = M.BreakHitResult(hitresult)

 local text = {}
    for k, v in pairs(results) do
        text[k] = v.to_string and v:to_string() or tostring(v)
    end
    if tojson then json.dump_file("hitresults\\" .. tostring(os.time()) .. ".json", text, 4) end
    return text
end




local function is_out_param(func, prop)
    return func:find_property(prop):is_out_param()
end


local function get_param_names(func)
    local params = func:as_function():get_child_properties()
    local param_names = {}
    while params ~= nil do
        local p = params:get_fname():to_string()
        table.insert(param_names, p)
        params = params:get_next()
    end
    return param_names
end

local function get_param_data(func)
    local param_names = M.get_param_names(func)
    local data = {}
    for i, name in ipairs(param_names) do
        data[name] = {}
        local fprop = func:find_property(name)
        if fprop.is_param and fprop:is_param() then
            data[name] = {
                is_out_param = fprop:is_out_param(),
                is_return_param = fprop:is_return_param(),
                is_reference_param = fprop:is_reference_param(),
            }
        end
    end
end



local function build_out_params(func)
    local params = func:as_function():get_child_properties()
    local out = {}
    local order = {}
    while params ~= nil do
        local p = params:get_fname():to_string()
            print(#order, p)
            local param_class = params:get_class()
            if func:as_struct():find_property(p):is_out_param() then
                out[p] = {}  -- dynamically create empty table
            end
            -- this is equivalent to table.insert but is more optimal
            order[#order+1] = p
        params = params:get_next()
    end
    return out, order
end
              
function string:find_first_of(include_cdo)
    return UEVR_UObjectHook.get_first_object_by_class(get(self), include_cdo)
end


function string:find_all_instances(include_cdo)
    return get(self):get_objects_matching(include_cdo)
end


-- this allows for version independent hitresult analysis 
function M.BreakHitResult(hitresult)
    Statics = _G.Statics or ("GameplayStatics"):find_first_of(true)
    local func = Statics.BreakHitResult
    local tbls = {}

     local tbls, order = build_out_params(func)
     --tbls.Hit = hitresult
    -- Collect arguments in order
    -- start with the hitresult already in the table

   local args = {}
   tbls["Hit"] = hitresult
    -- this is the same as table.insert, we cant just do args[i] since we have  to offset by 1
    -- for i, name in ipairs(order) do
    --     args[#args+1] = args[#args+1] or tbls[name]
    -- end
    for i, name in ipairs(order) do
        args[i] = tbls[name]
    end
    -- unpack the empty tables
    -- despite having no data in each table and
    -- despite table.unpack technically generating new values
    -- tbls still keeps references to each of them allowing us to retrieve the results
    Statics:BreakHitResult(table.unpack(args))

    -- Build results map
    -- This is simple here due to the function only taking out params
    -- but even if it didn't we would still know the order
    -- without the ordering steps we can get the data but we won't know which result goes where
    local results = { }
    for i = 2, #args do
        local name = order[i]
        results[name] =  tbls[name].result
    end
    if os.time() % 5 == 0 then
        local text = {}
        for k, v in pairs(results) do
            if v ~= nil then
                text[k] = can_index(v) and v.to_string and v:to_string() or tostring(v)
            end
        end
        json.dump_file("hitresults\\" .. tostring(os.time()) .. ".json", text, 4)
    end

    return results
end



```
