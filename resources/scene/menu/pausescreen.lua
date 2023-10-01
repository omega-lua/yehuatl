-- Template from Solar2D-Guide: https://docs.coronalabs.com/guide/system/composer/index.html#template

local lib = require( "resources.lib.lib" )
local widget = require( "widget" )
local composer = require( "composer" )
local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Scene variables
-- -----------------------------------------------------------------------------------

scene.type = 'menu'

-- -----------------------------------------------------------------------------------
-- Scene functions
-- -----------------------------------------------------------------------------------

local function handleButtonEvent(event)
    if (event.phase == 'ended') then    
        if (event.target.id == "buttonResume") then
            handlePauseScreen()
        elseif (event.target.id == 'buttonExit') then  
            local changeTo = "resources.scene.menu.mainmenu"
            local sceneType = "menu"
            local options = { effect = "fade", time = 800,}
            lib.scene.show(changeTo, sceneType, options)
        elseif (event.target.id == 'buttonSave') then  
            print("saving...")
            saveGameProgress()
            --changeToscene
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

    -- Create the widget
    local buttonResume = widget.newButton({
        left = ((display.viewableContentWidth+display.screenOriginX)/2),
        top = (display.actualContentHeight / 2),
        id = "buttonResume",
        label = "Resume",
        font = "fonts/BULKYPIX.TTF",
        fontSize = 30, 
        onEvent = handleButtonEvent, 
        labelColor = { default={ 255, 255, 255, 1}}
    })

    local buttonExit = widget.newButton({
        left = ((display.viewableContentWidth+display.screenOriginX)/2)-300,
        top = (display.actualContentHeight / 2),
        id = "buttonExit",
        label = "Exit",
        font = "fonts/BULKYPIX.TTF",
        fontSize = 30, 
        onEvent = handleButtonEvent, 
        labelColor = { default={ 255, 255, 255, 1}}
    })

    local buttonSave = widget.newButton({
        left = ((display.viewableContentWidth+display.screenOriginX)/2)+300,
        top = (display.actualContentHeight / 2),
        id = "buttonSave",
        label = "Save",
        font = "fonts/BULKYPIX.TTF",
        fontSize = 30, 
        onEvent = handleButtonEvent, 
        labelColor = { default={ 255, 255, 255, 1}}
    })
    sceneGroup:insert(buttonExit)
    sceneGroup:insert(buttonResume)
    sceneGroup:insert(buttonSave)
end
 
 
-- show()
function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)
 
    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen
        overlaySceneStatus = true
    end
end
 
 
-- hide()
function scene:hide( event )
    local sceneGroup = self.view
    local phase = event.phase
    local parent = event.parent  --reference to the parent scene object
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is on screen (but is about to go off screen)
        --parent:resumeGame()
        print("will-hidephase")
 
    elseif ( phase == "did" ) then
        -- Code here runs immediately after the scene goes entirely off screen
        print("did-hidephase:")
        overlaySceneStatus = false
        print(overlaySceneStatus)
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