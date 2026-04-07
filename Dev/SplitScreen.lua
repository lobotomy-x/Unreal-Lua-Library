pc_id = ImGui.incrementer(pc_id, 0, 7, "PC ID")
if imgui.button("Make new Pc") then
    if pc == nil then
        pc_id = 0
    end
    new_pc = Statics:CreatePlayer(world, pc_id, true)
end

if imgui.button("Delete PC") then
    if pc_id == 0 then
        return
    end
    Statics:RemovePlayer(api:get_player_controller(pc_id), true)
end
if imgui.button("Toggle Splitscreen") then
    split = not split
    Statics:SetForceDisableSplitscreen(world, split)
end