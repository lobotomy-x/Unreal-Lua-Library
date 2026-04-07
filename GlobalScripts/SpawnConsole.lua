local pc 
local console_spawned = false
local function spawn_console()
    pc = pc or api:get_player_controller(0)
    if pc then
        local pc_player_ref = pc.Player
            if not pc_player_ref then
                local props = pc:get_class():get_child_properties()
                while props ~= nil do
                    -- probably only necessary because MHUR devs want to be different and named their player ref PLAYER
                    if props and props.get_fname and props:get_fname():to_string():lower() == "player" then
                        pc_player_ref = pc[props:get_fname():to_string()]
                        if pc_player_ref ~= nil then break end
                    end
                end
            end
            local _viewport
            if pc_player_ref then
                _viewport = pc_player_ref.ViewportClient
            else
                _viewport = uevr.api:find_uobject("Class /Script/Engine.GameViewportClient"):get_first_object_matching(false)
            end

            if _viewport and _viewport.ViewportConsole == nil then
                   local console_class = uevr.api:find_uobject("Class /Script/Engine.Console")

             local temp = uevr.api:spawn_object(console_class, _viewport)
               _viewport.ViewportConsole = temp
               if _viewport.ViewportConsole ~= nil then
                    console_spawned = true
                    print("Console spawned, activate with ~")
               end
            end
        end
end
spawn_console()
