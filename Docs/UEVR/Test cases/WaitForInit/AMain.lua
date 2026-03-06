-- main.lua
local ModuleThreads = {}
local ModuleStatus = {}
local ModuleErrors = {}

local function safe_require(name)
    local ok, result = pcall(require, "Lib/" .. name)
    if not ok then
        ModuleStatus[name] = "error"
        ModuleErrors[name] = result
        return nil
    end
    return type(result) == "table" and result
end

function wait_for_module(name)
    while ModuleStatus[name] ~= "ready" do
        if ModuleStatus[name] == "error" then
            return false
        end
        coroutine.yield()
    end
    return true
end

function load_module_threaded(name)
    ModuleStatus[name] = "loading"
    local co = coroutine.create(function()
        local ok, result = pcall(require, "Lib/" .. name)
        if ok and result ~= nil and type(result) == "table" then
            _ENV[name] = result
            ModuleStatus[name] = "ready"
        else
            ModuleStatus[name] = "error"
            ModuleErrors[name] = result
        end
    end)
    ModuleThreads[name] = co

end

function update_module_loader()
    for name, co in pairs(ModuleThreads) do
        if coroutine.status(co) ~= "dead" then
            local ok, err = coroutine.resume(co)
            if not ok then
                ModuleStatus[name] = "error"
                ModuleErrors[name] = err
            end
        end
    end
end

function load_all_modules(list)
    for _, name in ipairs(list) do
      load_module_threaded(name)
    end
end
function retry_failed_modules()
    for name, status in pairs(ModuleStatus) do
        if status == "error" then
            ModuleStatus[name] = "pending"
            ModuleErrors[name] = nil
            load_module_threaded(name)
        end
    end
end
-- Kick off loading
load_all_modules({ "A", "B" })

-- Simulate update loop
for i = 1, 20 do
    update_module_loader()
    -- Show results
  print("=== Module Status ===")
  for name, status in pairs(ModuleStatus) do
      print(name .. ": " .. status)
      if status == "error" then
          print("  Error: " .. tostring(ModuleErrors[name]))
      end
  end
end



-- Use loaded modules
if ModuleStatus["A"] == "ready" then
    A.say_hello()
end

A = require("Lib/A")
B = require("Lib/B")