--------------------------------------------------------------------------------
-- Localize
--------------------------------------------------------------------------------

local lib = {}

local composer = require( "composer" )
local json = require( "json" )
local physics = require( "physics" )

--------------------------------------------------------------------------------
-- file functions
--------------------------------------------------------------------------------

local file = {}

function file.doesExist( filename, path )
    local results = false
 
    -- Path for the file
    local filePath = system.pathForFile( filename, path )
 
    if ( filePath ) then
        local _file, errorString = io.open( filePath, "r" )
 
        if not _file then
            -- Error occurred; output the cause
            -- print( errorString )
        else
            -- File exists!
            results = true
            -- Close the _file handle
            _file:close()
        end
    end
 
    return results
end

function file.write(path, dir, contents)
    -- 2. Make new SaveFile
    local absPath = system.pathForFile(path, dir)
    local file, errorString = io.open( absPath, "w+" )
    if not file then
        -- Error occurred; output the cause
        -- print( "File error: " .. errorString )
    else
        -- Write data to file
        file:write( contents )
        -- Close the file handle
        io.close( file )
    end
    
    file = nil
end

function file.read(path, dir)
    local contents = nil
    -- Open savefile
    local absPath = system.pathForFile(path, dir)
    local file, errorString = io.open( absPath, "r" )
    if not file then
        -- Error occurred; output the cause
        -- print( "File error: " .. errorString )
        file = nil
        return contents, errorString
    else
        -- Read data
        contents = file:read("*a")
        -- Close the file handle
        io.close( file )
        file = nil
        return contents
    end
end

function file.delete(filename)
    local result, reason = os.remove( system.pathForFile( filename, system.DocumentsDirectory ) )
end

lib.file = file

--------------------------------------------------------------------------------
-- savefile functions
--------------------------------------------------------------------------------

local savefile = {}
savefile.current = {name=nil, data={}}

function savefile.new(filename)
    local contents = nil
    
    -- Searches for available filename
    if not filename then
        -- Find out which savefiles already exist
        local saveFile1 = lib.file.doesExist("savefile1.json", system.DocumentsDirectory)
        local saveFile2 = lib.file.doesExist("savefile2.json", system.DocumentsDirectory)
        local saveFile3 = lib.file.doesExist("savefile3.json", system.DocumentsDirectory)
        
        -- Give the new savefile a name not already used (1-3)
        if (saveFile1 == false) then
            filename = "savefile1.json"
        elseif (saveFile2 == false) then
            filename = "savefile2.json"
        elseif (saveFile3 == false) then
            filename = "savefile3.json"
        else 
            return false
        end
    end

    -- Read content from default_savefile.json
    local contents = lib.file.read("resources/data/default_savefile.json", system.ResourceDirectory)

    -- Make new savefile
    lib.file.write(filename, system.DocumentsDirectory, contents)
end

lib.savefile = savefile

--------------------------------------------------------------------------------
-- scene functions
--------------------------------------------------------------------------------

local scene = {}
scene.current = nil

function scene.show( scenePath, options, isOverlay )
    composer.loadScene( scenePath )

    local _scene = composer.getScene( scenePath )
    lib.control.setMode(_scene.type)

    if isOverlay then
        composer.showOverlay( scenePath, options )
    else
        composer.gotoScene( scenePath, options )
    end
end

lib.scene = scene

--------------------------------------------------------------------------------
-- level functions
--------------------------------------------------------------------------------

local level = {}
level.current = nil

function level.setUpPhysics()
    physics.start() -- physics first startup
    physics.pause() -- pause physics for setup
    physics.setScale( 35 )
    physics.setGravity( 0, 9.81 )
end

function level.save()
    local scene = composer.getScene(composer.getSceneName("current"))
    local savefile = lib.savefile.current.data
    local map = scene.map

    -- get data of entities
    local entities = {}
    for object in map.layer['entities'].objects() do
        local t = {}
        t.x, t.y = object.x, object.y
        t.health = object.health
        t.isDead = object.isDead
        t.inventory = object.inventory

        entities[object._name] = t
    end

    -- get data of player (x and y values are stored in entities, so they are stored in level data.)
    local player = map.layer["entities"].object['player']
    local Player = require("resources.lib.player")
    local p = {}
    p.isDead = player.isDead or "nil"
    p.attributes = Player.attributes or {}
    p.inventory = Player.inventory or {}
    p.name = Player.name or "nil"

    -- get story progress
    --

    -- store in savefile table
    local savefile = lib.savefile.current.data
    local currentLevel = lib.level.current
    savefile.player = p
    savefile.levels.current = currentLevel
    savefile.levels[currentLevel] = {}
    savefile.levels[currentLevel].entities = e

    -- save table to savefile
    local name = lib.savefile.current.name
    local encoded = json.encode(savefile, {indent=true})
    lib.file.write(name, system.DocumentsDirectory, encoded)
end

function level.load(level)
    -- Localize
    local encoded = file.read(lib.savefile.current.name, system.DocumentsDirectory)
    local savefile = json.decode(encoded)
    lib.savefile.current.data = savefile

    -- if no variable is given to the function, load current (-> last used) level again.
    if not level then
        local current = savefile.levels.current
        if (current == "nil") then
            savefile.levels.current = "level1"
        end
        level = savefile.levels.current
    end

    -- show scene
    local scenePath = "resources.scene.game."..level..".scene"
    lib.scene.show(scenePath)
    lib.level.current = level
end

lib.level = level

--------------------------------------------------------------------------------
-- settings functions
--------------------------------------------------------------------------------

local settings = {}
settings.table = {}
settings.tmpTable = {}

function settings.initiate(table)
    if not table then
        --print("ERROR: No table provided to initiateSettings()")
    else
        settings.table = table

        selectedInputDevice = settings.table.selectedInputDevice
        otherInputDevices = settings.table.otherInputDevices

        volumeMusic = settings.table.volumeMusic
        volumeSoundEffects = settings.table.volumeSoundEffects
        selectedOutputDevice = settings.table.selectedOutputDevice
        otherOutputDevices = settings.table.otherOutputDevices
        playStereo = settings.table.playStereo
        renderParticles = settings.table.renderParticles
        cameraDamping = settings.table.cameraDamping
        difficulty = settings.table.difficulty
    end
end

function settings.save(table)
    if table then
        -- json.encode
        local encoded = json.encode(table, { indent=true })

        -- Write file
        lib.file.write("settings.json", system.DocumentsDirectory, encoded)
    else
        --print("ERROR: No table provided to saveSettings()")
    end
end

function settings.reset()
    -- Get data from initial_setting.json
    local encoded = lib.file.read("resources/data/default_settings.json", system.ResourceDirectory)
    local data = json.decode(encoded)

    -- Save data
    settings.save(data)

    -- Load resetted settings
    settings.initiate(data)
    return data
end

function settings.onStartup()
    local data = nil
    local doesExist = lib.file.doesExist("settings.json", system.DocumentsDirectory)
    if doesExist then
        local encoded = lib.file.read("settings.json", system.DocumentsDirectory)
        data = json.decode(encoded)
    else
        data = settings.reset()
    end
    settings.table = data
    settings.initiate(data)
end

lib.settings = settings

--------------------------------------------------------------------------------
-- inputdevice / keybind functions
--------------------------------------------------------------------------------

local keybind = {}
local inputdevice = {}
inputdevice.current = {name=nil, type=nil}
inputdevice.available = {}

function inputdevice.createKeybinds(inputDeviceType)
    -- get default_settings from ResourceDirectory
    local encoded = lib.file.read("resources/data/default_settings.json", system.ResourceDirectory)
    local default_settings = json.decode(encoded)

    if inputDeviceType then
        keybinds = default_settings.controls.keybinds[inputDeviceType]
    else
        --("ERROR: No inputdevicetype given.")
    end

    return keybinds
end

function inputdevice.initiateKeybinds(key)
    keybind.jump = key.jump
    keybind.forward = key.forward
    keybind.backward = key.backward
    keybind.interact = key.interact
    keybind.escape = key.escape
    keybind.meleeAttack = key.meleeAttack
    keybind.rangedAttack = key.rangedAttack
    keybind.ability  = key.ability
    keybind.block  = key.block
    keybind.navigateLeft = key.navigateLeft
    keybind.navigateRight = key.navigateRight
    keybind.navigateUp = key.navigateUp
    keybind.navigateDown = key.navigateDown
end

function inputdevice.getAvailable()
    -- Localize
    local inputDevices = system.getInputDevices()
    local availableInputDevices = {}
    local _dir = {}
    
    -- Iterate through inputDevices
    for index = 1, #inputDevices do
        local inputDevice = inputDevices[index]
        local displayName = inputDevice.displayName

        if (_dir[displayName]) then
            -- input device already in _dir

            local index = _dir[displayName]
            table.insert(availableInputDevices[index].permanentIds, inputDevice.permanentId)
        else
            -- input device not in _dir

            -- create subtable
            local array = {}
            array.displayName = displayName
                
            -- store permanentIds
            array.permanentIds = {}
            table.insert(array.permanentIds, inputDevice.permanentId)

            -- Get type of input Device
            array.type = inputDevice.type

            -- Set array to the big table
            table.insert(availableInputDevices, array)

            -- Update _dir
            _dir[displayName] = #availableInputDevices
        end
    end

    return availableInputDevices
end

function inputdevice.getLastUsed()
    -- Localize
    local savedInputDevices = lib.settings.table.controls.inputDevice.saved
    local maxn, lastDevice, lastType = 0, nil, nil

    for name, parameters in pairs(savedInputDevices) do
        if parameters.lastUsed and (parameters.lastUsed > maxn) then
            maxn = parameters.lastUsed
            lastDevice = name
            lastType = parameters.type
        end
    end

    return lastDevice, lastType
end

function inputdevice.remember(deviceName, deviceType)
    -- Localize
    local controls = lib.settings.table.controls
    local keybinds = {}

    -- InputDevice is not saved
    if (deviceType == "unkown") then
        -- print("ERROR: device has unkwon type. Origin: lib.lua, l.330")
        --composer.showOverlay("resources.scene.menu.inputdevicemenu", {isModal=true, effect="fade", time=400})
        return
    else
        -- Type is known. Make new, typespecific keybinds
        keybinds = lib.inputdevice.createKeybinds(deviceType)
        -- add keybinds to keybinds table
        controls.keybinds[deviceName] = keybinds
        -- add input device to saved
        controls.inputDevice.saved[deviceName] = {}
        controls.inputDevice.saved[deviceName].type = deviceType

        -- Set changes in table
        lib.settings.table.controls = controls
    end

    return keybinds
end

function inputdevice.forget(deviceName)
    -- 1. Get which inputdevice to forget
    local deviceName = deviceName
    local controls = lib.settings.table.controls
    local savedInputDevices = controls.inputDevice.saved

    -- 2. Delete selected inputdevice out of controls.keybinds.
    controls.keybinds[deviceName] = nil

    -- 3. Delete selected inputdevice out of controls.inputdevice.saved
    controls.inputDevice.saved[deviceName] = nil

    -- 4. Check if selected inputdevice is inputdevice.current
    if (controls.inputDevice.current == deviceName) then
        -- if yes, change inputdevice.current to last Used ?
        controls.inputDevice.current = nil
    end

    -- 5. Set changes to lib.settings.table
    lib.settings.table.controls = controls

    -- 6. Save changes
    lib.settings.save(lib.settings.table)
end

function inputdevice.set(deviceName, deviceType)
    -- Localize
    local savedInputDevices = lib.settings.table.controls.inputDevice.saved
    local isSaved = (savedInputDevices[deviceName] ~= nil)
    local deviceType = deviceType
    local keybinds = {}

    if isSaved then
        if not keybinds then
            --print("ERROR: No keybinds are stored for this (saved) input device.")
            return false
        end
        keybinds = lib.settings.table.controls.keybinds[deviceName]
    else
        keybinds = lib.inputdevice.remember(deviceName, deviceType)
    end

    -- set variables
    lib.inputdevice.current.name = deviceName
    lib.inputdevice.current.type = deviceType
    lib.settings.table.controls.inputDevice.current = deviceName
    lib.settings.table.controls.inputDevice.saved[deviceName].lastUsed = os.time() 
    -- Save changes in settings.json
    lib.settings.save(lib.settings.table)
    -- initiate keybinds
    lib.inputdevice.initiateKeybinds(keybinds)
end

function inputdevice.onStartup()
    -- Localize
    local availableInputDevices = inputdevice.getAvailable()
    local savedInputDevices = settings.table.controls.inputDevice.saved
    settings.table.controls.inputDevice.alwaysLastUsed = false -- DEBUG

    if availableInputDevices then
        -- Get count of crossmatches between those two tables
        local n, device = 0, nil
        for name, saved in pairs(savedInputDevices) do
            for j, available in pairs(availableInputDevices) do
                if (name == available.displayName) then
                    n = n + 1
                    device = name
                end
            end
        end

        if (n == 1) then
            -- if theres only one crossmatch, use this input device and return.
            lib.inputdevice.set(device, savedInputDevices[device].type)
            return false
        
        elseif (n > 1) then
            -- Get last used of saved input device.
            local lastDevice, lastType = inputdevice.getLastUsed()

            if lib.settings.table.controls.inputDevice.alwaysLastUsed then
                --print("INFO: set last used inputdevice")
                -- use last used.
                lib.inputdevice.set(lastDevice, lastType)
                return false
            else
                --print("INFO: multiple saved AND available")

                lib.inputdevice.set(lastDevice, lastType)
                -- show menu.
                lib.scene.show("resources.scene.menu.inputdevicemenu", {time=400, effect="fade"})
                return true
            end
        else
            -- no inputdevices (saved AND available)
            -- Show menu
            lib.inputdevice.set("keyboard", "keyboard")
            -- Controller?
            lib.scene.show("resources.scene.menu.inputdevicemenu", {time=400, effect="fade"})
            return true
        end
    else
        --print("ERROR: No available inputdevices.")
        return false
    end
end

lib.inputdevice = inputdevice
lib.keybind = keybind

--------------------------------------------------------------------------------
-- control functions
--------------------------------------------------------------------------------

local control = {key = {}, touch = {}, mode=nil}

function control.key.menu(event)
    if (event.phase == "up") then
        -- Localize
        local keyName = event.keyName
        local next = nil
        local scene = composer.getScene(composer.getSceneName("overlay") or composer.getSceneName("current")) or {}
        local widgetsTable = scene.widgetsTable or {}
        local widget = widgetsTable[scene.widgetIndex] or {}
        local navigation = widget.navigation or {}
        local keybind = lib.keybind

        if (keyName == keybind.navigateRight) then
            next = navigation[1]

        elseif (keyName == keybind.navigateDown) then
            next = navigation[2]

        elseif (keyName == keybind.navigateLeft) then
            next = navigation[3]

        elseif (keyName == keybind.navigateUp) then
            next = navigation[4]

        elseif (keyName == keybind.interact) then
            if widget['function'] then widget["function"]() end
        elseif (keyName == keybind.escape) then
            scene:dispatchEvent({ name="interaction", target={id="buttonBack"}, phase="ended"})
        end

        -- For normal navigation
        if ( type( next ) == "number" ) then
            scene.widgetIndex = next
            scene:updateUI()
       
        -- For segments and switches
        elseif ( type( next ) == "function" ) then
            next()
        end
    end
end

function control.key.game(event)
    -- Localize
    local phase = event.phase
    local keyName = event.keyName
    local keybind = lib.keybind
    local scene = composer.getScene( composer.getSceneName( 'current' ))
    local map = scene.map
    local player = map.layer["entities"].object['player']
    
    if (phase == "down") then
        if (keyName == keybind.jump) then
            player.pressingJump = true
            player:jump()

        elseif (keyName == keybind.forward) then
            player.pressingForward = true
            
        elseif (keyName == keybind.backward) then
            player.pressingBackward = true
                 
        elseif (keyName == keybind.sneak) then
            player.isSneaking = true

        elseif (keyName == keybind.interact) then
            player:interact()
        elseif (keyName == keybind.meleeAttack) then
            player:meleeAttack()
        elseif (keyName == keybind.rangedAttack) then
            player:rangedAttack()
        elseif (keyName == keybind.block) then
            player:block('begin')
        
        elseif (keyName == keybind.escape) then
            scene:pause()
        end
        
    elseif (phase == "up") then
        if (keyName == keybind.jump) then
            player.pressingJump = false

        elseif (keyName == keybind.forward) then
            player.pressingForward = false

        elseif (keyName == keybind.backward) then
            player.pressingBackward = false

        elseif (keyName == keybind.sneak) then
            player.isSneaking = false
        elseif (keyName == keybind.block) then
            player:block('cancel')
        end
    end

    player:handleMovement()
end

function control.touch.menu(event)
    -- gets handled directly by the buttons and handleInteraction()
end

function control.touch.game(event)
    local target = event.target
    local command = target.command
    local phase = event.phase

    -- Cancel unwanted event-phase
    if phase == 'moved' then return false end

    local scene = composer.getScene( composer.getSceneName( 'current' ) )
    local map = scene.map
    local player = map.layer["entities"].object['player']

    if phase == 'began' then
        -- visual
        display.getCurrentStage():setFocus( event.target, event.id )
        target.alpha = 0.5
        
        if command == 'jump' then
            player:jump()
            player.pressingJump = true

        elseif command == 'pressingBackward' or command == 'pressingForward' then
            player[command] = true
            player:handleMovement()

        elseif command == 'meleeAttack' then
            player:meleeAttack()
        elseif command == 'rangedAttack' then
            player:rangedAttack()
        elseif command == 'block' then
            player:block('begin')
        elseif command == 'ability' then
            player:ability()
        elseif command == 'pause' then
            -- doesnt get handled
        elseif command == 'interact' then
            player:interact()
        end

    elseif phase == 'ended' then
        -- visual
        display.getCurrentStage():setFocus( event.target, nil )
        target.alpha = 1

        if command == 'jump' then
            player.pressingJump = false

        elseif command == 'pressingBackward' or command == 'pressingForward' then
            target.alpha = 1
            player[command] = false
            player:handleMovement()

        elseif command == 'meleeAttack' then
            -- doesnt get handled
        elseif command == 'rangedAttack' then
            -- doesnt get handled
        elseif command == 'block' then
            player:block('cancel')
        elseif command == 'ability' then
            -- doesnt get handled
        elseif command == 'interact' then
            -- doesnt get handled
        elseif command == 'pause' then
            scene:pause()
        end
    end
end

function control.setMode(sceneType, deactivateControls)
    -- Localize
    local inputType = lib.inputdevice.current.type
    local scene = composer.getScene(composer.getSceneName("overlay") or composer.getSceneName("current"))
    
    -- Remove all active Control-Eventlisteners
    Runtime:removeEventListener("key", lib.control.key.menu)
    Runtime:removeEventListener("key", lib.control.key.game)
    Runtime:removeEventListener("touch", lib.control.touch.menu)
    Runtime:removeEventListener("touch", lib.control.touch.game)

    if deactivateControls then
        -- removes all eventListeners, but doesnt add the current. So no controls.
        return true
    end

    if not sceneType then
        sceneType = scene.type
    end

    if (inputType == "keyboard") then
        lib.control.mode = "key"
        if (sceneType == "menu") then
            Runtime:addEventListener("key", lib.control.key.menu)

        elseif (sceneType == "game") then
            Runtime:addEventListener("key", lib.control.key.game)
        end
    
    elseif (inputType == "touchscreen") then
        lib.control.mode = "touch"
        if (sceneType == "menu") then
            -- Gets handled directly by the buttons and handleInteraction()

        elseif (sceneType == "game") then
            -- We dont need global eventListener for ingame-touch, the buttons
            -- call control.touch.game when touch input occurs.
        end
    elseif (inputType == "controller") then
        lib.control.mode = "key"
        if (sceneType == "menu") then
            Runtime:addEventListener("key", lib.control.key.menu)

        elseif (sceneType == "game") then
            Runtime:addEventListener("key", lib.control.key.game)
        end
    elseif not inputType then
        lib.control.mode = "unkown"
        -- inputtype unknown, add all eventListeners.

        Runtime:addEventListener("key", lib.control.key.menu)
    end
end

lib.control = control

--------------------------------------------------------------------------------

return lib