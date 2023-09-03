-- library.lua stores all applicationwide functions and variables,
-- which otherwise would be found in main.lua

--------------------------------------------------------------------------------
-- Localize
--------------------------------------------------------------------------------
local library = {}

local require = require
local json = require("json")
local physics = require( "physics" )
local composer = require( "composer" )
composer.isDebug = true
--------------------------------------------------------------------------------
-- Functions
--------------------------------------------------------------------------------

-- DEBUG: To print a table if needed. Source: https://gist.github.com/revolucas/dd1ecccfca32d558fddf70ddb39eb8a6
function printTable(node)
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
end

function doesFileExist( filename, path )
    -- From Solar2D-Guide: https://docs.coronalabs.com/guide/data/readWriteFiles/index.html#testing-if-files-exist
    local results = false
 
    -- Path for the file
    local filePath = system.pathForFile( filename, path )
 
    if ( filePath ) then
        local file, errorString = io.open( filePath, "r" )
 
        if not file then
            -- Error occurred; output the cause
            print(errorString )
        else
            -- File exists!
            results = true
            -- Close the file handle
            file:close()
        end
    end
 
    return results
end

function readFile(path)
    local contents = nil

    -- 1. Open savefile
    local file, errorString = io.open( path, "r" )
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

function deleteFile(filename)
    local result, reason = os.remove( system.pathForFile( filename, system.DocumentsDirectory ) )
  
    if result then
        print( "File removed" )
    else
        print( "File does not exist:", reason )
    end
end

function writeFile(path, contents)
    -- 2. Make new SaveFile
    local file, errorString = io.open( path, "w+" )
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

function loadSaveFile(filename)
    local path = system.pathForFile(filename, system.DocumentsDirectory)
    local contents = library.readFile(path)

    -- 2. Decode JSON-file
    decoded, pos, msg = json.decode(contents, 1, "emptyTable")

    -- 3. Set Variabels
    if decoded then
        -- 3.1 Set map-Variable
        currentMapPath = decoded['environmentData']['map']

        -- 3.2 Set other Variables
        playerData = decoded["playerData"]
        environmentData = decoded["environmentData"]

    else
        print( "Decode failed at "..tostring(pos)..": "..tostring(msg) )
    end
end

-- Generates new savefile or overwrites existing savefile with content from initial.json
function newSaveFile(filename)
    local contents = nil
    
    -- Searches for available filename
    if not filename then
        -- Find out which savefiles already exist
        local saveFile1 = library.doesFileExist("save1.json", system.DocumentsDirectory)
        local saveFile2 = library.doesFileExist("save2.json", system.DocumentsDirectory)
        local saveFile3 = library.doesFileExist("save3.json", system.DocumentsDirectory)
        
        -- Give the new savefile a name not already used (1-3)
        if (saveFile1 == false) then
            filename = "save1.json"
        elseif (saveFile2 == false) then
            filename = "save2.json"
        elseif (saveFile3 == false) then
            filename = "save3.json"
        else 
            print("---Something went wrong while making a new saveslot... All 3 savefiles are present.---")
            return false
        end
    end

    -- Read content from initial.json
    local path = system.pathForFile( "resources/data/initial.json", system.ResourceDirectory )
    local contents = library.readFile(path)

    -- Make new savefile
    local path = system.pathForFile( filename, system.DocumentsDirectory )
    library.writeFile(path, contents)
end

function getSettings(path)
    -- Read file
    local data = library.readFile(path)
    
    -- decode data
    local decoded = json.decode(data, 1, "emptyTable")
    
    return decoded
end

function initiateSettings(table)
    if not table then
        print("ERROR: No table provided to initiateSettings()")
    else
        -- Ist zwar globaler Table, wird aber nur einmal bei Startup gemacht.
        runtime.settings = table

        -- Es werden alle geladen, da ich denke, lieber mehr RAM benutzen als kritische Zeit während des KeyboardControl() vergeuden.
        selectedInputDevice = runtime.settings.selectedInputDevice
        otherInputDevices = runtime.settings.otherInputDevices

        volumeMusic = runtime.settings.volumeMusic
        volumeSoundEffects = runtime.settings.volumeSoundEffects
        selectedOutputDevice = runtime.settings.selectedOutputDevice
        otherOutputDevices = runtime.settings.otherOutputDevices
        playStereo = runtime.settings.playStereo
        renderParticles = runtime.settings.renderParticles
        cameraDamping = runtime.settings.cameraDamping
        difficulty = runtime.settings.difficulty
    end
end

-- DEBUG,
function setUpInitialSettings()
    local data = {}

    local encoded = json.encode(data, {indent=true})

    local path = system.pathForFile( "resources/data/default_settings.json", system.ResourceDirectory )
    library.writeFile(path, encoded)
end
-- Speichert
function saveSettings(table)
    if table then
        -- json.encode
        local encoded = json.encode(table, { indent=true })

        -- Write file
        local path = system.pathForFile( "settings.json", system.DocumentsDirectory )
        library.writeFile(path, encoded)
    else
        print("ERROR: No table provided to saveSettings()")
    end
end

function resetSettings()
    -- Get data from initial_setting.json
    local path = system.pathForFile( "resources/data/default_settings.json", system.ResourceDirectory )
    local data = library.getSettings(path)

    -- Save data
    library.saveSettings(data)
    return data
end

function getAvailableInputDevices()
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

    runtime.availableInputDevices = availableInputDevices
    return availableInputDevices
end

function createKeybinds(inputDeviceType)
    -- get default_settings from ResourceDirectory
    local path = system.pathForFile( "resources/data/default_settings.json", system.ResourceDirectory )
    local default_settings = library.getSettings(path)
    
    if inputDeviceType == "controller" then
        keybinds = default_settings.controls.keybinds.controller
    elseif inputDeviceType == "keyboard" then
        keybinds = default_settings.controls.keybinds.keyboard
    elseif inputDeviceType == "touchscreen" then
        keybinds = default_settings.controls.keybinds.touchscreen
    else print("ERROR: unkown or unsupported Input Device Type") return end

    -- Changes are all stored together, so not here.
    return keybinds
end

function initiateKeybinds(key)

    keybindJump = key.jump
    keybindSneak = key.sneak
    keybindForward = key.forward
    keybindBackward = key.backward
    keybindInteract = key.interact
    keybindEscape = key.escape
    keybindPrimaryWeapon = key.primaryWeapon
    keybindSecondaryWeapon = key.secondaryWeapon
    keybindInventory = key.inventory
    keybindAbility  = key.ability
    keybindBlock  = key.block
    keybindNavigateLeft = key.navigateLeft
    keybindNavigateRight = key.navigateRight
    keybindNavigateUp = key.navigateUp
    keybindNavigateDown = key.navigateDown
end

function setInputDevice(displayName, inputDeviceType)
    -- Localize
    local savedInputDevices = runtime.settings.controls.inputDevice.saved
    local isSaved = (savedInputDevices[displayName] ~= nil)
    local inputDeviceType = inputDeviceType --or savedInputDevices[displayName]
    local keybinds = {}

    if isSaved then
        -- InputDevice is saved, get keybinds from settings
        keybinds = runtime.settings.controls.keybinds[displayName]
    else
        -- InputDevice is not saved
        if (inputDeviceType == "unkown") then
            composer.showOverlay("resources.scene.menu.inputdeviceoverlay", {isModal=true, effect="fade", time=400})
            return
        else
            -- Type is known. Make new, typespecific keybinds
            keybinds = library.createKeybinds(inputDeviceType)
            -- add keybinds to keybinds table
            runtime.settings.controls.keybinds[displayName] = keybinds
            -- add input device to saved
            runtime.settings.controls.inputDevice.saved[displayName] = inputDeviceType
        end
    end

    -- set runtime.currentInputDevice
    runtime.currentInputDevice = displayName
    runtime.currentInputDeviceType = inputDeviceType

    -- set settings.controls.inputDevice.current in settings.json
    runtime.settings.controls.inputDevice.current = displayName

    -- update controlMode
    library.setControlMode(runtime.currentSceneType)

    -- Save changes in settings.json
    library.saveSettings(runtime.settings)

    -- initiate keybinds
    library.initiateKeybinds(keybinds)
end

function initiateInputDevices()
    -- Localize
    local availableInputDevices = library.getAvailableInputDevices()

    if #availableInputDevices == 1 then
        print("only one input device found")
        local displayName = availableInputDevices[1].displayName
        local inputDeviceType = availableInputDevices[1].type
        library.setInputDevice(displayName, inputDeviceType)
    elseif #availableInputDevices > 1 then
        -- if only one saved input device is found in availableInputDevices, use this one. Inefficient.
        local temp_available = {}
        local temp_saved = {}
        local n, name = 0, nil
        for k,v in pairs(availableInputDevices) do
            table.insert(temp_available, availableInputDevices[k].displayName)
        end
        for k,v in pairs(runtime.settings.controls.inputDevice.saved) do
            table.insert(temp_saved, k)
        end
        for i=1, #temp_saved do
            if (table.indexOf( temp_available, temp_saved[i] )) then
                print("true")
                n = n + 1
                name = temp_saved[i]
            end
        end
        if (n == 1) then
            print("only one device saved AND available.")
            local inputDeviceType = runtime.settings.controls.inputDevice.saved[name]
            library.setInputDevice(name, inputDeviceType)
            return
        end

        -- activate all keybinds!!!!
        
        -- show Overlay
        composer.showOverlay( "resources.scene.menu.inputdeviceoverlay", {isModal=true, effect="fade", time=400})

    elseif #availableInputDevices == 0 then
        print("ERROR: No input devices found.")
    end
end

function initiatePhysics()
    physics.start() -- physics first startup
    physics.pause() -- pause physics for setup
    physics.setDrawMode("hybrid") -- DEBUG
    physics.setScale( 60 )
    physics.setGravity( 0, 14 )
end

function terminatePhysics()
    physics.stop()
end

function navigateGame(event)
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

function touchscreenControl(event)
    if (event.phase == "began") then
        if (event.target == ButtonForward) then
            movF = true
        elseif (event.target == ButtonForward) then
            --
        end
    elseif (event.phase == "ended") or (event.phase == "cancelled") then
        --
    end
end

function createNavigationMatrix()
    -- Localize
    local sqrt = math.sqrt
    local scene = composer.getScene(composer.getSceneName("overlay") or composer.getSceneName("current"))
    local widgetsTable = scene.widgetsTable
    local matrix, array = {}, {}

    -- Get all coordinates from interactable widgets
    for i, object in pairs(scene.widgetsTable) do
        if object.isInteractable then
            local x, y = object.pointer:localToContent(0,0)
            --local x, y = scene.widgetsTable[i].creation.x, scene.widgetsTable[i].creation.y
            array[i] = {x,y}
        end
    end

    
    for i, c in pairs(array) do
        local ix, iy = c[1], c[2]
        local a,b,c,d = "nil", "nil", "nil", "nil"
        local minA, minB, minC, minD = 5000, 5000, 5000, 5000
        local _lookup = {["a"]={}, ["b"]={}, ["c"]={}, ["d"]={}}
        
        -- get deltas
        for j, k in pairs(array) do
            if (i ~= j) then
                local jx, jy = k[1], k[2]

                if ix < jx then
                    local dx, dy = (ix-jx)*0.2, (iy-jy)
                    local delta = sqrt(dx*dx*0.2+dy*dy)               
                    if delta < minA then 
                        a = j
                        minA = delta
                    end
                end
                if ix > jx then
                    local dx, dy = (ix-jx)*0.2, (iy-jy)
                    local delta = sqrt(dx*dx+dy*dy)
                    if delta < minC then
                        c = j
                        minC = delta
                    end
                end
                if iy < jy then
                    local dx, dy = (ix-jx), (iy-jy)*0.2
                    local delta = sqrt(dx*dx+dy*dy)
                    if delta < minB then
                        b = j
                        minB = delta
                    end
                end
                if iy > jy then
                    local dx, dy = (ix-jx), (iy-jy)*0.2
                    local delta = sqrt(dx*dx+dy*dy)
                    if delta < minD then
                        d = j
                        minD = delta
                    end
                end

            end
        end

        -- handle no navigationindex
        if (a == nil) then
            --
        end
        if (b == nil) then
            --
        end
        if (c == nil) then
            --
        end
        if (d == nil) then
            --
        end
        print("---------------------",a,b,c,d)
        matrix[i] = {a,b,c,d}
    end
    return matrix
end

function setNavigationMatrix(matrix)
    local scene = composer.getScene(composer.getSceneName("overlay") or composer.getSceneName( "current" ) )
    for i, object in pairs(matrix) do
        scene.widgetsTable[i].navigation = matrix[i]
    end
end

function keyNavigation(event)
    if (event.phase == "up") then
        local keyName = event.keyName
        local nextIndex = nil
        local scene = composer.getScene(composer.getSceneName("overlay") or composer.getSceneName("current"))
        local widget = scene.widgetsTable[scene.widgetIndex]

        if (keyName == keybindNavigateRight) then
            nextIndex = widget.navigation[1]

        elseif (keyName == keybindNavigateDown) then
            nextIndex = widget.navigation[2]

        elseif (keyName == keybindNavigateLeft) then
            nextIndex = widget.navigation[3]

        elseif (keyName == keybindNavigateUp) then
            nextIndex = widget.navigation[4]

        elseif (keyName == keybindInteract) then
            widget["function"]()
        end

        -- For normal navigation
        if ( type( nextIndex ) == "number" ) then
            scene.widgetIndex = nextIndex
            scene:updateUI()
       
        -- For segments and switches
        elseif ( type( nextIndex ) == "function" ) then
            nextIndex()
        end
    end
end

function setControlMode(sceneType)
    Runtime:removeEventListener("key", library.keyNavigation)
    Runtime:removeEventListener("key", library.navigateGame)
    Runtime:removeEventListener("touch", library.touchscreenControl)
    --Runtime:removeEventListener()
    
    local inputType = runtime.currentInputDeviceType
    if (inputType == "keyboard") then
        if (sceneType == "menu") then
            Runtime:addEventListener("key", library.keyNavigation)
            runtime.currentSceneType = "menu"
        elseif (sceneType == "game") then
            runtime.currentSceneType = "game"
            Runtime:addEventListener("key", library.navigateGame)
        end
    
    elseif (inputType == "touchscreen") then
        if (sceneType == "menu") then
            runtime.currentSceneType = "menu"
            -- Touch navigation (??)
        elseif (sceneType == "game") then
            runtime.currentSceneType = "game"
            -- Touch navigation (??)
        end
    elseif (inputType == "controller") then
        if (sceneType == "menu") then
            Runtime:addEventListener("key", library.keyNavigation)
            runtime.currentSceneType = "menu"
        elseif (sceneType == "game") then
            runtime.currentSceneType = "game"
            -- navigateGame()
        end
    elseif (inputType == "unknown") then
        -- If unknown, add all eventListeners.

        Runtime:addEventListener("key", library.keyNavigation)
        --
        --
    end
end

function handleSceneChange(goTo, nextType, options)
    --local currScene = composer.getSceneName( "current" )
    --local currType = currScene:sub(17, 20) -- Crappy. Otherwise: https://docs.coronalabs.com/api/library/global/select.html
    --local currScene = runtime.currentScene    
    
    local currType = runtime.currentSceneType

    if (currType == 'menu') and (nextType == 'game') then
        initiatePhysics()

    elseif (currType == 'game') and (nextType == 'menu') then
        terminatePhysics()
        composer.removeScene("resources.scene.game.game", true)
    end
    
    -- update variables
    --runtime.currentScene = ???
    runtime.currentSceneType = nextType
    
    composer.gotoScene(goTo, options)
    library.setControlMode(nextType)
end

-- DEBUG: To make the initial.json if lost.
function saveUserDataJSON()
    local userData = {
        ["playerData"] = {
            ["primaryWeapon"] = {},
            ["secondaryWeapon"] = {},
            ["inventory"] = {},
            ["health"] = {
                ["currentHealth"] = 10,
                ["maxHealth"] = 10,
                ["regeneration"] = 0.5,
                ["defense"] = 1,
                ["statusEffect"] = {}
            },
            ["attack"] = {
                ["strength"] = 1, 
                ["speed"] = 1, 
                ["cooldown"] = 1, 
                ["accuracy"] = 1
            },
            ["movement"] = {
                ["speed"] = 1, 
                ["jumpHeight"] = 1,
                ["randomness"] = 0,
                ["stealth"] = 1
            },
        },
        ["environmentData"] = { 
            ["map"] = "map1",
        },
    
    }
    
    local encoded = json.encode( userData,{ indent=true } )
    print("encoded:", encoded)

 
    -- Path for the file to write
    local path = system.pathForFile( "initial.json", system.DocumentsDirectory )
 
    -- Open the file handle
    local file, errorString = io.open( path, "w" )
 
    if not file then
        -- Error occurred; output the cause
        print( "File error: " .. errorString )
    else
        -- Write data to file
        --print(encoded)
        file:write(encoded)
        -- Close the file handle
        io.close( file )
    end
 
    file = nil
end

--------------------------------------------------------------------------------
-- Add functions to Public Library
--------------------------------------------------------------------------------
library.printTable = printTable
library.doesFileExist = doesFileExist
library.readFile = readFile
library.deleteFile = deleteFile
library.writeFile = writeFile
library.loadSaveFile = loadSaveFile
library.newSaveFile = newSaveFile
library.getSettings = getSettings
library.initiateSettings = initiateSettings
library.setUpInitialSettings = setUpInitialSettings
library.saveSettings = saveSettings
library.resetSettings = resetSettings
library.createKeybinds = createKeybinds
library.initiateInputDevices = initiateInputDevices
library.initiateKeybinds = initiateKeybinds
library.setInputDevice = setInputDevice
library.getAvailableInputDevices = getAvailableInputDevices
library.setUpInputDevices = setUpInputDevices
library.initiatePhysics = initiatePhysics
library.terminatePhysics = terminatePhysics
library.findNearestObj = findNearestObj
library.hoverObj = hoverObj
library.navigateGame = navigateGame
library.touchscreenControl = touchscreenControl
library.createNavigationMatrix = createNavigationMatrix
library.setNavigationMatrix = setNavigationMatrix
library.keyNavigation = keyNavigation
library.setControlMode = setControlMode
library.handleSceneChange = handleSceneChange
library.saveUserDataJSON = saveUserDataJSON

return library