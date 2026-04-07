post_tick_value_test = {}
tick_value_test = {}
function register_pre_tick(interval, fn)
    local pt = 0
    delay_game_load(pc, "get_player_controller")
    uevr.sdk.callbacks.on_pre_engine_tick(function(engine, delta)
       pt = pt + 1
       if pt == interval or pt % interval == 0 then
            if type(fn) == "function" then
                fn(engine, delta)
             end
        end
        if pt > math.max(2000, interval) then pt = 0 end
    end)
end

_ENV.register_pre_tick = register_pre_tick

function register_post_tick(interval, fn)
    local pt = 0
    delay_game_load(pc, "get_player_controller")
    uevr.sdk.callbacks.on_post_engine_tick(function(engine, delta)
       pt = pt + 1
       if pt == interval or pt % interval == 0 then
            if type(fn) == "function" then
                fn(engine, delta)
             end
        end
        if pt > math.max(2000, interval) then pt = 0 end
    end)
end
pre_tick = register_pre_tick
post_tick = register_post_tick
_ENV.register_post_tick = register_post_tick


-- post_tick(120, function(engine, delta)
--     print("120 ticks")
-- end)
-- post_tick(36, function(engine, delta)
--     print("36 ticks")
-- end)
