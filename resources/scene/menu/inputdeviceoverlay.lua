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
        delay = 1500,
        alpha = 0
    }
    
    toast:setFillColor(255, 0, 0)
    sceneGroup:insert(toast)
    transition.to(toast, params)
end

-- Gets opened by pressing the back button.
function scene:applyInputDevice()
    -- if statement here to check if both inputs are here.
    local currentInputDevice = runtime.currentInputDevice
    local currentType = runtime.currentInputDeviceType
    local newType = scene.cache.type
    local newInputDevice = scene.cache.index

    print("currentInputDevice:", currentInputDevice)
    print("currentType:", currentType)
    print("newType:", newType)
    print("newInputDevice:", newInputDevice)

    if (newType ~= currentType) and (currentType ~= "unkown") then
        -- user wants to override/change inputdevicetype

        -- Show warning
        scene:showToast("Youre about to override the current keybinds...")
        return
    end

    local deviceToLoad = newInputDevice or currentInputDevice
    local typeToLoad = newType or currentType
    if (newIndex and newType) then
        -- scene:setInputDevice(displayName, inputDeviceType)
        --composer.hideOverlay({effect="fade", time=400})
        --library.setControlMode(runtime.currentSceneType)
    end
end

local function handleButtonEvent(event)
    if (event.phase == "ended") then
        local id = event.target.id
        if (id == "buttonApply") then
            scene:applyInputDevice()
        elseif (id == "buttonInputDevice1") then
            scene.cache.index = 1
        elseif (id == "buttonInputDevice2") then
            scene.cache.index = 2
        elseif (id == "buttonInputDevice3") then
            scene.cache.index = 3
        elseif (id == "buttonTouchscreen") then
            scene.cache.type = "touchscreen"
        elseif (id == "buttonController") then
            scene.cache.type = "controller"
        elseif (id == "buttonKeyboard") then
            scene.cache.type = "keyboard"
        end
    end
end

function scene:loadUI()
    sceneGroup = scene.view

    local scrollView = widget.newScrollView({
        id = "scrollView",
        x = 300,
        y = 200,
        width = 600,
        height = 400,
        horizontalScrollDisabled = true,
        friction = 0.985,
        scrollWidth = 800,
        scrollHeight = 1200,
        backgroundColor = { 0.1, 0.1, 0.1},
    })

    -- Create table entry for each inputDeviceButton
    local n = #runtime.availableInputDevices
    for i=1, n do
        -- variables for navigation
        local current = i+#scene.widgetsTable
        local up = current-1
        -- then its the back button
        if (up < 5) then up = 1 end
        local down = current + 1
        -- then its the back button
        if (down > n+4) then down = 1 end
        
        local array = {
            ["creation"] = {
                x = 250,
                y = (i*40)+120,
                id = "buttonInputDevice"..i,
                label = runtime.availableInputDevices[i].displayName,
                onEvent = handleButtonEvent,
                font = "fonts/BULKYPIX.TTF",
                fontSize = 20,
                labelColor = { default={ 1, 1, 1 }, over={ 1, 1, 1, 0.5 } }
            },
            ["function"] = function() scene.cache.index = i end,
            ["navigation"] = {3,down,1,up},
            ["pointer"] = {},
            ["type"] = "button",
            ["parent"] = "scrollView",
        }
        -- Insert
        table.insert(scene.widgetsTable, array)
    end
    library.printTable(scene.widgetsTable)

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
                    x = -50,
                    y = 50,
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
            },
            [2] = {
                ["creation"] = {
                    x = 550,
                    y = 160,
                    id = "buttonKeyboard",
                    label = "keyboard",
                    onEvent = handleButtonEvent,
                    font = "fonts/BULKYPIX.TTF",
                    fontSize = 20,
                    labelColor = { default={ 1, 1, 1 }, over={ 1, 1, 1, 0.5 } }
                },
                ["function"] = function() scene.cache.type = "keyboard" end,
                ["navigation"] = {1,3,6,4},
                ["pointer"] = {},
                ["type"] = "button",
                ["parent"] = "sceneGroup",
            },
            [3] = {
                ["creation"] = {
                    x = 550,
                    y = 200,
                    id = "buttonController",
                    label = "controller",
                    onEvent = handleButtonEvent,
                    font = "fonts/BULKYPIX.TTF",
                    fontSize = 20,
                    labelColor = { default={ 1, 1, 1 }, over={ 1, 1, 1, 0.5 } }
                },
                ["function"] = function() scene.cache.type = "controller" end,
                ["navigation"] = {1,4,6,2},
                ["pointer"] = {},
                ["type"] = "button",
                ["parent"] = "sceneGroup",
            },
            [4] = {
                ["creation"] = {
                    x = 550,
                    y = 240,
                    id = "buttonTouchscreen",
                    label = "touchscreen",
                    onEvent = handleButtonEvent,
                    font = "fonts/BULKYPIX.TTF",
                    fontSize = 20,
                    labelColor = { default={ 1, 1, 1 }, over={ 1, 1, 1, 0.5 } }
                },
                ["function"] = function() scene.cache.type = "touchscreen" end,
                ["navigation"] = {1,2,6,3},
                ["pointer"] = {},
                ["type"] = "button",
                ["parent"] = "sceneGroup",
            },
        }

        scene.cache = {["index"] = nil,["type"] = nil}
        scene:loadUI()

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