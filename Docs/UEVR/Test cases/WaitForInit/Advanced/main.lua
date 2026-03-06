-- main.lua
local loader = require("loader")
function def(modName, modPath)
    loader.define(modName, require(modPath or modName))
end
function load_exports(mod)
     return require("loader").get(mod)
end
-- Define modules using the loader
--loader.define("moduleA", require("moduleA"))
--loader.define("moduleB", require("moduleB"))

-- Load all modules. This is where the magic happens.
-- The coroutines manage the cooperative loading.
loader.load_all()

-- Access the fully loaded modules
local modA = loader.get("moduleA")
local modB = loader.get("moduleB")

modA.funcA()
modB.funcB()
