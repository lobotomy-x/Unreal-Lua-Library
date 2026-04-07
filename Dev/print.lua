
function printOnce(msg)
    if msg_cache[msg] then return end
    uevr.params.functions.log_info("[LUA] "..msg)
    msg_cache[msg] = true
    print(msg)
end


local function print_to_ue_console(message)
    pc = pc or api:get_player_controller(0)
    if pc.ClientSendMessage then pc:ClientSendMessage(message) end
end