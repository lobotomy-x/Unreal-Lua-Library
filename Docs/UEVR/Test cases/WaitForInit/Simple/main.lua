function wait_for_init(name)
    while not _ENV[name] do
        coroutine.yield()
    end
end

 
function delay_co(t)
    local co = coroutine.create(function()
        for _, v in ipairs(t) do
            _ENV[v] = require("simple/"..v)
        end
        for _, v in ipairs(t) do
            wait_for_init(v)
        end
    end)
    coroutine.resume(co)
end



delay_co({"test", "test2", "test3"})
test1res = test.func(1, 2)
test2res = test2.func2(1, 2)
test3res = test3.func3(1,1)
test4res = test.func4(2,1)
print(test1res)
print(test2res)
print(test3res)
print(test4res)



test = require("simple.test")
test2 = require("simple.test2")
test3 = require("simple.test3")

