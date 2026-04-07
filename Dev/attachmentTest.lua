

if imgui.button("test attachments") then
     print(inspect(pawn:get_attached_components())
end

if imgui.button("test components") then
     print(inspect(pawn:get_components())
end


if imgui.button("Add arrow") then
    pawn = pawn or uevr.api:get_local_pawn(0)
    local arrow  = pawn:add_component("ArrowComponent")
    DebugDraw.debug_draw_shape(arrow)
    arrow:attach(pawn, "None", {2,0,2})
    arrow:set_rotation(pawn:rotation())
end

if imgui.button("Destroy Arrows") then 
pawn = pawn or uevr.api:get_local_pawn(0)
local arrows = pawn.RootComponent.AttachChildren --get_components("ArrowComponent")
for i,v in ipairs(arrows) do
if v:get_class():get_short_name() == "ArrowComponent" then
print(v:to_string())
v:destroy()
end
end
end     
local attachments, components
if imgui.button("test attachments") then 
    attachments = pawn:get_attached_components()
end

if imgui.button("test components") then
    components = pawn:get_components()

end

if attachments then
    if imgui.collapsing_header("Attachments") then
    for i, v in ipairs(attachments) do
        if imgui.tree_node_ptr_id(i, v:get_short_name()) then
                imgui.push_id(i)
                    imgui.text(inspect(v:get_property_info())
                imgui.pop_id()
                imgui.tree_pop()
        end

        end
    end
end



local function get_attachments_components()
    local components = pawn:get_components()
    local attachments = pawn:get_attached_components()
        for i = #components, 1, -1 do
            if components[i]:is_in(attachments) then
            table.remove(components, i)
            end
        end
    return components, attachments
end


    local function tree_child(obj)
        local props = obj:get_property_info()
        imgui.push_id(imgui.get_id(obj))
        if imgui.tree_node(obj:readable_name()) then
            for i,v in ipairs(props) do
                imgui.push_id(i)
                if imgui.tree_node(v.name) then
                imgui.text(v.type)
                    imgui.text(inspect(v.Value))
                        imgui.tree_pop()
                    end
                imgui.pop_id()
                end
            imgui.tree_pop()
        end
        imgui.pop_id()
    end
local components, attachments = get_attachments_components()
    if imgui.collapsing_header("Unattached Components") then
        


        for i, v in ipairs(components) do
             tree_child(v)
        end
    end
    

    if imgui.collapsing_header("Attachments") then
        


        for i, v in ipairs(attachments) do
             tree_child(v)
        end
    end
    

