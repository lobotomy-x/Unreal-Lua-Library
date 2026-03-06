-- Lib/A.lua

local M = {}

function M.say_hello()
    print("Hello from A!")
    B.say_hi()
end
wait_for_module("B")
local B = _ENV.B or require("Lib/B")

return M
