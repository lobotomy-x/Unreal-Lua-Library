uevr.sdk.callbacks.on_lua_event(function(event_name, event_data)
    if event_name == "exec" then
        local success, run_err = pcall(load(event_data))
        if not success then print("Runtime Error: " .. run_err) end
    end
end)

