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
    if (event.target.id == 'buttonPlay') then
        if ( event.phase == "ended") then
            local goTo = "resources.scene.menu.savemenu"
            local sceneType = "menu"
            local options = { effect = "fade", time = 400,}
            library.handleSceneChange(goTo, sceneType, options)

        end
    elseif (event.target.id == 'buttonSettings') then
        if ( event.phase == "ended" ) then
            local goTo = "resources.scene.menu.settingsmenu"
            local sceneType = "menu"
            local options = { effect = "fade", time = 400,}
            library.handleSceneChange(goTo, sceneType, options)
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

    local buttonPlay = widget.newButton(
        {
        left = ((display.viewableContentWidth+display.screenOriginX)/2)+200, --display.pixelWidth/2
        top = display.contentCenterY, -- Nicht ganz genau in Mitte, wegen Textfeld-Anchorpoint vorher: top = display.actualContentHeight/2
        id = "buttonPlay",
        label = "Play",
        onEvent = handleButtonEvent,
        fontSize = 30,
        labelColor = { default={ 255, 255, 255, 1}},
        }
    )
    local buttonSettings = widget.newButton(
        {
        left = ((display.viewableContentWidth+display.screenOriginX)/2)-200, --display.pixelWidth/2
        top = display.contentCenterY, -- Nicht ganz genau in Mitte, wegen Textfeld-Anchorpoint vorher: top = display.actualContentHeight/2
        id = "buttonSettings",
        label = "Settings",
        onEvent = handleButtonEvent,
        fontSize = 30,
        labelColor = { default={ 255, 255, 255, 1}},
        }
    )
    
    sceneGroup:insert( buttonPlay )
    sceneGroup:insert( buttonSettings )
end
 
 
-- show()
function scene:show( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)
 
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