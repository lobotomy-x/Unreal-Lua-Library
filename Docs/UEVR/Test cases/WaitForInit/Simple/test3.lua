local M = {}


delay_co({"test","test2"})
function M.func3(a, b)
    return test.func(a,b) + test2.func2(a,b)
end
local test = _ENV.test or require("simple.test")

local test2 = _ENV.test2 or require("simple.test2")
return M