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
    -- clear unnecessary data
    runtime.settings.controls.keybinds.controller = nil
    runtime.settings.controls.keybinds.keyboard = nil
    runtime.settings.controls.keybinds.touchscreen = nil
else
    local path = system.pathForFile( "settings.json" , system.DocumentsDirectory )
    print("--settings.json found--")
    local data = library.getSettings(path)
    library.initiateSettings(data)
    runtime["settings"] = data
end

-- "global" scene variables
runtime["currentSaveFile"] = nil
runtime.currentScene = "mainmenu"
runtime.currentSceneType = "menu"

-- "global" input device variables
runtime.currentInputDevice = nil
runtime.currentInputDeviceType = nil

-- Maybe store as player.variable
movF, movB, movJ, interact = false, false, false, false

library.handleSceneChange("resources.scene.menu.mainmenu", "menu",{ effect = "fade", time = 1600,})

-- initialization of inputDevice-handling
library.initiateInputDevices()