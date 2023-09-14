-- Template from Solar2D-Guide: https://docs.coronalabs.com/guide/system/composer/index.html#template

local composer = require("composer")
local widget = require("widget")
local library = require("library")

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Scene Variables
-- -----------------------------------------------------------------------------------
scene.type = "menu"
scene.widgetIndex = 2
scene.widgetsTable = {}
scene.selectedDevice = nil
scene.selectedType = nil
scene._selectedIndex = nil

-- -----------------------------------------------------------------------------------
-- Scene functions
-- -----------------------------------------------------------------------------------

function scene:showToast(message)
    local toast = display.newText({
        text = message,     
        x = display.contentCenterX,
        y = display.contentCenterY*0.2,
        width = 256,
        font = "fonts/BULKYPIX.TTF",   
        fontSize = 18,
        align = "center"
    })
 
    local params = {
        time = 1000,
        tag = "toast",
        transition = easing.outQuart,
        delay = 2000,
        alpha = 0
    }
    
    toast:setFillColor(255, 0, 0)
    sceneGroup:insert(toast)
    transition.to(toast, params)
end

-- Gets opened by pressing the back button.
function scene:applyInputDevice()
    -- Localize
    local currentDevice = runtime.currentInputDevice
    local currentType = runtime.currentInputDeviceType
    local selectedDevice = scene.selectedDevice
    local selectedType = scene.selectedType
    local savedType = runtime.settings.controls.inputDevice.saved[selectedDevice]

    print("-------------")
    print("currentDevice:", currentDevice)
    print("currentType:", currentType)
    print("_selectedDeviceTable:", _selectedDeviceTable)
    print("selectedDevice:", selectedDevice)
    print("selectedType:", selectedType)
    print("savedType:", savedType)
    print("-------------")


    local function fc(v,k)
        library.setInputDevice(v, k)
        library.setControlMode(runtime.currentSceneType)
    end

    if selectedDevice and (selectedDevice ~= currentDevice) then
        if selectedType then
            -- load
            fc(selectedDevice, selectedType)
        elseif savedType then
            -- load
            fc(selectedDevice, savedType)
        else
            -- show message: need input.
            scene:showToast("WARNING: Need input type of "..selectedDevice)
            return
        end

    elseif selectedType and (selectedType ~= currentType) then
        if (currentType == nil) then
            -- load
            fc(currentDevice, selectedType)
        else
            -- show warning: user is about to override keybinds.
            scene:showToast("WARNING: About to override keybinds of "..currentDevice)
            return
        end
    end
    library.handleSceneChange("resources.scene.menu.settingsmenu", "menu", {effect="fade", time=400})
end

function scene:changeSelection(selection)
    if (selection == "inputdevice") then
        --local availableInputDevices = runtime.availableInputDevices
        --local selectedDevice = scene.selectedDevice
        local s, n = scene._selectedIndex, nil -- s(electedDevice), n(ext device)
        
        -- Uses variable so it has to iterate through the table only on first time of changeSelection().
        --if not s then
            --for i, device in pairs(availableInputDevices) do
                --if (device.displayName == selectedDevice) then s = i break end
           --end
        --end


        -- calculate which is input device is next (looping 1<->3)
        if (s == 3) or (s == nil) then n = 1 else n = s + 1 end

        -- set variables and buttonlabel
        scene._selectedIndex = n
        scene.selectedDevice = runtime.availableInputDevices[n].displayName
        local _t = runtime.settings.controls.inputDevice.saved[scene.selectedDevice] or {}
        scene.selectedType = _t.type or nil
        scene.widgetsTable[3].pointer:setLabel(scene.selectedType or "Choose...")
        scene.widgetsTable[2].pointer:setLabel(scene.selectedDevice)

    elseif (selection == "type") then
        local t = {"keyboard", "controller", "touchscreen"}
        local s, n = scene.selectedType or nil, nil -- s(elected type), n(ext type)
        if s then
            local i = table.indexOf( t, s )
            -- calculate which is type is next (looping 1<->3)
            if (i == 3) then n = 1 else n = i + 1 end
        else
            n = 1
        end

        -- Set variables and buttonlabel
        scene.selectedType = t[n]
        scene.widgetsTable[3].pointer:setLabel(t[n])
    end
end

-- Handles all user interaction
local function handleInteraction(event)
    if (event.phase == "ended") then
        local id = event.target.id
        if (id == "buttonApply") then
            scene:applyInputDevice()
        elseif (id == "buttonInputDevice") then
            scene:changeSelection("inputdevice")
        elseif (id == "buttonType") then
            scene:changeSelection("type")
        end
    end
end

-- On startup
function scene:loadUI() 
    sceneGroup = scene.view

    scene.widgetsTable = {
        [1] = {
            ["creation"] = {
                x = 650,
                y = 350,
                id = "buttonApply",
                label = "Apply",
                onEvent = handleInteraction,
                font = "fonts/BULKYPIX.TTF",
                fontSize = 20,
                labelColor = { default={ 1, 1, 1 }, over={ 1, 1, 1, 0.5 } }
            },
            ["function"] = function() scene:dispatchEvent({ name="interaction", target={id="buttonApply"}, phase="ended"}) end,
            ["navigation"] = {2,2,3,3},
            ["pointer"] = {},
            ["type"] = "button",
            ["parent"] = "sceneGroup",
        },
        [2] = {
            ["creation"] = {
                x = 150,
                y = 200,
                id = "buttonInputDevice",
                label = scene.selectedDevice or "Choose...",
                onEvent = handleInteraction,
                font = "fonts/BULKYPIX.TTF",
                fontSize = 25,
                labelColor = { default={ 1, 1, 1 }, over={ 1, 1, 1, 0.5 } }
            },
            ["function"] = function() scene:dispatchEvent({ name="interaction", target={id="buttonInputDevice"}, phase="ended"}) end,
            ["navigation"] = {3,1,1,1},
            ["pointer"] = {},
            ["type"] = "button",
            ["parent"] = "sceneGroup"
        },
        [3] = {
            ["creation"] = {
                x = 550,
                y = 200,
                id = "buttonType",
                label = scene.selectedType or "Choose...",
                onEvent = handleInteraction,
                font = "fonts/BULKYPIX.TTF",
                fontSize = 25,
                labelColor = { default={ 1, 1, 1 }, over={ 1, 1, 1, 0.5 } }
            },
            ["function"] = function() scene:dispatchEvent({ name="interaction", target={id="buttonType"}, phase="ended"}) end,
            ["navigation"] = {1,1,2,1},
            ["pointer"] = {},
            ["type"] = "button",
            ["parent"] = "sceneGroup"
        },
    }

    -- Create widgets
    for i, object in pairs(scene.widgetsTable) do
        local type = object.type

        -- what type of widget
        if (type == "text") then
            scene.widgetsTable[i].pointer = display.newText( object.creation )
            if object.color then
                scene.widgetsTable[i].pointer:setFillColor(unpack(object.color))
            end

        elseif (type == "line") then
            scene.widgetsTable[i].pointer = display.newLine(unpack(object.creation))
            if object.color then
                scene.widgetsTable[i].pointer:setStrokeColor(unpack(object.color))
            end
        
        elseif (type == "button") then
            scene.widgetsTable[i].pointer = widget.newButton( object.creation )

        elseif (type == "rectangle") then
            scene.widgetsTable[i].pointer = display.newRect(unpack(object.creation))
            if object.toBack then
                scene.widgetsTable[i].pointer:toBack()
            end
        elseif (type == nil) then
            print("ERROR: Widget",i,"has no type attribute.")
        end

        -- where to insert
        if (object.parent == "sceneGroup") then
            sceneGroup:insert(scene.widgetsTable[i].pointer)
        else
            print("ERROR: object has no valid parent attribute.")
        end
    end
end

function scene:hoverObj()
    local widgetIndex = scene.widgetIndex
    for i,widget in pairs(scene.widgetsTable) do
        local params = {}
        if (i == widgetIndex) then 
            params = {time = 200, transition = easing.outQuint, xScale = 1.5, yScale = 1.5}     
        else
            params = {time = 200, transition = easing.outQuint, xScale = 1, yScale = 1}
        end
        transition.to(widget.pointer, params)
    end
end
 
function scene:updateUI()
    -- Code for refreshing widget labels.
end
-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
 
-- create()
function scene:create( event )
 
    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen

    scene:loadUI()
end

-- show()
function scene:show( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)

        scene.widgetIndex = 2
        scene:updateUI()
        scene:hoverObj()

    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen
    end
end


-- hide()
function scene:hide( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is on screen (but is about to go off screen)
 
    elseif ( phase == "did" ) then
        -- Code here runs immediately after the scene goes entirely off screen

        composer.removeScene( "resources.scene.menu.inputdevicemenu")
    end
end
 
 
-- destroy()
function scene:destroy( event )
    local sceneGroup = self.view
    -- Code here runs prior to the removal of scene's view
 
end
 
 
-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------
scene:addEventListener( "interaction", handleInteraction )

return scene