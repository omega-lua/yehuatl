-- Template from Solar2D-Guide: https://docs.coronalabs.com/guide/system/composer/index.html#template

local library = require("library")
local widget = require( "widget" )
local composer = require( "composer" )
local scene = composer.newScene()


-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

-- Function to handle button events
local function handleButtonEvent( event )
    if ( event.phase == "ended") then
        if (event.target.id == 'buttonPlay') then
            scene:handleObjectInteraction("buttonPlay")

        elseif (event.target.id == 'buttonSettings') then
            scene:handleObjectInteraction("buttonSettings")

        elseif (event.target.id == 'buttonCredits') then
            scene:handleObjectInteraction("buttonCredits")
        end
    end
end
 
function scene:hoverObj()
    local currObject = scene.currObject
    for k,o in pairs(scene.referenceTable) do
        local params = {}
        if (k == currObject) then
            params = {time = 200, transition = easing.outQuint, xScale = 1.5, yScale = 1.5,}     
        else
            params = {time = 200, transition = easing.outQuint, xScale = 1, yScale = 1,}
        end
        transition.to(o, params)
    end
end

function scene:handleObjectInteraction(object)
    if (object == "buttonPlay") then
        library.handleSceneChange("resources.scene.menu.savemenu","menu", { effect = "fade", time = 400,})
    elseif (object == "buttonSettings") then
        library.handleSceneChange( "resources.scene.menu.settingsmenu", "menu", { effect = "fade", time = 400,})
    elseif (object == "buttonCredits") then
        library.handleSceneChange("resources.scene.menu.creditsmenu", "menu", { effect = "fade", time = 400,})
    end
end
 
function scene:loadUI()
    local sceneGroup = scene.view
    
    buttonPlay = widget.newButton(
        {
        x = display.contentCenterX*1.4, 
        y = display.contentCenterY,
        id = "buttonPlay",
        label = "Play",
        onEvent = handleButtonEvent,
        font = "fonts/BULKYPIX.TTF",
        fontSize = 30,
        labelColor = { default={ 1, 1, 1 }, over={ 1, 1, 1, 0.5 } }
        }
    )
    buttonSettings = widget.newButton(
        {
        x = display.contentCenterX*0.6,
        y = display.contentCenterY, 
        id = "buttonSettings",
        label = "Settings",
        onEvent = handleButtonEvent,
        font = "fonts/BULKYPIX.TTF",
        fontSize = 30,
        labelColor = { default={ 1, 1, 1 }, over={ 1, 1, 1, 0.5 } }
        }
    )

    buttonCredits = widget.newButton(
        {
        x = display.contentCenterX*1,
        y = display.contentCenterY*1.4, 
        id = "buttonCredits",
        label = "Credits",
        onEvent = handleButtonEvent,
        font = "fonts/BULKYPIX.TTF",
        fontSize = 30,
        labelColor = { default={ 1, 1, 1 }, over={ 1, 1, 1, 0.5 } }
        }
    )
    
    sceneGroup:insert( buttonPlay )
    sceneGroup:insert( buttonSettings )
    sceneGroup:insert( buttonCredits )
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
        
        -- Scene variables have to be set here, otherwise some would be empty.
        -- where the hover starts, normally in center of screen.
        scene.currObject = 1
        
        scene.matrix = {
            {3, 2, 3, 2},
            {1, 1, 3, 1},
            {1, 2, 1, 2},
        }
        scene.referenceTable = {
            [1] = buttonPlay,
            [2] = buttonCredits,
            [3] = buttonSettings,
        }

        scene.functionsTable = {
            [1] = function() library.handleSceneChange("resources.scene.menu.savemenu","menu", { effect = "fade", time = 400,}) end,
            [2] = function() library.handleSceneChange("resources.scene.menu.creditsmenu","menu", { effect = "fade", time = 400,}) end,
            [3] = function() library.handleSceneChange("resources.scene.menu.settingsmenu","menu", { effect = "fade", time = 400,}) end,
        }
        runtime.currentScene = scene
        runtime.currentSceneType = "menu"

        -- Refresh
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