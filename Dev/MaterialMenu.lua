

local EBlendMode =
{
    BLEND_Opaque                             = 0,
    BLEND_Masked                             = 1,
    BLEND_Translucent                        = 2,
    BLEND_Additive                           = 3,
    BLEND_Modulate                           = 4,
    BLEND_AlphaComposite                     = 5,
    BLEND_AlphaHoldout                       = 6,
    BLEND_MAX                                = 7,
}
local EMaterialShadingModel =
{
    MSM_Unlit                                = 0,
    MSM_DefaultLit                           = 1,
    MSM_Subsurface                           = 2,
    MSM_PreintegratedSkin                    = 3,
    MSM_ClearCoat                            = 4,
    MSM_SubsurfaceProfile                    = 5,
    MSM_TwoSidedFoliage                      = 6,
    MSM_Hair                                 = 7,
    MSM_Cloth                                = 8,
    MSM_Eye                                  = 9,
    MSM_SingleLayerWater                     = 10,
    MSM_ThinTranslucent                      = 11,
    MSM_FaceToon                             = 12,
    MSM_HairToon                             = 13,
    MSM_SkinToon                             = 14,
    MSM_NUM                                  = 15,
    MSM_FromMaterialExpression               = 16,
    MSM_MAX                                  = 17,
}
function M.HighlightMesh(mesh)
    local mat = UE.CreateMID("Material /Engine/EngineMaterials/EmissiveMeshMaterial.EmissiveMeshMaterial")
    mat.BlendMode = EBlendMode["BLEND_Translucent"]
    mat.ShadingModel = EMaterialShadingModel["MSM_ThinTranslucent"]
    if mat ~= nil then mesh:SetOverlayMaterial(mat)

    end
end
local real_sel_mat, selected_mat, sel_mat2 =     "Material /Engine/EngineMaterials/EmissiveMeshMaterial.EmissiveMeshMaterial", 1, 1

selected_mat = 1
local function OverlayMaterialMenu(mesh)
    if imgui.begin_menu("Overlay Materials") then

        if imgui.menu_item("Clear Overlay Mat") then
            mesh.OverlayMaterial = nil
        end
        if imgui.menu_item("Clear Overlay Mat 2") then
            mesh:SetOverlayMaterial(nil)
        end
        local c, nm = imgui.combo("Engine Materials", selected_mat, engine_mats)
        if c then selected_mat = nm
            real_sel_mat = engine_mats[selected_mat]
        end
        if imgui.menu_item("Add Highlight") then UE.HighlightMesh(mesh) end
        imgui.text(real_sel_mat)
        if imgui.menu_item("Add Overlay Mat") then
            local mat = UE.CreateMID(real_sel_mat)

            if mat ~= nil then mesh:SetOverlayMaterial(mat) end
        end

    imgui.end_menu()
    end
end


local real_sel_mat, selected_mat, sel_mat2 ="Material /Engine/EngineMaterials/EmissiveMeshMaterial.EmissiveMeshMaterial", 1, 1
local mat_names = nil
selected_mat = 1
local matidx_to_hide = 0
local nummats = nil
local function overlay_material_menu(mesh)
    nummats = nummats or mesh:GetNumMaterials()
    if imgui.begin_menu("Skeletal Materials") then
            -- if imgui.menu_item("check names") then
            --  mat_names = mat_names or mesh:GetMaterialSlotNames()
            --  if mat_names then print(inspect(mat_names)) end
            -- end
            matidx_to_hide = ImGui.incrementer(matidx_to_hide, 0, nummats, "Material index to hide")
            if imgui.menu_item("Hide Index") then
                mesh:ShowMaterialSection(matidx_to_hide, matidx_to_hide, false, 0)
            end
            if imgui.menu_item("Show Index") then
                mesh:ShowMaterialSection(matidx_to_hide, matidx_to_hide, true, 0)
            end
            if imgui.menu_item("Show All Mats") then
                mesh:ShowAllMaterialSections(0)
            end
        if imgui.menu_item("Hide All Mats") then
        for i = 0, mesh:GetNumMaterials()  do
            mesh:ShowMaterialSection(i,i,false)
        end         end
            imgui.end_menu()


        end
    if imgui.begin_menu("Overlay Materials") then

        if imgui.menu_item("Clear Overlay Mat") then
            mesh.OverlayMaterial = nil
            print("Clear method 1")
        end
        if imgui.menu_item("Clear Overlay Mat 2") then
            mesh:SetOverlayMaterial(nil)
            print("Clear Method 2")
        end
        local c, nm = imgui.combo("Materials", selected_mat, engine_mats)
        if c then selected_mat = nm
            real_sel_mat = engine_mats[selected_mat]
        end
        -- if imgui.menu_item("Add Highlight") then HighlightMesh(mesh) end
        imgui.text(real_sel_mat)
        if imgui.menu_item("Add Overlay Mat") then
            local mat = M.CreateMID(real_sel_mat)

            if mat ~= nil then mesh:SetOverlayMaterial(mat) end
        end
        -- if imgui.begin_menu("All mats") then
        --  if imgui.menu_item("Refresh") then
        --      get_all_mats()
        --  end
        --  local cm, n = imgui.combo("All Materials", sel_mat2, mats.all)
        --  if cm then sel_mat2 = n end
        --  if imgui.menu_item("Add Overlay Mat") then
        --      local mat = UE.CreateMID(mats.all[sel_mat2])
        --      if mat ~= nil then mesh:SetOverlayMaterial(mat) end
        --  end
        --  imgui.end_menu()
        -- end
    imgui.end_menu()
    end
end


local function create_mid(name)
    if not mats or not mats[name] then
        if mats == nil or #mats == 0 then get_all_mats() end
        mats[name] = api:find_uobject(name)
        print(mats[name])
    end
    if mats[name] then
        return Kismet("Material"):CreateDynamicMaterialInstance(pc, mats[name], UEVR_FName.new(), 0)
    end
end
local function update_poseable(poseable_mesh, leader_mesh, posed_bones, is_fp)
    names = names or BoneUtil.GetBoneNames(leader_mesh)
    socket_names = socket_names or BoneUtil.GetSockets(leader_mesh)
    local function setup()
        leader_mesh.PrimaryComponentTick.bTickEvenWhenPaused = true
        M.SetSkelMesh(poseable_mesh, M.GetSkelMeshAsset(leader_mesh))
        M.SetMeshLeader(poseable_mesh, leader_mesh.LeaderPoseComponent or leader_mesh)
        if poseable_mesh.CopyPoseFromSkeletalComponent then poseable_mesh:CopyPoseFromSkeletalComponent(leader_mesh) end
            poseable_mesh:K2_SetRelativeTransform(leader_mesh:GetRelativeTransform())
        end
    end

    local function update_poseable_mesh()
            if poseable_mesh == nil or not UEVR_UObjectHook.exists(poseable_mesh) then
            poseable_mesh = leader_mesh:get_outer():add_component("PoseableMesh")
        end
        local bone_poses = {}

        uevr.sdk.pre_engine_tick(function(engine, delta)
            update_poseable_mesh()
            if not poseable_mesh then return end
            poseable_mesh:CopyPoseFromSkeletalComponent(leader_mesh)
            if posed_bones then
                for i, v in ipairs(posed_bones) do
                    poseable_mesh:SetBoneTransformByName(FName(v), bone_poses[v], 0, false)
                end
            end

        end)
        uevr.sdk.post_engine_tick(function(engine, delta)
            poseable_mesh:K2_SetRelativeTransform(leader_mesh:GetRelativeTransform())
        end)
end
