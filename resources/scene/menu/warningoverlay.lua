-- Template from Solar2D-Guide: https://docs.coronalabs.com/guide/system/composer/index.html#template

local lib = require( "resources.lib.lib" )
local composer = require( "composer" )
local widget = require("widget")

local scene = composer.newScene()
 
-- -----------------------------------------------------------------------------------
-- Scene functions
-- -----------------------------------------------------------------------------------

scene.type = 'menu'
scene.isInteractable = false

-- -----------------------------------------------------------------------------------
-- Scene functions
-- -----------------------------------------------------------------------------------
local function handleInteraction(event)
    if scene.isInteractable then
        if (event.phase == 'ended') then
            local id = event.target.id
            if (event.target.id == "buttonBack") then
                scene.isInteractable = false
                composer.hideOverlay( 'fade', 100 )
            
            elseif (event.target.id == "buttonApply") then
                scene.isInteractable = false

                parent:applySettings()

                -- Message
                parent:showToast("Settings applied!")
            
                -- Hide overlay, show mainmenu, remove settingsmenu-scene
                composer.hideOverlay("fade", 400)
                lib.scene.show("resources.scene.menu.mainmenu", { effect = "fade", time = 800})
                composer.removeScene("resources.scene.menu.settingsmenu")
            elseif (event.target.id == "buttonDiscard") then
                scene.isInteractable = false
                -- Message
                parent:showToast("Settings discarded!")
                 
                -- Hide overlay, show mainmenu, remove settingsmenu-scene
                composer.hideOverlay("fade", 400)
                lib.scene.show("resources.scene.menu.mainmenu", { effect = "fade", time = 800})
                composer.removeScene("resources.scene.menu.settingsmenu")
            end
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
    if (lib.control.mode == "key") then
        scene:hoverObj()
    end
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
            },
            ["function"] = nil,
            ["navigation"] = nil,
            ["pointer"] = {},
            ["type"] = "text",
            ["color"] = { 0, 0, 0, 1}
        },
        [3] = {
            ["creation"] = {
                x = 300,
                y = 200,
                id = "buttonBack",
                label = "Cancel exit",
                onEvent = handleInteraction,
                font = "fonts/BULKYPIX.TTF",
                fontSize = 25,
                labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0, 0.5 } }
            },
            ["function"] = function() scene:dispatchEvent({ name="interaction", target={id="buttonBack"}, phase="ended"}) end,
            ["navigation"] = {nil,4,nil,5},
            ["pointer"] = {},
            ["type"] = "button",
        },
        [4] = {
            ["creation"] = {
                x = 300,
                y = 250,
                id = "buttonApply",
                label = "Save changes and exit",
                onEvent = handleInteraction,
                font = "fonts/BULKYPIX.TTF",
                fontSize = 25,
                labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0, 0.5 } }
            },
            ["function"] = function() scene:dispatchEvent({ name="interaction", target={id="buttonApply"}, phase="ended"}) end,
            ["navigation"] = {nil,5,nil,3},
            ["pointer"] = {},
            ["type"] = "button",
        },
        [5] = {
            ["creation"] = {
                x = 300,
                y = 300,
                id = "buttonDiscard",
                label = "Discard changes",
                onEvent = handleInteraction,
                font = "fonts/BULKYPIX.TTF",
                fontSize = 25,
                labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0, 0.5 } }
            },
            ["function"] = function() scene:dispatchEvent({ name="interaction", target={id="buttonDiscard"}, phase="ended"}) end,
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
        scene:updateUI()

        scene.isInteractable = true
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
 
        scene.isInteractable = false
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
scene:addEventListener( "interaction", handleInteraction )

return scene