
uevr.sdk.callbacks.on_lua_event(function(event_name, event_data)
    if event_name == "exec" then
        chunk, err = load(event_data)
        local success, result = pcall(chunk)
        print(inspect(result))
    end
end)