
local function hide_skeletal_mat(mesh, mat_idx)
    mesh:ShowMaterialSection(mat_idx,mat_idx, false, 0)
end

local function show_skeletal_mat(mesh, mat_idx)
    mesh:ShowMaterialSection(mat_idx,mat_idx, true, 0)
end


local function is_showing_mat(mesh, mat_idx)

   return  mesh:IsMaterialSectionShown(mat_idx,0)
end
local mesh = GetCharacterMesh()
    uevr.lua.add_script_panel("mesh", function()
    imgui.text("Mats "..tostring(mesh:GetNumMaterials()))
    for i = 1, mesh:GetNumMaterials() do
    imgui.push_id(i+1000)
    if imgui.button("Hide mat "..tostring(i)) then
    if is_showing_mat(mesh, i-1, 0) then
    hide_skeletal_mat(mesh, i-1)
    else
    show_skeletal_mat(mesh, i-1)
    end
    end

    imgui.pop_id()

    end
end)