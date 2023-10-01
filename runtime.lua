local lib = require( "resources.lib.lib" )

-- setup settings
lib.settings.onStartup()

-- setup inputdevices
local isInputdevicemenuOpen = lib.inputdevice.onStartup()
if not isInputdevicemenuOpen then
    lib.scene.show("resources.scene.menu.mainmenu", { effect = "fade", time = 1600,})
end