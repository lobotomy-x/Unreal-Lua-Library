if version.major == 5  then
        if ImGui.ToggleButton("Toggle Path Tracing") then
            pt = not pt
            Kismet("Rendering"):EnablePathTracing(pt)
         Kismet("Rendering"):RefreshPathTracingOutput()
        end
    end