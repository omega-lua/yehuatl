-- Template from Solar2D-Guide: https://docs.coronalabs.com/guide/system/composer/index.html#template

local lib = require( "resources.lib.lib" )
local widget = require( 'widget' )
local composer = require( "composer" )
local scene = composer.newScene()
 
-- -----------------------------------------------------------------------------------
-- Scene variables
-- -----------------------------------------------------------------------------------

scene.type = "menu"

-- -----------------------------------------------------------------------------------
-- Scene functions
-- -----------------------------------------------------------------------------------

function scene:hoverObj()
    local widgetIndex = scene.widgetIndex
    for i,widget in pairs(scene.widgetsTable) do
        local params = {}
        if (i == widgetIndex) then
            params = {time = 200, transition = easing.outQuint, xScale = 1.2, yScale = 1.2, alpha=1}     
        else
            params = {time = 200, transition = easing.outQuint, xScale = 1, yScale = 1, alpha=0.7}
        end
       transition.to(widget.pointer, params)
    end
end

function scene:updateUI(event)
    if (lib.control.mode == "key") then
        scene:hoverObj()
    end
end

local function handleInteraction(event)
    local id = event.target.id
    if id == 'buttonBack' then
        scene:removeEventListener('interaction', handleInteraction)
        local options = {time=400, effect='fade'}
        lib.scene.show( "resources.scene.menu.mainmenu", options )   
    elseif id == 'buttonContact' then
        system.openURL( "mailto:oliver@gomer.ch" ) 
    end
end

function scene:loadUI()
    local sceneGroup = scene.view

    -- line 1
    local options = {
        parent = sceneGroup, 
        text = "Made by Oliver",
        x = 300, 
        y = 100,
        width = 400,
        fontSize = 20,
        align = 'center'
    }
    local text1 = display.newText( options )

    -- line 2
    local options = {
        parent = sceneGroup, 
        text = "Testing and Feedback by Adrian",
        x = 300, 
        y = 150,
        width = 400,
        fontSize = 20,
        align = 'center'
    }
    local text2 = display.newText( options )

    -- line 3
    local options = {
        parent = sceneGroup, 
        text = "Made with Solar2d SDK, Map Design with Tiled Editor, Map Loading with Dusk Engine",
        x = 300, 
        y = 220,
        width = 400,
        fontSize = 15,
        align = 'center'
    }
    local text3 = display.newText( options )

    -- line 4
    local options = {
        parent = sceneGroup, 
        text = "Font used: Bulkypixel",
        x = 300, 
        y = 290,
        width = 400,
        fontSize = 15,
        align = 'center'
    }
    local text4 = display.newText( options )

    -- line 5
    local options = {
        parent = sceneGroup, 
        text = "v1.0",
        x = 300, 
        y = 370,
        width = 400,
        font = "fonts/BULKYPIX.TTF",
        fontSize = 20,
        align = 'center'
    }
    local text5 = display.newText( options )


    -- Create widgets
    for i, object in pairs(scene.widgetsTable) do
        local type = object.type
        if (type == "text") then
            scene.widgetsTable[i].pointer = display.newText (object.creation )
            sceneGroup:insert(scene.widgetsTable[i].pointer)
        elseif (type == "button") then
            scene.widgetsTable[i].pointer = widget.newButton( object.creation )
            sceneGroup:insert(scene.widgetsTable[i].pointer)
        end
    end
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
 
-- create()
function scene:create( event )
 
    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen

    scene.widgetIndex = 1
    scene.widgetsTable = {
        [1] = {
            ["creation"] = {
                id = 'buttonBack',
                x = 50,
                y = 50,
                width = 120,
                height = 50,
                defaultFile = 'resources/graphics/ui/buttonShort.png',
                overFile = 'resources/graphics/ui/buttonShortPressed.png',
                label = "Back",
                onRelease = handleInteraction,
                font = "fonts/BULKYPIX.TTF",
                fontSize = 25,
                labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } }
            },
            ["function"] = function() scene:dispatchEvent({ name="interaction", target={id="buttonBack"}, phase="ended"}) end,
            ['navigation'] = {2,nil,2,nil},
            ["pointer"] = {},
            ["type"] = "button",
        },
        [2] = {
            ["creation"] = {
                id = 'buttonContact',
                x = 550,
                y = 50,
                width = 160,
                height = 50,
                defaultFile = 'resources/graphics/ui/buttonShort.png',
                overFile = 'resources/graphics/ui/buttonShortPressed.png',
                label = "Contact",
                onRelease = handleInteraction,
                font = "fonts/BULKYPIX.TTF",
                fontSize = 25,
                labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } }
            },
            ["function"] = function() scene:dispatchEvent({ name="interaction", target={id="buttonContact"}, phase="ended"}) end,
            ['navigation'] = {1, nil, 1, nil},
            ["pointer"] = {},
            ["type"] = "button",
        }
    }
    
    scene:loadUI()
    scene:updateUI()
end


-- show()
function scene:show( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)

        scene:addEventListener( "interaction", handleInteraction )
 
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

        scene:removeEventListener("interaction", handleInteraction)
 
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