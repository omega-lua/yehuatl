-- Hier ist sozusagen die programm-loop, was vorher in main.lua und game.lua passierte.

-- Lokalisieren

-- Library nicht lokalisieren??????
library = require("library")
local composer = require("composer")

runtime = {}
runtime["currentSaveFile"] = nil

-- settingsfiles Setup and Initialication
local state = library.doesFileExist("settings.json", system.DocumentsDirectory)
if (state == false) then
    print("--settings.json not found--")
    local data = library.resetSettings()
    library.initiateSettings(data)
    runtime["settings"] = data
else
    local path = system.pathForFile( "settings.json" , system.DocumentsDirectory )
    print("--settings.json found--")
    local data = library.getSettings(path)
    library.initiateSettings(data)
    runtime["settings"] = data
end


movF, movB, movJ, interact = false, false, false, false
function handleKeyInput(event)
    library.keyboardControl(event)
end


-- Gotoscene()
composer.gotoScene( "resources.scene.menu.mainmenu")

Runtime:addEventListener("key", handleKeyInput)