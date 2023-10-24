local lib = require( "resources.lib.lib" )

-- setup settings
lib.settings.onStartup()

-- add multitouch
system.activate( "multitouch" )

-- setup inputdevices
local isInputdevicemenuOpen = lib.inputdevice.onStartup()
if not isInputdevicemenuOpen then
    lib.scene.show("resources.scene.menu.mainmenu", { effect = "fade", time = 800,})
end