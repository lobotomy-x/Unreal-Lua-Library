local M = {}

delay_co({"test"})


function M.func2(a, b)
    return test.func(a,b) * 2
end
local test = _ENV.test or require("simple.test")
return M