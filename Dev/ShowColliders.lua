
local params = {
    include_arrows = false,
    include_brushes = false,
    color_profiles = nil
}


local collision_drawn  = false
local wake_all = true
local colliders = nil
local color_table
local ECollisionEnabled = {
    NoCollision = 0,
    QueryOnly = 1,
    PhysicsOnly = 2,
    QueryAndPhysics = 3,
    ECollisionEnabled_MAX = 4,
}

local ERendererStencilMask = {
    ERSM_Default = 0,
    ERSM_255 = 1,
    ERSM_1 = 2,
    ERSM_2 = 3,
    ERSM_4 = 4,
    ERSM_8 = 5,
    ERSM_16 = 6,
    ERSM_32 = 7,
    ERSM_64 = 8,
    ERSM_128 = 9,
    ERSM_MAX = 10,
}



function SetStencilParms(shape, dsv, stencil_mask)
    if stencil_mask == nil then stencil_mask = "ERSM_255" end
    shape:SetRenderCustomDepth(true)
    shape:SetCustomDepthStencilValue(dsv)
    shape:SetCustomDepthStencilWriteMask(ERendererStencilMask[stencil_mask])
end

function debug_draw_shape(shape, color)
    color = color or get_semi_random_bright_color()
    local fcolor = (color * 255.0)
    shape:SetHiddenInGame(false, false)
    shape.bAutoActivate = true
    shape:SetVisibility(true, true)
    shape:SetRenderInMainPass(true)
    shape:SetRenderCustomDepth(true)
    shape:SetCustomDepthStencilValue(255)
    shape:SetCustomDepthStencilWriteMask(ERendererStencilMask.ERSM_255)
    for _,v in ipairs({"ShapeColor", "BrushColor", "ArrowColor"}) do
        if shape:get_property(v) then
            shape:set_property(v, {
                R =  fcolor.x,
                G =  fcolor.y,
                B =  fcolor.z,
                A =  fcolor.w
            })
        end
    end
end

function V4toLC(v)
    return {
        R =  v.x,
        G =  v.y,
        B =  v.z,
        A =  v.w
    }
end

function V4toC(v)
    v = v * 255.0
    return {        
        R =  math.floor(v.x),
        G =  math.floor(v.y),
        B =  math.floor(v.z),
        A =  math.floor(v.w)
    }
end
local class_names = {
    "CapsuleComponent",
    "BoxComponent",
    "SphereComponent",

}
local function apply_shape_properties(shape, color)
    shape:SetHiddenInGame(false, false)
    shape.bAutoActivate = true
    shape:SetVisibility(true, true)
    shape:SetRenderInMainPass(true)
    shape:SetRenderCustomDepth(true)
    shape:SetCustomDepthStencilValue(100)
    shape:SetCustomDepthStencilWriteMask(ERendererStencilMask.ERSM_255)
    shape.ShapeColor.R = color.x * 255.0
    shape.ShapeColor.G = color.y * 255.0
    shape.ShapeColor.B = color.z * 255.0
    shape.ShapeColor.A = color.w * 255.0
end

-- this can legit fuck up your game lol
function test_all_colliders()
    for i, v in ipairs(("PrimitiveComponent"):find_allinstances(true)) do
          v:SetCollisionEnabled(ECollisionEnabled["QueryAndPhysics"])
   v:SetCollisionObjectType(ECollisionChannel["ECC_Visibility"])
  v:SetCollisionProfileName("BlockAll", true)
  v:SetCollisionResponseToChannel(ECollisionChannel["ECC_Visibility"], ECollisionResponse["ECR_Overlap"])
end

end
--test_all_colliders()


 color_table = get_semi_random_bright_color(1, 500, true)

uevr.lua.add_script_panel("Visualizers", function()

    local c, n = imgui.checkbox("Include Arrows", params.include_arrows)
    if c then params.include_arrows = n end


    local c, n = imgui.checkbox("Include Brushes", params.include_brushes)
    if c then params.include_brushes = n end

    if imgui.button("Toggle show all collision and shapes") then
        collision_drawn = not collision_drawn
        local all_collider_objects = {}
        for i, v in ipairs(class_names) do
            extend_table(all_collider_objects, find_all(v))
        end
        if params.include_arrows then
                extend_table(all_collider_objects, find_all("ArrowComponent"))
        end
        if params.include_brushes then
            extend_table(all_collider_objects, find_all("BrushComponent"))
        end
        print(#all_collider_objects)
        colliders = #all_collider_objects
        color_table = color_table or {}

        for idx, shape in ipairs(all_collider_objects) do
            if collision_drawn then
                color_table[idx] = color_table[idx] or get_semi_random_bright_color(idx, colliders)
                if wake_all then shape:WakeAllRigidBodies() end
                debug_draw_shape(shape, color_table[idx] or get_semi_random_bright_color() )
            else
                shape:SetVisibility(false, false)
                shape:SetRenderInMainPass(false)
                shape:SetRenderCustomDepth(false)
                shape:SetCustomDepthStencilValue(0)
            end
        end
    end
    if collision_drawn then
        imgui.text("Enabled visualizations for "..tostring(colliders).." shapes")

    end

end)