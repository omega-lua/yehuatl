-- Template from Solar2D-Guide: https://docs.coronalabs.com/guide/system/composer/index.html#template

local composer = require("composer")
local widget = require("widget")
local library = require("library")

local scene = composer.newScene()
 
-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
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
    local _selectedDeviceTable = runtime.availableInputDevices[scene.selectedIndex] or {}
    local selectedDevice = _selectedDeviceTable.displayName
    local selectedType = scene.selectedType
    local savedType = runtime.settings.controls.inputDevice.saved[selectedDevice]
    
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
    composer.hideOverlay({effect="fade", time=800})
end

-- Maybe useful for playing audio/visual feedback in future.
local function handleButtonEvent(event)
    if (event.phase == "ended") then
        local id = event.target.id
        if (id == "buttonApply") then
            scene:applyInputDevice()
        elseif (id == "buttonInputDevice1") then
            scene.selectedIndex = 1
        elseif (id == "buttonInputDevice2") then
            scene.selectedIndex = 2
        elseif (id == "buttonInputDevice3") then
            scene.selectedIndex = 3
        elseif (id == "buttonInputDevice4") then
            scene.selectedIndex = 4
        elseif (id == "buttonTouchscreen") then
            scene.selectedType = "touchscreen"
        elseif (id == "buttonController") then
            scene.selectedType = "controller"
        elseif (id == "buttonKeyboard") then
            scene.selectedType = "keyboard"
        end
    end
end

function scene:loadUI()
    sceneGroup = scene.view

    local scrollView = widget.newScrollView({
        id = "scrollView",
        x = 200,
        y = 200,
        width = 600,
        height = 400,
        horizontalScrollDisabled = true,
        friction = 0.985,
        scrollWidth = 800,
        scrollHeight = 1200,
        backgroundColor = { 0.1, 0.1, 0.1},
    })

    -- Create table entry for each inputDeviceWidget
    local n = #runtime.availableInputDevices
    for i=1, n do
        -- isSaved property to darken the unsaved input devices
        local isSaved = runtime.settings.controls.inputDevice.saved[runtime.availableInputDevices[i].displayName]
        if isSaved ~= nil then isSaved = true else isSaved = nil end
        local t = {}
        if isSaved then t={1,1,1,1} else t={1,1,1,0.5} end

        local array = {
            ["creation"] = {
                x = 300,
                y = (i*40)+120,
                id = "buttonInputDevice"..i,
                label = runtime.availableInputDevices[i].displayName,
                onEvent = handleButtonEvent,
                font = "fonts/BULKYPIX.TTF",
                fontSize = 20,
                labelColor = { default=t, over={ 1, 1, 1, 0.5 } }
            },
            ["function"] = function() scene.selectedIndex = i end,
            ["navigation"] = {},
            ["pointer"] = {},
            ["type"] = "button",
            ["parent"] = "scrollView",
            ["isInteractable"] = true
        }
        -- Insert
        table.insert(scene.widgetsTable, array)
    end

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

        elseif (type == "segment") then
            scene.widgetsTable[i].pointer = widget.newSegmentedControl( object.creation )

        elseif (type == "switch") then
            scene.widgetsTable[i].pointer = widget.newSwitch( object.creation )

        elseif (type == nil) then
            print("ERROR: Widget",i,"has no type attribute.")
        end

        -- where to insert
        if (object.parent == "scrollView") then
            scrollView:insert(scene.widgetsTable[i].pointer)
        elseif (object.parent == "sceneGroup") then
            sceneGroup:insert(scene.widgetsTable[i].pointer)
        else
            print("ERROR: object has no parent attribute.")
        end
    end
    sceneGroup:insert(scrollView)
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
    scene:hoverObj()
end
-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
 
-- create()
function scene:create( event )
 
    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen

    scene.widgetIndex = 6
end
 
 
-- show()
function scene:show( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)

        -- Has to be here, so that it refreshes the UI everytime. Has to be set before scene:loadUI()
        scene.widgetsTable = {
            [1] = {
                ["creation"] = {
                    x = 650,
                    y = 350,
                    id = "buttonApply",
                    label = "Apply",
                    onEvent = handleButtonEvent,
                    font = "fonts/BULKYPIX.TTF",
                    fontSize = 20,
                    labelColor = { default={ 1, 1, 1 }, over={ 1, 1, 1, 0.5 } }
                },
                ["function"] = function() scene:applyInputDevice() end,
                ["navigation"] = {5,5,3,nil},
                ["pointer"] = {},
                ["type"] = "button",
                ["parent"] = "sceneGroup",
                ["isInteractable"] = true
            },
            [2] = {
                ["creation"] = {
                    x = 600,
                    y = 160,
                    id = "buttonKeyboard",
                    label = "keyboard",
                    onEvent = handleButtonEvent,
                    font = "fonts/BULKYPIX.TTF",
                    fontSize = 20,
                    labelColor = { default={ 1, 1, 1 }, over={ 1, 1, 1, 0.5 } }
                },
                ["function"] = function() scene.selectedType = "keyboard" end,
                ["navigation"] = {1,3,6,4},
                ["pointer"] = {},
                ["type"] = "button",
                ["parent"] = "sceneGroup",
                ["isInteractable"] = true
            },
            [3] = {
                ["creation"] = {
                    x = 600,
                    y = 200,
                    id = "buttonController",
                    label = "controller",
                    onEvent = handleButtonEvent,
                    font = "fonts/BULKYPIX.TTF",
                    fontSize = 20,
                    labelColor = { default={ 1, 1, 1 }, over={ 1, 1, 1, 0.5 } }
                },
                ["function"] = function() scene.selectedType = "controller" end,
                ["navigation"] = {1,4,6,2},
                ["pointer"] = {},
                ["type"] = "button",
                ["parent"] = "sceneGroup",
                ["isInteractable"] = true
            },
            [4] = {
                ["creation"] = {
                    x = 600,
                    y = 240,
                    id = "buttonTouchscreen",
                    label = "touchscreen",
                    onEvent = handleButtonEvent,
                    font = "fonts/BULKYPIX.TTF",
                    fontSize = 20,
                    labelColor = { default={ 1, 1, 1 }, over={ 1, 1, 1, 0.5 } }
                },
                ["function"] = function() scene.selectedType = "touchscreen" end,
                ["navigation"] = {1,2,6,3},
                ["pointer"] = {},
                ["type"] = "button",
                ["parent"] = "sceneGroup",
                ["isInteractable"] = true
            },
        }

        scene.widgetIndex = 6
        scene.selectedIndex = nil
        scene.selectedType = nil
        scene:loadUI()

        local matrix = library.createNavigationMatrix()
        library.setNavigationMatrix(matrix)

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
 
return scene