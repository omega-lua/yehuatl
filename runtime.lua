-- Hier ist sozusagen die programm-loop, was vorher in main.lua und game.lua passierte.

-- Lokalisieren

-- Library nicht lokalisieren?????? Ausserdem ist require ja jedesmal ein File-read => Stromverbauch...
library = require("library")
local composer = require("composer")
runtime = {}

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

runtime["currentSaveFile"] = nil
runtime.currentScene = nil
runtime.currentSceneType = nil
runtime.selectedInputDevice = runtime.settings.selectedInputDevice

-- Maybe store as player.variable
movF, movB, movJ, interact = false, false, false, false

-- Gotoscene()
composer.gotoScene("resources.scene.menu.mainmenu")
library.setControlMode("menu")