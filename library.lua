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

-- Sets Variables stored in the savefile. //Weiss nicht ob da hier sein soll oder in game.lua
function loadSaveFile(filename)
    local path = system.pathForFile(filename, system.DocumentsDirectory)
    local contents = library.readFile(path)

    -- 2. Decode JSON-file
    decoded, pos, msg = json.decode(contents, 1, "emptyTable")

    -- KOMMT IN INITIATEDATA
    -- 3. Set Variabels
    if decoded then
        -- 3.1 Set map-Variable
        currentMapPath = decoded['environmentData']['map']

        -- 3.2 Set other Variables
        playerData = decoded["playerData"]
        environmentData = decoded["environmentData"]

    elseif not decoded then
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
    local decoded = json.decode(data)
    
    return decoded
end

function initiateSettings(table)
    if (table[1] == "testVariableKeineAhnungWie") then
        print("ERROR: Received empty Table.")
    else
        -- Ist zwar globaler Table, wird aber nur einmal bei Startup gemacht.
        settings = table

        -- Es werden alle geladen, da ich denke, lieber mehr RAM benutzen als kritische Zeit während des KeyboardControl() vergeuden.
        selectedInputDevice = settings.selectedInputDevice
        otherInputDevices = settings.otherInputDevices
        keybindJump = settings.keybindJump
        keybindSneak = settings.keybindSneak
        keybindForward = settings.keybindForward
        keybindBackward = settings.keybindBackward
        keybindInteract = settings.keybindInteract
        keybindEscape = settings.keybindEscape
        keybindPrimaryWeapon = settings.keybindPrimaryWeapon
        keybindSecondaryWeapon = settings.keybindSecondaryWeapon
        keybindInventory = settings.keybindInventory
        keybindSelect = settings.keybindSelect
        keybindAbility  = settings.keybindAbility
        keybindBlock  = settings.keybindBlock
        loudnessMusic = settings.loudnessMusic
        loudnessSoundEffects = settings.loudnessSoundEffects
        selectedOutputDevice = settings.selectedOutputDevice
        otherOutputDevices = settings.otherOutputDevices
        playStereo = settings.playStereo
        renderParticles = settings.renderParticles
        cameraDamping = settings.cameraDamping
        difficulty = settings.difficulty
    end
end

-- DEBUG
function setUpInitialSettings()
    local data = {
        ["selectedInputDevice"] = "Keyboard",
        ["otherInputDevices"] = "EmptyTable", 
        ["keybindJump"] = "space",
        ["keybindSneak"] = "-",
        ["keybindForward"] = "l",
        ["keybindBackward"] = "j",
        ["keybindInteract"] = "h",
        ["keybindEscape"] = "escape",
        ["keybindPrimaryWeapon"] = "8",
        ["keybindSecondaryWeapon"] = "9",
        ["keybindInventory"] = "i",
        ["keybindSelect"] = "enter",
        ["keybindAbility"] = "z",
        ["keybindBlock"] = "b",
        ["loudnessMusic"] = 0.5,
        ["loudnessSoundEffects"] = 0.4,
        ["selectedOutputDevice"] = "EmptyTable",
        ["otherOutputDevices"] = "EmptyTable",
        ["playStereo"] = true,
        ["renderParticles"] = true,
        ["cameraDamping"] = 0.9,
        ["difficulty"] = 3,
    }

    local encoded = json.encode(data, {indent=true})

    local path = system.pathForFile( "resources/data/initial_settings.json", system.ResourceDirectory )
    library.writeFile(path, encoded)
end
-- Speichert 
function saveSettings(table)
    -- json.encode
    local encoded = json.encode(table, { indent=true })

    -- Write file
    local path = system.pathForFile( "settings.json", system.DocumentsDirectory )
    library.writeFile(path, encoded)
end

function resetSettings()
    -- Get data from initial_setting.json
    local path = system.pathForFile( "resources/data/initial_settings.json", system.ResourceDirectory )
    local data = library.getSettings(path)
    
    -- Save data
    library.saveSettings(data)
    return data
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

function findNearestObj()
    -- maybe define a table with the data for each menu, instead of calculating it everytime.
    for i, object in ipairs(listOfObjects) do
        local x, y = object.x, object.y
        
        if (navigationInput == "up") and (y <= currPosY) then
            local dx, dy = (currPosX-x), (currPosY-y)
            local delta = sqrt((dx*dx)+(dy*dy))
            --distances[object] = delta
            distances[i] = delta
            if delta < minD then
                minD = delta
            end

        elseif (navigationInput == "down") and (y >= currPosY)then
            local dx, dy = (currPosX-x), (currPosY-y)
            local delta = sqrt((dx*dx)+(dy*dy))
            --distances[object] = delta
            distances[i] = delta
            if delta < minD then
                minD = delta
            end

        elseif (navigationInput == "left") and (x <= currPosX) then
            local dx, dy = (currPosX-x), (currPosY-y)
            local delta = sqrt((dx*dx)+(dy*dy))
            --distances[object] = delta
            distances[i] = delta
            if delta < minD then
                minD = delta
            end

        elseif (navigationInput == "right") and (x >= currPosX) then
            local dx, dy = (currPosX-x), (currPosY-y)
            local delta = sqrt((dx*dx)+(dy*dy))
            distances[i] = delta
            if delta < minD then
                minD = delta
            end
        else
            local delta = 10000
            distances[i] = delta
            if delta < minD then
                minD = delta
            end
        end
    end
    local index = table.indexOf( distances, minD )
    local nearestObj = listOfObjects[index]
    currPosX, currPosY = nearestObj:localToContent(0,0)
end

-- Muss noch herausfinden, wie was gesteuert werden kann.
function keyboardControl(event)
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
            print("keybindEscape-event")
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

-- movF, movB, movJ, interact
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

-- inmenu navigation with key-event as input
function navigateMenu(event)
    if (event.phase == "up") then

        -- Localize
        local scene = composer.getScene(composer.getSceneName("current"))
        local keyName = event.keyName
        local currentObj = scene.currentObj
        local data = scene.navigationMatrix[currentObj]
        
        if (keyName == "i") then
            local nextObj = data[1]
            if nextObj then
                scene.currentObj = nextObj
                scene:hoverObj(nextObj)
            end

        elseif (keyName == "l") then
            local nextObj = data[2]
            if nextObj then
                scene.currentObj = nextObj
                scene:hoverObj(nextObj)
            end

        elseif (keyName == "k") then
            local nextObj = data[3]
            if nextObj then
                scene.currentObj = nextObj
                scene:hoverObj(nextObj)
            end

        elseif (keyName == "j") then
            local nextObj = data[4]
            if nextObj then
                scene.currentObj = nextObj
                scene:hoverObj(nextObj)
            end
        
        -- User wants to enter selected/hovered menu.
        elseif (keyName == "space") then
            scene:interactWithObj(scene.currentObj)
        end
    end 
end

function setControlMode(sceneType)
    Runtime:removeEventListener("key", library.navigateMenu)
    --Runtime:removeEventListener()
    --Runtime:removeEventListener()
    
    print(runtime.selectedInputDevice)
    if (runtime.selectedInputDevice == "keyboard") then
        if (sceneType == "menu") then
            print("eventListener added.")
            Runtime:addEventListener("key", library.navigateMenu)
            runtime.currentSceneType = "menu"
        elseif (sceneType == "game") then
            runtime.currentSceneType = "game"
            -- scene:navigateGame()
        end
    
    elseif (runtime.selectedInputDevice == "touchscreen") then
        if (sceneType == "menu") then
            runtime.currentSceneType = "menu"
            -- Touch navigation (??)
        elseif (sceneType == "game") then
            runtime.currentSceneType = "game"
            -- Touch navigation (??)
        end
    end
end

function handleSceneChange(goTo, nextType, options)
    local currScene = composer.getSceneName( "current" )
    local currType = currScene:sub(17, 20) -- Crappy. Otherwise: https://docs.coronalabs.com/api/library/global/select.html

    if (currType == 'menu') and (nextType == 'game') then
        initiatePhysics()

    elseif (currType == 'game') and (nextType == 'menu') then
        terminatePhysics()
        composer.removeScene("resources.scene.game.game", true)
    end
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
library.initiatePhysics = initiatePhysics
library.terminatePhysics = terminatePhysics
library.findNearestObj = findNearestObj
library.findNearestObjV2 = findNearestObjV2
library.hoverObj = hoverObj
library.keyboardControl = keyboardControl
library.touchscreenControl = touchscreenControl
library.navigateMenu = navigateMenu
library.setControlMode = setControlMode
library.handleSceneChange = handleSceneChange
library.saveUserDataJSON = saveUserDataJSON

return library