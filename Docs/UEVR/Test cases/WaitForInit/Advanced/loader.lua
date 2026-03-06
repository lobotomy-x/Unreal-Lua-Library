-- loader.lua
local loader = {}
local loaded_modules = {}
local module_coroutines = {}
local module_definitions = {} -- Stores the raw module functions

-- Function to define a module
function loader.define(name, module_func)
    module_definitions[name] = module_func
end

-- Function to get an already loaded (or loading) module interface
function loader.get(name)
    -- If the module is already fully loaded, return its interface
    if loaded_modules[name] and coroutine.status(module_coroutines[name]) == "dead" then
        return loaded_modules[name]
    end
    -- If the module is currently loading (suspended), return the partial table
    if module_coroutines[name] and coroutine.status(module_coroutines[name]) ~= "dead" then
        return loaded_modules[name]
    end
    -- If not started, this indicates an issue in the loading order/design
    error("Attempt to use module '" .. name .. "' before it is loaded or during a non-deferred access.")
end

-- Function to start the loading process for all modules
function loader.load_all()
    -- 1. Initialize empty interface tables and coroutines for all modules
    for name, module_func in pairs(module_definitions) do
        loaded_modules[name] = {} -- Create an empty table for the module's public interface
        -- Wrap the module's function in a coroutine
        module_coroutines[name] = coroutine.create(function()
            module_func(loaded_modules[name]) -- Pass the shared interface table to the module
        end)
    end

    -- 2. Concurrently resume all module coroutines until they are all finished
    local all_dead = false
    while not all_dead do
        all_dead = true
        for name, co in pairs(module_coroutines) do
            if coroutine.status(co) ~= "dead" then
                all_dead = false
                local success, err = coroutine.resume(co)
                if not success then
                    error("Error loading module '" .. name .. "': " .. tostring(err))
                end
            end
        end
        -- Optional: yield the main thread to prevent a tight loop if modules yield internally
        -- coroutine.yield() 
    end
end

return loader
