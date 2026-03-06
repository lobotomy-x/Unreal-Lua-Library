-- moduleA.lua
return function(exports)
    -- Defer the require until runtime using the loader.get function
    local moduleB = function() return require("loader").get("moduleB") end

    function exports.funcA()
        print("Module A funcA called. Calling Module B funcB.")
        -- Access moduleB functions via the deferred function
        moduleB().funcB()
    end

    exports.dataA = "Data from A"
end
