if imgui.button("cycle vt") then
        pc:UnPossess()
        oldvt = pc:GetViewTarget()
         cameraman = pc.PlayerCameraManager
        skms = skms or {}
        if #skms == 0 then skms = ("SkinnedMeshComponent"):find_all_instances(false) else

         set_view_target(skms[#skms]:get_outer())
         table.remove(skms, #skms)
     end
     end
   if imgui.button("Add camera actor") then

          oldvt = pc:GetViewTarget()
         cameraman = pc.PlayerCameraManager

         local temp = SpawnActor("Class /Script/Engine.CameraActor", pc)
         temp:set_lifespan(10, true)
         cameraman.AnimCameraActor = temp
         pc:ClientMessage("Test Message", UEVR_FName.new())
         if sphere then

          temp:set_location(sphere:location())
          temp:attach(sphere)
         end
         pc:ClientSetViewTarget(temp,  FViewTargetTransitionParams())

          wait_for_object_death(temp)
          if not temp then
         pc:ClientSetViewTarget(oldvt,  FViewTargetTransitionParams())
     end