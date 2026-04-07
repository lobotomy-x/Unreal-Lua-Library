local game_info = nil
function GetGameInfo()
    game_info = game_info or {
        name = Kismet("System"):GetGameName(),
        commandline = Kismet("System"):GetCommandLine(),
        projectDir =    Kismet("System"):GetProjectDirectory(),
        projectContentDir =  Kismet("System"):GetProjectContentDirectory(),
        savedDir = Kismet("System"):GetProjectSavedDirectory(),
        version = Kismet("System"):GetEngineVersion()
    }
    return game_info
end
