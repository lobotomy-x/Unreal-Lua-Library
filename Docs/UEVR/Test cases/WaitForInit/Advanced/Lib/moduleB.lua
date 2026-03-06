-- moduleB.lua
return function(M)
    -- Defer the require until runtime using the loader.get function
    --local moduleA = function() return require("loader").get("moduleA") end
    local moduleA = load_exports("moduleA")

    function M.funcB()
        print("Module B funcB called. Accessing Module A dataA: " .. moduleA().dataA)
    end

   M.dataB = "Data from B"
end
