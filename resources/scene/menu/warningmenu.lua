-- Template from Solar2D-Guide: https://docs.coronalabs.com/guide/system/composer/index.html#template

local composer = require( "composer" )
local widget = require("widget")
local library = require("library")

local scene = composer.newScene()
 
-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
function scene:discardSettings()
    parent.isSaved = true
    tmpSettings = nil

    -- Message
    parent:showToast("Settings discarded!")
            
    composer.hideOverlay("fade", 400)
    composer.removeScene("resources.scene.menu.settingsmenu")
    library.handleSceneChange("resources.scene.menu.mainmenu", "menu", { effect = "fade", time = 400,})
end

local function handleButtonEvent(event)
    if (event.phase == 'ended') then
        if (event.target.id == "buttonBack") then
            parent:hideOverlay()
        elseif (event.target.id == "buttonApplySettings") then
            parent:applySettings()
            parent:hideOverlay()
        elseif (event.target.id == "buttonDiscardSettings") then
            scene:discardSettings()
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
    scene:hoverObj()
end

function scene:loadUI()
    local sceneGroup = scene.view
    -- Code here runs when the scene is first created but has not yet appeared on screen

    -- Create widgets
    for i, object in pairs(scene.widgetsTable) do
        local type = object.type

        if (type == "text") then
            scene.widgetsTable[i].pointer = display.newText( object.creation )
            sceneGroup:insert(scene.widgetsTable[i].pointer)
            if object.color then
                scene.widgetsTable[i].pointer:setFillColor(unpack(object.color))
            end

        elseif (type == "line") then
            scene.widgetsTable[i].pointer = display.newLine(unpack(object.creation))
            sceneGroup:insert(scene.widgetsTable[i].pointer)
            if object.color then
                scene.widgetsTable[i].pointer:setStrokeColor(unpack(object.color))
            end
        
        elseif (type == "button") then
            scene.widgetsTable[i].pointer = widget.newButton( object.creation )
            sceneGroup:insert(scene.widgetsTable[i].pointer)

        elseif (type == "roundedRectangle") then
            scene.widgetsTable[i].pointer = display.newRoundedRect(unpack(object.creation))
            sceneGroup:insert(scene.widgetsTable[i].pointer)
            if object.toBack then
                scene.widgetsTable[i].pointer:toBack()
            end

        elseif (type == nil) then
            print("ERROR: Widget",i,"has no type attribute.")
        end
    end
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
 
-- create()
function scene:create( event )
    --display.getCurrentStage():setFocus( warningmenu )
    
    scene.widgetsTable = {
        [1] = {
            ["creation"] = {
                display.contentCenterX,
                display.contentCenterY, 
                700, 
                350,
                10,
            },
            ["function"] = nil,
            ["navigation"] = nil,
            ["pointer"] = {},
            ["type"] = "roundedRectangle",
            ["toBack"] = true,
        },
        [2] = {
            ["creation"] = {
                x = 300, 
                y = 100,
                id = "textWarning",
                text = "Settings aren't saved yet. What to do next?",
                font = "fonts/BULKYPIX.TTF",
                fontSize = 20,
                --width = 300,
            },
            ["function"] = nil,
            ["navigation"] = nil,
            ["pointer"] = {},
            ["type"] = "text",
            ["color"] = { 1, 0, 0, 1}
        },
        [3] = {
            ["creation"] = {
                x = 300,
                y = 200,
                id = "buttonCancel",
                label = "Cancel exit",
                onEvent = handleButtonEvent,
                font = "fonts/BULKYPIX.TTF",
                fontSize = 25,
                labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0, 0.5 } }
            },
            ["function"] = function() parent:hideOverlay() end,
            ["navigation"] = {nil,4,nil,5},
            ["pointer"] = {},
            ["type"] = "button",
        },
        [4] = {
            ["creation"] = {
                x = 300,
                y = 250,
                id = "buttonApplySettings",
                label = "Save settings and exit",
                onEvent = handleButtonEvent,
                font = "fonts/BULKYPIX.TTF",
                fontSize = 25,
                labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0, 0.5 } }
            },
            ["function"] = function() parent:applySettings() parent:hideOverlay() end,
            ["navigation"] = {nil,5,nil,3},
            ["pointer"] = {},
            ["type"] = "button",
        },
        [5] = {
            ["creation"] = {
                x = 300,
                y = 300,
                id = "buttonDiscardSettings",
                label = "Discard Settings",
                onEvent = handleButtonEvent,
                font = "fonts/BULKYPIX.TTF",
                fontSize = 25,
                labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0, 0.5 } }
            },
            ["function"] = function() scene:discardSettings() end,
            ["navigation"] = {nil,3,nil,4},
            ["pointer"] = {},
            ["type"] = "button",
        },
    }

    scene.widgetIndex = 3
end
 
 
-- show()
function scene:show( event )
 
    local sceneGroup = self.view
    local phase = event.phase
    parent = event.parent
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)
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
        parent = nil
 
    elseif ( phase == "did" ) then
        -- Code here runs immediately after the scene goes entirely off screen
       --display.getCurrentStage():setFocus( nil )
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