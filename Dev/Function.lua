
local _uobject =  UEVR_UObject
local _ustruct  =  UEVR_UStruct --    setmetatable({}, uevr_ustruct)
local _uclass   =  UEVR_UClass --    setmetatable({}, uevr_uclass)
local _ufunction = UEVR_UFunction --     setmetatable({}, uevr_ufunction)
local _ffield   =  UEVR_FField --    setmetatable({}, uevr_ffield)
local _fproperty = UEVR_FProperty --        setmetatable({}, uevr_fproperty)
local _uevr_types = {
     _uobject,
     _ustruct,
     _uclass,
     _ufunction,
     _ffield,
     _fproperty
}

-- Note that there may be some differences between the naming of these flags
-- and the names used by Epic. This list was retrieved from praydog's ufunction implementation
-- in the UEVR UESDK so the naming scheme is his own
local flags = {
    is_final=0x1,
    is_required_api=0x2,
    is_blueprint_authority_only=0x4,
    is_blueprint_cosmetic=0x8,
    is_net=0x40,
    is_net_reliable=0x80,
    is_net_request=0x100,
    is_exec=0x200,
    is_native=0x400,
    is_event=0x800,
    is_net_response=0x1000,
    is_static=0x2000,
    is_net_multicast=0x4000,
    is_ubergraph_function=0x8000,
    is_multicast_delegate=0x10000,
    is_public=0x20000,
    is_private=0x40000,
    is_protected=0x80000,
    is_delegate=0x100000,
    is_net_server=0x200000,
    has_out_params=0x400000,
    has_defaults=0x800000,
    is_net_client=0x1000000,
    is_dll_import=0x2000000,
    is_blueprint_callable=0x4000000,
    is_blueprint_event=0x8000000,
    is_blueprint_pure=0x10000000,
    is_editor_only=0x20000000,
    is_const=0x40000000,
    is_net_validate=0x80000000,
}

flags.__orderedIndex = {
"is_final",
"is_required_api",
"is_blueprint_authority_only",
"is_blueprint_cosmetic",
"is_net",
"is_net_reliable",
"is_net_request",
"is_exec",
"is_native",
"is_event",
"is_net_response",
"is_static",
"is_net_multicast",
"is_ubergraph_function",
"is_multicast_delegate",
"is_public",
"is_private",
"is_protected",
"is_delegate",
"is_net_server",
"has_out_params",
"has_defaults",
"is_net_client",
"is_dll_import",
"is_blueprint_callable",
"is_blueprint_event",
"is_blueprint_pure",
"is_editor_only",
"is_const",
"is_net_validate"
}


local function_flags = {
   is_final= {enabled = false, value = 0x1, tip = "Base Unreal Engine function, not overrideable by game devs. Irrelevant"},
   is_required_api= {enabled = false, value = 0x2, tip = "Base Unreal Engine function exported in the engine dll. Irrelevant"},
   is_blueprint_authority_only= {enabled = false, value = 0x4, tip = "Can only execute with network authority\n (server, dedicated server, or single-player game). Try removing if hooking"},
   is_blueprint_cosmetic= {enabled = false, value = 0x8,   tip = "This function is cosmetic and will not run on dedicated servers. Irrelevant, only used for UI"},
   is_net= {enabled = false, value = 0x40, tip = "This function is an RPC (Remote Procedure Call) service request. This implies NetMulticast and Reliable."},
   is_net_reliable= {enabled = false, value = 0x80, tip = "The function is replicated over the network and guaranteed to arrive (requires Client or Server)"},
   is_net_request= {enabled = false, value = 0x100, tip = "This function is an RPC (Remote Procedure Call) service request.(This implies NetMulticast and Reliable)"},
   is_exec = {enabled = false, value = 0x200,   tip = "The function can be executed from the in-game console. \nRequires game restart to take effect"},
   is_native = {enabled = false, value = 0x400, tip = "Generally you want to add this"},
   is_event = {enabled = false, value = 0x800,  tip = "Events can't return values and are used mainly for blueprint communication. Custom Events an be called from console with CE"},
   is_net_response = {enabled = false, value = 0x1000,  tip = "This function is an RPC service response. (This implies NetMulticast and Reliable.). Irrelevant"},
   is_static = {enabled = false, value = 0x2000, tip = "No class instance required"},
   is_net_multicast = {enabled = false, value = 0x4000, tip = "The function is executed both locally on the server,and replicated to all clients, regardless of the Actor's NetOwner."},
   is_ubergraph_function = {enabled = false, value = 0x8000, tip = "Ubergraphs combine all the event graphs on a blueprint and are generated during compilation"},
   is_multicast_delegate = {enabled = false, value = 0x10000,   tip = "Used to broadcast execution to multiple bound functions"},
   is_public = {enabled = false, value = 0x20000,   tip = "Accessible outside of its owner class"},
   is_private = {enabled = false, value = 0x40000,  tip = "Not accessible outside of its owner class - Remove if hooking"},
   is_protected = {enabled = false, value = 0x80000, tip = "This function cannot be overridden in subclasses. Remove if hooking"},
   is_delegate = {enabled = false, value = 0x100000, tip = "Delegates are objects to bind class member functions for type-safe generic calling.\nUnclear at present how much we can interact with these."},
   is_net_server = {enabled = false, value = 0x200000,  tip = "The function is only executed on the server. Irrelevant"},
   has_out_params = {enabled = false, value = 0x400000, tip = "When calling this function you must make an empty table for each\n out param and check the .result property of that param"},
   has_defaults = {enabled = false, value = 0x800000,   tip = "One or more parameters have default values"},
   is_net_client = {enabled = false, value = 0x1000000, tip = "The function is only executed on the client that owns the Object on which the function is called. Also has an _Implementation version"},
   is_dll_import = {enabled = false, value = 0x2000000, tip = "Imported from a third party plugin"},
   is_blueprint_callable = {enabled = false, value = 0x4000000, tip = "The function can be executed in a Blueprint or Level Blueprint graph. Could be useful to set."},
   is_blueprint_event = {enabled = false, value = 0x8000000, tip = "The function can be implemented in a Blueprint or Level Blueprint graph."},
   is_blueprint_pure = {enabled = false, value = 0x10000000, tip = "The function does not affect the owning object in any way. Const functions are pure unless specifically marked otherwise. Pure functions do not cache their results"},
   is_editor_only = {enabled = false, value = 0x20000000,   tip = "This function can be called in the editor on selected instances via a button in the Details panel."},
   is_const = {enabled = false, value = 0x40000000, tip = "C++ feature indicating that it won't modify the staste of the object its called on"},
   is_net_validate = {enabled = false, value = 0x80000000,  tip = "Declares an additional function named the same as the main function,\n but with _Validate added to the end. This function takes the same parameters. Irrelevant"}
}
function_flags.__orderedIndex = {
"is_final",
"is_required_api",
"is_blueprint_authority_only",
"is_blueprint_cosmetic",
"is_net",
"is_net_reliable",
"is_net_request",
"is_exec",
"is_native",
"is_event",
"is_net_response",
"is_static",
"is_net_multicast",
"is_ubergraph_function",
"is_multicast_delegate",
"is_public",
"is_private",
"is_protected",
"is_delegate",
"is_net_server",
"has_out_params",
"has_defaults",
"is_net_client",
"is_dll_import",
"is_blueprint_callable",
"is_blueprint_event",
"is_blueprint_pure",
"is_editor_only",
"is_const",
"is_net_validate",
}


local function ensure_function(func_obj)
    if type(func_obj) == "string" then
        if func_obj:find(".") then
            local class, func = func_obj:split(".")
            return api:find_uobject(class):find_function(func)
        end
    elseif func_obj.hook_ptr ~= nil and func_obj:as_function() then return func_obj end
end


local function check_flags(ufunc)
    local text = {}
    text.__orderedIndex = {}
    for i, name in ipairs(function_flags.__orderedIndex) do
        local value = flags[name]
        if ufunc:get_function_flags() & value ~= 0 then
            text[name] = string.format("0x%x", value)
            table.insert(text.__orderedIndex, name)
        end
    end
    return text
end

local function check_flag(ufunc, flag)
    if ufunc:get_function_flags() & flags[flag] ~= 0 then
        return true
    end
    return false
end

-- clones the function_flags table from above with enabled values set properly
-- suitable for UI display purposes only, use check_flags normally
local function all_fn_flags(func)
    local t = {}
    for i, flag in ipairs(function_flags.__orderedIndex) do
        t[flag] = function_flags[flag]
        table.insert(t.__orderedIndex, flag)
        if check_flag(func, flag) then
            t[flag].enabled = true
        end
    end
    return t
end

local flags_to_reset = {}
local flags_to_set = {}

local function register_flag_to_reset(ufunc, flag)
    flags_to_reset = flags_to_reset or {}
    flags_to_reset[ufunc] = flags_to_reset[ufunc] or {}
    table.insert(flags_to_reset[ufunc], flag)
end

local function register_flag_to_set(ufunc, flag)
    flags_to_set = flags_to_set or {}
    flags_to_set[ufunc] = flags_to_set[ufunc] or {}
    table.insert(flags_to_set[ufunc], flag)
end



local function _set_flag(ufunc, flag)
    register_flag_to_reset(ufunc, flag)
    -- ufunc:set_function_flags(ufunc:get_function_flags() | ((type(flag) == "string" and flags[flag]) or (type(flag) == "number" and flag)))
    ufunc:set_function_flags(ufunc:get_function_flags() | flags[flag])
end

local function _unset_flag(ufunc, flag)
        register_flag_to_set(ufunc, flag)
    ufunc:set_function_flags(ufunc:get_function_flags() & ~  flags[flag])
end

local function set_flag(ufunc, flag)
    if not check_flag(ufunc, flag) then
        _set_flag(ufunc, flag)
    end
end

local function unset_flag(ufunc, flag)
    if check_flag(ufunc, flag) then
        _unset_flag(ufunc, flag)
    end
end



local function set_flags(_flags)
    for idx, flag in ipairs(_flags) do
        set_flag(self, flag)
    end
end

local function unset_flags(_flags)
    for idx, flag in ipairs(_flags) do
        unset_flag(self, flag)
    end
end



local flags_to_reset = {}
local flags_to_set = {}




local FunctionFlags = require("FunctionFlags")

-- dump all flags in a table
function _ufunction:check_flags()
    return check_flags(self)
end

-- check flags by name or hexint
function _ufunction:check_flag(flag)
    return check_flag(self, flag)
end

--utest(pawn:get_class():find_function("AddMovementInput"), "check_flags")

-- allow setting and unsetting by name or int
function _ufunction:set_flag(flag)
    local old_flags = self:check_flags()
    set_flag(self, flag)
end

-- set multiple flags by name or int
function _ufunction:set_flags(flags)
    if flags ~= nil and type(flags) == "table" then
        if #flags > 1 then
            for idx, flag in ipairs(flags) do
                set_flag(self, flag)
            end
        else self:set_flag(flags)
        end
    end
end

-- hmm does this actually need to exist? idk
function _ufunction:is_static()
    return self:check_flag("is_static")
end




function _ufunction:force_call(instance, args)
    set_flags(self, {"is_blueprint_callable", "is_native", "is_public", "is_required_api"})
    unset_flags(self, {"is_blueprint_authority_only", "is_private", "is_editor_only", "is_net_server"})
    instance:call(self:get_fname():to_string(), table.unpack(args))
end


-- allow setting and unsetting by name or int
function _ufunction:unset_flag(flag)
    unset_flag(self, flag)
end

-- set multiple flags by name or int
function _ufunction:unset_flags(flags)
    for idx, flag in ipairs(flags) do
        unset_flag(self, flag)
    end
end




-- have to get names and types from child_properties
function _ufunction:get_param_props()
    local s,r = pcall(function()
        local param_props = {}
        param_props.__lookup = {}
        local params = self:get_child_properties()
        while params ~= nil do
            local p = params:get_fname():to_string()
            local utype = params:get_class():get_name()
            param_props[#param_props + 1] =  {name = p, type = utype, out = params:is_out_param(self)}
            params = params:get_next()
            param_props.__lookup[p] = true
        end
        return param_props
    end)
    return s and r
end


local param_cache
function _ufunction:get_params()
    param_cache = param_cache or {}
    local param_data = param_cache[self] or {}
    if #param_data == 0 then
        for i, tbl in ipairs(self:get_param_props()) do
            local name = tbl.name
            local fprop = self:find_property(name)
            if fprop.is_param and fprop:is_param() then
                ordered_insert(param_data, name, {
                    type = tbl.type,
                    is_out_param = fprop:is_out_param(),
                    is_return_param = fprop:is_return_param(),
                    is_reference_param = fprop:is_reference_param(),
                })
            end
        end
    end
    param_cache[self] = param_data
    return param_data
end




local function build_out_params(func, inargs)
    local params = func:as_function():get_child_properties()
    local out = {}
    local ordered = {}
    local index = 1
    local outparms = {}
    while params ~= nil do

        local p = params:get_fname():to_string()
        ordered[index] = p
        -- you can pass a table with names of already filled params to exclude from filling with an empty table
        if inargs and inargs[p] ~= nil then
            out[p] = inargs[p]
            outparms[p] = params:is_out_param(func)
        elseif not params:is_out_param() then
            out[p] = 0
            outparms[p] = false
            print("Missing input arg ", p)
        else
            outparms[p] = true
            out[p] = {}
        end
        index = index + 1
        params = params:get_next()
    end
    return out, ordered, outparms
end


function _uobject:check_output(fn, args)
    if self.as_class and self:as_class() then return end
    local uclass = self:get_class()
    local realfunc = uclass:find_function(fn)
    local out, ordered, outparms = build_out_params(realfunc, args)
    -- local params = realfunc:get_params()
    -- local results = {}
    -- local fn_args = {}

    -- for name, data in orderedPairs(params) do
    --     if data.is_out_param and args[name] == nil then
    --         ordered_insert(results, name, {})
    --         fn_args[#fn_args+1] = results[name]
    --     else
    --         if args[name] ~= nil then
    --             fn_args[#fn_args+1] = args[name]
    --         else
    --             error(fn.." call sig needs input argument "..name.." of type "..data.type)
    --         end
    --     end
    -- end
    realfunc:set_flag("is_native")
    self:call(fn, table.unpack(out))
    local res = {}
    for i, v in ipairs(ordered) do
        res[v] = outparms[v] and out[v].result or out[v]
    end
    print(inspect(res))
    return res
end






function _ufunction:get_base_class()
    -- local uclass = self:get_outer():as_struct()
    local short = self:get_fname():to_string()
    -- local last = uclass
    -- while uclass ~= nil and uclass:find_function(short) ~= nil do
    --     last = uclass
    --     uclass = uclass:get_super()
    -- end
    -- if last:find_function(short) then return last end
    local basec = api:find_uobject("Class /Script/CoreUObject.Class")
    for i,v in ipairs(basec:get_objects_matching(false)) do
        if v.find_function and v:find_function(short) then
            return v
        end
    end

end


function _uclass:has_static_functions()
    local functions = self:get_functions()
    for i, v in ipairs(functions) do
        if v:is_static() then return true
        end
    end
end

local func_classes = nil
function _ufunction:get_classes_with_function(baseclass)
    func_classes = func_classes or {}
    func_classes[self:get_fname():to_string()] = func_classes[self:get_fname():to_string()] or {}
    if #func_classes[self:get_fname():to_string()] == 0 then
        -- baseclass = baseclass or self:get_base_class()
        -- for i, v in ipairs(baseclass:get_objects_matching(false))
        -- do
        --     if v.as_class and v:as_class() ~= nil then
        --         table.insert(func_classes[self:get_fname():to_string()], v)
        --     end
        -- end
        local array = UEVR_FUObjectArray.get()
        for i = 0, array:get_object_count() - 1 do
            local obj = array:get_object(i)
            if obj and obj:as_class() and obj:as_class():is_child_of(baseclass) then
                table.insert(func_classes[self:get_fname():to_string()] , obj)
            end
        end
    end
    return func_classes[self:get_fname():to_string()]
end



-- get names and types from child_properties
function _uobject:get_functions()
    local funcs = {}
    local struct = self.as_class and self:as_class() or self.get_class and self:get_class()
    if UE5 or Minor >= 25 then
         local s,r = pcall(function()
            local f = {}
            local children = struct:get_children()
            while children ~= nil do
                if children:as_function() ~= nil then
                   f[#f + 1] = children
               end
                children = children:get_next()
            end
            return f
        end)
        if s then funcs = r end
    else
        local props = self:get_properties()
        for i, p in ipairs(props) do
            if p.as_function and p:as_function() ~= nil then
                funcs[#funcs + 1] = p
            end
        end
    end
    return funcs
end

function _uclass:get_function_data()
    local funcs = self:get_functions()
    local t = {}
    for i,v in ipairs(funcs) do
        ordered_insert(t, v:get_short_name(), {
            function_flags = v:check_flags(),
            params = v:get_params()
        })
    end
    return t
end
--unit_test(pawn, "get_functions")
-- local subs
-- function _ufunction:hook_subclasses(prefn, postfn)
--     subs = subs or self:get_classes_with_function(self)


-- end


local func_objects_matching = {}
function _ufunction:get_objects_with_function()
    local baseclass = self:get_base_class()
    func_objects_matching = baseclass:as_class():get_objects_matching(true)
    return func_objects_matching
end

--unit_test(test_func,  "get_objects_with_function")

function _uobject:hook_ptr(prefn, postfn)
  if not self:as_function() then
        print(self:get_full_name().." is not a function") return
    end
    self:as_function():hook_ptr(prefn, postfn)
end

notify_message_colors = {
    info = Vector4f.new(1.0, 1.0, 1.0, 1.0),
    warning = Vector4f.new(1.0, 1.0, 0.0, 1.0),
    error = Vector4f.new(1.0, 0.2, 0.2, 1.0)
}
vr_notify_queue = {}
pc_notify_queue = {}


function imgui_notification(message, scaled_coords, duration, color, start_time)
    if os.clock() - start_time <= duration then
        local res = imgui.get_display_size()
        local x = scaled_coords.x * res.x
        local y = scaled_coords.y * res.y

        uevr.sdk.callbacks.on_frame(function()
            ImGui.register_draw(function()
                imgui.set_cursor_screen_pos(Vector2f.new(x,y))
                imgui.text_colored(message, VecToU32(color))

                            end)
            -- draw.text(message, x, y, color)

        end)
    end
end

function notify_message(msg, type)
    if vr.is_hmd_active() and vr.is_using_controllers() then
        table.insert(vr_notify_queue, notification(msg, {0.5, 0.25}, 5000, notify_message_colors.info, os.clock()))
    end
    if (not (vr.is_hmd_active() and not vr.is_using_controllers())) or dev_mode then
        -- table.insert(pc_notify_queue,
         imgui_notification(msg, {0.05, 0.15}, 5000, notify_message_colors.info, os.clock())
    end
end

local dump_locals = true
function dump_hooked_fn_locals()
    dump_locals = not dump_locals
end

local notify_queue = {}

notify_cache = {}

function _ufunction:notify_heavy(msg)
    local t = {}
    if notify_cache[self:get_full_name()] then
        return true
    end
    self:as_function():set_flags({"is_native", "is_blueprint_callable"})
    local params = self:get_param_names()
    self:hook_ptr(function(fn, obj, locals, result)
        if msg then print(msg) end
        print(fn:get_full_name())
        if params then
            local s,r = pcall(function()
                for i, v in ipairs(params) do
                     if dump_locals then
                        table.insert(t, {v, locals[v]})
                        end
                        print(locals[v])
                    end
                return true
            end)
        end
    end)
    notify_cache[self:get_full_name()] = msg or true
     if dump_locals then
        json.dump_file("Hooks\\"..self:get_full_name(), t, 4)
    end
    return true
end

notify_names = {}
function _ufunction:get_caller()
     self:hook_ptr(function(fn, obj, locals, result)
        if not notify_names[obj] then
            print(obj:get_full_name())
            notify_names[obj] = true
        end
    end)

end

function fn_notify(fnstr, obj, filtered_locals)
    local msg = fnstr.."\nCalled by "..obj
    if filtered_locals then
        for name, value in pairs(filtered_locals) do
            msg = msg.."\n"..name..": "..(value.to_string and value:to_string() or tostring(value))
        end
    end
    if vr.is_hmd_active() and vr.is_using_controllers() then
        table.insert(vr_notify_queue, notification(msg, {0.5, 0.25}, 5000, notify_message_colors.info, os.clock()))
    end
    imgui_notification(msg, {0.05, 0.15}, 5000, notify_message_colors.info, os.clock())

end
local notify_params = {}
notify_history = nil
function _ufunction:notify(args)

    if args then
        local name_filter = args.name_filter or nil
        local args_to_check = args.args_to_check or nil
        local function filter_events(fn, obj, locals )
            local t = {}
            if args_to_check then
                for i,v in ipairs(args_to_check) do
                    t[v] = locals[v] or nil
                end
            end
            local name = obj:get_full_name()
            if (name_filter and name:contains(name_filter, true)) or name_filter == nil then
                fn_notify(fn:get_fname():to_string(), name, t)
            end
        end
         self:hook_ptr(function(fn, obj, locals, result)
                filter_events(fn, obj, locals)
            end)
    else
        self:hook_ptr(function(fn, obj, locals, result)
                printOnce(obj:get_full_name())
                printOnce(fn:get_full_name())

            end)
    end
    -- notify_history = notify_history or {}
    -- notify_history[self] = notify_history[self] or {}
    --  self:hook_ptr(nil, function(fn, obj, locals, result)
    --         if fn ~= self then print(fn, self) end
    --         if notify_history and notify_history[self]
    --             and not notify_history[self][obj] then

    --             notify_history[self][obj] = {time = os.time(), locals = locals}

    --         else

    --             notify_history = notify_history or {}
    --             notify_history[self][obj] = nil
    --         end
    -- end)
    -- register_post_tick(freq, function()
    --     notify_history = notify_history or {}
    --     notify_history[self] = {}
    -- end)
end


function _uobject:notify(msg)
    if not self:as_function() then
        print(self:get_full_name().." is not a function") return end
    self:as_function():notify(msg)
end


local block_cache = {}
function _ufunction:block()
    if block_cache[self:get_full_name()] then
        return true
    end
    self:hook_ptr(function(fn, obj, locals, result)
        print(obj:get_full_name())
        print("Blocked "..fn:get_fname():to_string())
        return false
        end)
    block_cache[self:get_full_name()] = true
    return true
end

_ENV.UEVR_UObject =      _uobject
_ENV.UEVR_UStruct =      _ustruct
_ENV.UEVR_UClass =       _uclass
_ENV.UEVR_UFunction =    _ufunction
_ENV.UEVR_FField =       _ffield
_ENV.UEVR_FProperty =    _fproperty
_G.UEVR_UObject =        _uobject
_G.UEVR_UStruct =        _ustruct
_G.UEVR_UClass =         _uclass
_G.UEVR_UFunction =      _ufunction
_G.UEVR_FField =         _ffield
_G.UEVR_FProperty =      _fproperty

-- -- register_post_tick(100, function() print("1 ticks?") end)

-- -- register_post_tick(34, function() print("2 ticks?") end)

-- -- If you encounter commented out blocks such as this you can uncomment them by simply adding one more - to the first set
-- --[[

-- local testfunc3 = api:find_uobject("Function /Script/Engine.Actor.SetAutoDestroyWhenFinished")
-- testfunc3:as_function():block()

-- print("origin class "..(pc:get_class():find_function("SetAutoDestroyWhenFinished"):as_function():get_base_class()):get_full_name())
-- local objectsmatching = pc:get_class():find_function("SetAutoDestroyWhenFinished"):as_function():get_objects_with_function()
-- for i=1,120 do
--     print(objectsmatching[i]:get_full_name())
-- end
-- end
-- --]]

-- --[[ This confirmed that hooks are not inherited
-- local testfunc4 = api:find_uobject("Function /Script/Engine.ActorComponent.ReceiveTick")
-- testfunc4:as_function():get_caller()
-- --]]


-- --[[
-- if test then
-- local testfunc2 = api:find_uobject("Function /Script/Engine.Character.Jump")
-- testfunc2:notify("Jump notify")
-- end
-- --]]

local jumping = false
 --[[
 -- so fun fact, you can hook functions multiple times
 -- however just one false and it will be blocked entirely
 local testfunc2 = api:find_uobject("Function /Script/Engine.Character.Jump")
 if testfunc2 then
 testfunc2:as_function():set_flags({"is_native", "is_blueprint_callable"})
 testfunc2:as_function():hook_ptr(function(fn, obj, locals, result)
                                  jumping = true
         print(obj:get_full_name())
         print("Jump prehook 1")
         return true
         end)

 testfunc2:as_function():hook_ptr(function(fn, obj, locals, result)
         print(obj:get_full_name())
         print("Jump prehook 2")
         return true
         end)

 testfunc2:as_function():hook_ptr(nil, function(fn, obj, locals, result)
         print(obj:get_full_name())
         print("Jump post hook 1")
         jumping = false
         return true
         end)
 end
 --]]
