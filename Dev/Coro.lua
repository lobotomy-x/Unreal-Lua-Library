function delay_game_load(obj)
    local function wait_for_game_init(obj)
        while not obj do
            coroutine.yield()
        end
    end


    local co = coroutine.create(function()
        local s, r = pcall(function() if UEVR_UObjectHook.exists(obj) then return obj end end)
        obj = r or nil
        wait_for_game_init(obj)
    end)
    coroutine.resume(co)
end
function delay_module_load(t)
    local function wait_for_module_init(name)
        while not _G[name] do
            coroutine.yield()
        end
    end



    local co = coroutine.create(function()
        for _, v in ipairs(t) do
            _G[v] = require(v)
        end
        for _, v in ipairs(t) do
            wait_for_module_init(v)
        end
    end)
    coroutine.resume(co)
end

function co_load(env_name, path)
    local function wait_for_module_init(name)
        while not _G[name] do
            coroutine.yield()
        end
    end

    local co = coroutine.create(function()
        _G[env_name] = require(path)
        wait_for_module_init(env_name)
    end)
    coroutine.resume(co)
end
function wait_for_object_death(obj)

    local function object_is_alive(object)
        while UEVR_UObjectHook.exists(object) do
            coroutine.yield()
        end
    end

    local co = coroutine.create(function()
        object_is_alive(obj)
    end)
    coroutine.resume(co)
end


local function wait_for_test(delay, time)
    while not (os.clock() - time) > delay do
        coroutine.yield()
    end
end

local function delay_test(delay)
    local start_time = os.clock()
    local co = coroutine.create(function()
        wait_for_test(delay, start_time)
    end)
    coroutine.resume(co)
end
