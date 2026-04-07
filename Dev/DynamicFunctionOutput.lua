

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


function can_index(lua_object)
    local mt = getmetatable(lua_object)
    return (not mt and type(lua_object) == "table") or (mt and not not mt.__index)
end

function BreakHitResult(hitresult)
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


-- You DO NOT need to break a hitresult if you just want to use it for transforms
-- If you're just trying to move something quickly you can fire off a quick hitresult
function GetHitResultUnderCursor(inputs, _break)
    local hitresult = {}
    local hitResult = nil
    --pc:SetMouseLocation({X = get_resolution().x * 0.5, Y = get_resolution().y * 0.5})
    pc = pc or api:get_player_controller(0)
    if inputs == nil then
        inputs = 1
    end
    if type(inputs) == "string" then
        inputs = M.GetCollisionChannel(inputs)
    end
    if type(inputs) == "table" then
        if pc:GetHitResultUnderCursorForObjects(inputs, true, hitresult) then
            hitResult = hitresult.result
        end
    end

    if pc:GetHitResultUnderCursorByChannel(inputs, true, hitresult) then
        hitResult = hitresult.result
    end
    if hitResult ~= nil then
        -- this puts the responsibility on the caller to parse out the results which do include the hitresult itself
        if _break then
            --return Statics:check_output("BreakHitResult", {Hit =hitResult})
            return M.BreakHitResult(hitResult)
        else
            -- this gives the actual hitresult struct if you just need it for a transformation
            return hitResult
        end
    end
end




function  GetActorFromHitResult(HitResult, actor_data)
    if HitResult == nil then
        return nil
    end
    local t =  BreakHitResult(HitResult)
    return t.HitActor or nil
end


