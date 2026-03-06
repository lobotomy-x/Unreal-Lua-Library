local M = {}


function M.func(a, b)
    return a + b 
end
function M.func4(a, b)
  
  delay_co({"test3"})
    return test3.func3(a + b) + 1 
    
    local test3 = _ENV.test3 or require("simple.test3")
end


return M