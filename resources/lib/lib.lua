--------------------------------------------------------------------------------
-- Localize
--------------------------------------------------------------------------------

local lib = {}

local dusk = require("Dusk.Dusk")
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
            print(errorString )
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
        print( "File error: " .. errorString )
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
        print( "File error: " .. errorString )
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
  
    if result then
        print( "File removed" )
    else
        print( "File does not exist:", reason )
    end
end

lib.file = file

--------------------------------------------------------------------------------
-- savefile functions
--------------------------------------------------------------------------------

local savefile = {}
savefile.current = nil

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
            print("---Something went wrong while making a new saveslot... All 3 savefiles are present.---")
            return false
        end
    end

    -- Read content from default_savefile.json
    local contents = lib.file.read("resources/data/default_savefile.json", system.ResourceDirectory)

    -- Make new savefile
    lib.file.write(filename, system.DocumentsDirectory, contents)
end

function savefile.read(filename)
    -- handle exception
    if not filename then
        print("ERROR: No filename provided in fc(): savefile.read")
        return false
    end

    -- read savefile
    local filePath = 'resources.data.'..filename
    local encoded = lib.file.read( filePath, system.ResourceDirectory)
    local data = json.decode( encoded, "_")

    return data
end

lib.savefile = savefile

--------------------------------------------------------------------------------
-- scene functions
--------------------------------------------------------------------------------

local scene = {}
scene.current = nil

function scene.show(scenePath, options)
    composer.loadScene( scenePath )

    local _scene = composer.getScene( scenePath )
    lib.control.setMode(_scene.type)

    composer.gotoScene(scenePath, options)
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
    physics.setDrawMode("hybrid") -- DEBUG
    physics.setScale( 60 )
    physics.setGravity( 0, 14 )
end

function level.goTo(level)
    -- Localize
    local level = level
    -- get data from current savefile
    local path = "resources/data/"..lib.savefile.current
    local encrypted = file.read(path, system.ResourceDirectory)
    local data = json.decode(encrypted)

    if not level then
        -- variable n has no value -> load last one used (..levels.current)
        level = data.levels.current
    end

    -- load level
    local scenePath = "resources.scene.game."..level..".scene"
    composer.loadScene( scenePath, true)

    -- build map with dusk
    local mapPath = "resources/scene/game/"..level.."/map.json"
    local map = dusk.buildMap(mapPath)

    -- load entities
    --local entities = data.levels[currentLevel]

    -- connect entities with classes
    --map.extend(entities) -- ?
    
    -- copy informations of player in savefile to variables in player.lib

    -- setup and pause physics
    --lib.level.setUpPhysics()

    -- camera positioning

    -- start physics
    --physics.start()

    -- show scene
    lib.scene.show(scenePath) -- Might cause problems, it uses loadScene aswell.
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
        print("ERROR: No table provided to initiateSettings()")
    else
        -- Ist zwar globaler Table, wird aber nur einmal bei Startup gemacht.
        settings.table = table

        -- Es werden alle geladen, da ich denke, lieber mehr RAM benutzen als kritische Zeit während des KeyboardControl() vergeuden.
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
        print("ERROR: No table provided to saveSettings()")
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
        print("ERROR: No inputdevicetype given.")
    end

    -- Changes are all stored together, so not here.
    return keybinds
end

function inputdevice.initiateKeybinds(key)
    keybind.jump = key.jump
    keybind.sneak = key.sneak
    keybind.forward = key.forward
    keybind.backward = key.backward
    keybind.interact = key.interact
    keybind.escape = key.escape
    keybind.primaryWeapon = key.primaryWeapon
    keybind.secondaryWeapon = key.secondaryWeapon
    keybind.inventory = key.inventory
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
            -- Input Device kommt schon vor

            local index = _dir[displayName]
            table.insert(availableInputDevices[index].permanentIds, inputDevice.permanentId)
        else
            -- Input Device kommt noch nicht vor

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
        print("ERROR: device has unkwon type. Origin: lib.lua, l.330")
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
            print("ERROR: No keybinds are stored for this (saved) input device.")
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
                print("INFO: set last used inputdevice")
                -- use last used.
                lib.inputdevice.set(lastDevice, lastType)
                return false
            else
                print("INFO: multiple saved AND available")

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
        print("ERROR: No available inputdevices.")
        return false
    end
end

lib.inputdevice = inputdevice
lib.keybind = keybind

--------------------------------------------------------------------------------
-- control functions
--------------------------------------------------------------------------------

local control = {key = {}, touch = {}, mode=nil}
local moveF, moveB, MoveJ, interact = false, false, false, false

function control.key.menu(event)
    if (event.phase == "up") then
        local keyName = event.keyName
        local next = nil
        local scene = composer.getScene(composer.getSceneName("overlay") or composer.getSceneName("current"))
        local widget = scene.widgetsTable[scene.widgetIndex]
        local keybind = lib.keybind

        if (keyName == keybind.navigateRight) then
            next = widget.navigation[1]

        elseif (keyName == keybind.navigateDown) then
            next = widget.navigation[2]

        elseif (keyName == keybind.navigateLeft) then
            next = widget.navigation[3]

        elseif (keyName == keybind.navigateUp) then
            next = widget.navigation[4]

        elseif (keyName == keybind.interact) then
            widget["function"]()
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
    -- Noch checken ob overlay aktiviert ist. (overlaySceneStatus)
    if (event.phase == "down") then
        if (event.keyName == keybindJump) then
            player:Jump()

        elseif (event.keyName == keybindForward) then
            movF = true
            
        elseif (event.keyName == keybindBackward) then
            movB = true
                 
        elseif (event.keyName == keybindSneak) then
            player.movement["speed"] = 0.3

        elseif (event.keyName == keybindInteract) then
            player:Interact()
        elseif (event.keyName == keybindMeleeAttack) then
            player:MeleeAttack()
        elseif  (event.keyName == keybindEscape) then
            -- Problem: Durch diesen Weg wird status immer "pause", egal ob Overlay geöffnet ist oder nicht.
            handlePauseScreen()
        end
        
    elseif (event.phase == "up") then
        if (event.keyName == keybindJump) then
            --

        elseif (event.keyName == keybindForward) then
            movF = false

        elseif (event.keyName == keybindBackward) then
            movB = false

        elseif (event.keyName == keybindSneak) then
            player.movement["speed"] = 1
            
        end
    end
        
    local vx, vy = player:getLinearVelocity()
    if (movF == movB) then
        vx = 0
    elseif (movF == true) then
        vx = player.movement["speed"]*350
    elseif (movB == true) then
        vx = player.movement["speed"]*-350
    end
    player:setLinearVelocity(vx, vy)
        
    if (overlaySceneStatus == false) then
        if (vx < 0) then
            player.xScale = -1
        elseif (vx > 0) then
            player.xScale = 1
        end
    end
end

function control.touch.menu(event)
    --
end

function control.touch.game(event)
    --
end

function control.setMode(sceneType)
    -- Localize
    local inputType = lib.inputdevice.current.type
    local scene = composer.getScene(composer.getSceneName("overlay") or composer.getSceneName("current"))
    
    -- Rwemove all active Control-Eventlisteners
    Runtime:removeEventListener("key", lib.control.key.menu)
    Runtime:removeEventListener("key", lib.control.key.game)
    Runtime:removeEventListener("touch", lib.control.touch.menu)
    Runtime:removeEventListener("touch", lib.control.touch.game)

    -- Error handling
    if not sceneType then
        print("WARNING: control.setMode(): sceneType is nil.")
        return false
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
            --Runtime:addEventListener("touch", lib.control.touch.menu)

        elseif (sceneType == "game") then
            Runtime:addEventListener("touch", lib.control.touch.game)
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
        --Runtime:addEventListener("touch", lib.control.touch.menu)
        --
    end
end

lib.control = control

-- DEBUG ------------------------------------------------------------------------------

function lib.print(node)
    if (type(node) == "table") then
        -- To print a table if needed. Source: https://gist.github.com/revolucas/dd1ecccfca32d558fddf70ddb39eb8a6
        local cache, stack, output = {},{},{}
        local depth = 1
        local output_str = "{\n"
  
        while true do
            local size = 0
            for k,v in pairs(node) do
                size = size + 1
            end
  
            local cur_index = 1
            for k,v in pairs(node) do
                if (cache[node] == nil) or (cur_index >= cache[node]) then
  
                    if (string.find(output_str,"}",output_str:len())) then
                        output_str = output_str .. ",\n"
                    elseif not (string.find(output_str,"\n",output_str:len())) then
                        output_str = output_str .. "\n"
                    end
  
                    -- This is necessary for working with HUGE tables otherwise we run out of memory using concat on huge strings
                    table.insert(output,output_str)
                    output_str = ""
  
                    local key
                    if (type(k) == "number" or type(k) == "boolean") then
                        key = "["..tostring(k).."]"
                    else
                        key = "['"..tostring(k).."']"
                    end
  
                    if (type(v) == "number" or type(v) == "boolean") then
                        output_str = output_str .. string.rep('\t',depth) .. key .. " = "..tostring(v)
                    elseif (type(v) == "table") then
                        output_str = output_str .. string.rep('\t',depth) .. key .. " = {\n"
                        table.insert(stack,node)
                        table.insert(stack,v)
                        cache[node] = cur_index+1
                        break
                    else
                        output_str = output_str .. string.rep('\t',depth) .. key .. " = '"..tostring(v).."'"
                    end
  
                    if (cur_index == size) then
                        output_str = output_str .. "\n" .. string.rep('\t',depth-1) .. "}"
                    else
                        output_str = output_str .. ","
                    end
                else
                    -- close the table
                    if (cur_index == size) then
                        output_str = output_str .. "\n" .. string.rep('\t',depth-1) .. "}"
                    end
                end
  
                cur_index = cur_index + 1
            end
  
            if (size == 0) then
                output_str = output_str .. "\n" .. string.rep('\t',depth-1) .. "}"
            end
  
            if (#stack > 0) then
                node = stack[#stack]
                stack[#stack] = nil
                depth = cache[node] == nil and depth + 1 or depth - 1
            else
                break
            end
        end
  
        -- This is necessary for working with HUGE tables otherwise we run out of memory using concat on huge strings
        table.insert(output,output_str)
        output_str = table.concat(output)
  
        print(output_str)

    elseif (type(node) == "string") or (type(node) == "number") then
        print(node)
    end
end
--------------------------------------------------------------------------------

return lib