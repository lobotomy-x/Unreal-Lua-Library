-- Prepare a variable in the true global table
_G.benchmark_var = 123
local iterations = 10000000 -- 10 million accesses

-- 1. Test ORIGINAL: Simple Fallback (Always checks _G)
local env_simple = setmetatable({}, { __index = _G })
local start_simple = os.clock()
for i = 1, iterations do
    local x = env_simple.benchmark_var
end
local time_simple = os.clock() - start_simple

-- 2. Test ALTERED: Caching Fallback (Copies to local _ENV after first access)
local env_cache = setmetatable({}, {
    __index = function(t, k)
        local v = _G[k]
        if v ~= nil then rawset(t, k, v) end
        return v
    end
})
local start_cache = os.clock()
for i = 1, iterations do
    local x = env_cache.benchmark_var
end
local time_cache = os.clock() - start_cache

-- Print Results
print(string.format("Simple Fallback: %.4f seconds", time_simple))
print(string.format("Caching Fallback: %.4f seconds", time_cache))
print(string.format("Speed improvement: %.2fx", time_simple / time_cache))


local Benchmark = {
    label = "",
    parameters = {},
    results_in = false,
    timings = {},
    cases = {}
}
Benchmark.__index = Benchmark
function Benchmark.new(label)
    local t = {}
end
function Benchmark:add_case(name, func, params)

end

uevr.lua.add_script_panel("test2", function()
local c1, n1, s1, s2 = imgui.input_text("String1", text_test.a)
if c1 then text_test.a = n1 end
local c2, n2, s11, s22 = imgui.input_text("String2", text_test.b)
if c2 then text_test.b = n2 end
if imgui.button("execute") then
    text_test.out = Kismet("String"):Concat_StrStr(text_test.a, text_test.b)
end
imgui.text(text_test.out)

if imgui.button("Run benchmark") then
    time_naive, size_naive, time_opt, size_opt, time_gopt, size_gopt = test_string_concat()
    results_in = true
end
if results_in then

    imgui.text(string.format("Naive (..):     %.4f seconds (Size: %d bytes)", time_naive, size_naive))

    imgui.text(string.format("Optimized:      %.4f seconds (Size: %d bytes)", time_opt, size_opt))
    imgui.text(string.format("game Optimized:      %.4f seconds (Size: %d bytes)", time_gopt, size_gopt))

    imgui.text(string.format("\nSpeedup: %.2fx faster", time_naive / time_opt))
    end
end)