
local console = uevr.api:get_console_manager()
local api = uevr.api
local vr = uevr.params.vr

local has_checked_fg

local fg_vars = {
    "r.FidelityFX.FI.Enabled",
    "r.Streamline.DLSSG.Enable",
    "r.XeFG.Enabled",
}


local non_vr_setting

local function check_fg(console)
    local vr_ready = vr.is_runtime_ready() and vr.is_hmd_active()
    if (not has_checked_fg) then
        for i, v in ipairs(fg_vars) do
            local fg = console:find_variable(v)
            if fg then
                print("Found "..v)
                if fg:get_int() == 1 then
                    if vr_ready then
                        non_vr_setting = non_vr_setting or {}
                        non_vr_setting[v] = 1
                        print("Disabled "..v)
                        fg:set_int(0)
                    else
                        print("VR is disabled, preserving user setting")
                        non_vr_setting = non_vr_setting or {}
                        non_vr_setting[v] = 1
                    end
                else
                    print("Already disabled")
                end
            end
        end
    end
    has_checked_fg = true
end


local function wait_for_spawn()
    local console_manager
    local function check(console)
        while not console do
            coroutine.yield()
        end
    end

    local co = coroutine.create(function()
        local s, r = pcall(function()
            local console = api:get_console_manager()
            check(console)
            return console
        end)
        if s then console_manager = r end
    end)
    coroutine.resume(co)


end
wait_for_spawn()
uevr.sdk.callbacks.on_post_engine_tick(function(engine, delta)
    if not has_checked_fg then
        console = console or uevr.api:get_console_manager()
        if console then
            check_fg(console)
        end
    end
    if non_vr_setting and not (vr.is_runtime_ready() and vr.is_hmd_active()) then
        console = console or uevr.api:get_console_manager()
        for k,v in pairs(non_vr_setting) do
            console:find_variable(k):set_int(v)
        end
    end



end)



local sr_options = {
    DLSS = {
        Enabled = "r.NGX.DLSS.Enable",
        Quality = "r.NGX.DLSS.Quality",
        QualityRange = {-2, 3},
    },
    XESS = {
        Enabled = "r.XeSS.Enabled",
        Quality = "r.XeSS.Quality",
        QualityRange = {1, 4},
    }
}

local checked_fsr = false
local function check_fsr_prefix()
    local fsr_prefix = "r.FidelityFX.FSR"
    console = console or uevr.api:get_console_manager()
    local found = false
    for i, v in ipairs({"", "2", "3"}) do
        if console:find_variable(fsr_prefix..v..".Enabled") then
            fsr_prefix = fsr_prefix..v
            found = true
        end
    end
    if found then
        sr_options["FSR"] = {
        Enabled = fsr_prefix..".Enabled",
        Quality = fsr_prefix..".QualityMode",
        QualityRange = {0, 4},
        Extras = {
            fsr_prefix..".AutoExposure",
            fsr_prefix..".DeDither",
        }
    }
    end
    checked_fsr = true
end


local min = math.min
local function display_sr_settings()
    if not checked_fsr then
        check_fsr_prefix()
    end
    imgui.push_item_width(min(imgui.get_window_size().x * 0.67, 250))
    console = console or uevr.api:get_console_manager()
    for k,v in pairs(sr_options) do
        local var = console:find_variable(v.Enabled)
        if var then
            local enabled = var:get_int() == 1

            if imgui.collapsing_header(k) then
                imgui.push_id(v.Enabled)
                local c, nv = imgui.checkbox("Enabled##"..k, var:get_int() == 1)
                if c then 
                    enabled = nv
                    if not enabled then
                    var:set_int(0)
                    else var:set_int(1)
                    end
                end
                imgui.pop_id()
                 if k == "DLSS" and console:find_variable("r.NGX.DLSS.Preset") ~= nil then
                    local presets = {"A", "B", "C", "D", "E", "F", "G"}
                    local denoiser = console:find_variable("r.NGX.DLSS.DenoiserMode")
                    if denoiser then
                        denoiser:set_int(1)
                        presets = {"A", "B", "C", "D", "E", "F", "G", "H", "I", "J","K"}
                        imgui.text("DLSS-RR found, Preset J or K recommended")
                    end
                    local presetvar = console:find_variable("r.NGX.DLSS.Preset")
                    local preset = presetvar:get_int()
                    if preset == 0 then preset = 1 end
                    local cpreset, npreset = imgui.combo("DLSS Preset", preset, presets)
                    if cpreset then
                        presetvar:set_int(npreset)
                    end
                end
                local quality = console:find_variable(v.Quality)
                if quality then
                    local quality_value = quality:get_int()
                    if k == "FSR" then
                        imgui.text("Lower value is higher quality")
                    end
                    local cq, nq = imgui.slider_int("Quality##"..k, quality_value, v.QualityRange[1], v.QualityRange[2])
                    if cq then
                        quality_value = nq
                        quality:set_int(quality_value)
                        if k == "DLSS" then
                            local auto = console:find_variable("r.NGX.DLSS.Quality.Auto")
                            if auto and auto:get_int() == 1 then auto:set_int(0) end
                            if quality_value == "3" then
                              console:find_variable("r.NGX.DLAA.Enable"):set_int(1)
                            end
                        end
                    end
                end
            end
        end
    end
    imgui.pop_item_width()
end

uevr.lua.add_script_panel("Super Resolution Settings", function()
    display_sr_settings()
end)


