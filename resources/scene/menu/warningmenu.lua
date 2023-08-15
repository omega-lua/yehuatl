-- Template from Solar2D-Guide: https://docs.coronalabs.com/guide/system/composer/index.html#template

local composer = require( "composer" )
local widget = require("widget")
local library = require("library")

local scene = composer.newScene()
 
-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
 
local function handleButtonEvent(event)
    if (event.phase == 'ended') then
        if (event.target.id == "buttonBack") then
            composer.hideOverlay("fade", 500)
        elseif (event.target.id == "buttonApplySettings") then
            parent:applySettings()
            
            -- Message
            parent:showToast("Settings applied!")

            composer.hideOverlay("fade", 200)

        elseif (event.target.id == "buttonDiscardSettings") then
            parent.isSaved = true
            parent.tmpSettings = {}

            -- Message
            parent:showToast("Settings discarded!")
            
            composer.hideOverlay("fade", 200)
            library.handleSceneChange("resources.scene.menu.mainmenu", "menu", { effect = "fade", time = 100,})
        end
    end
end
 
local function loadUI()
    local sceneGroup = scene.view
    -- Code here runs when the scene is first created but has not yet appeared on screen

    local overlayBox = display.newRect(
        display.contentCenterX,
        display.contentCenterY, 
        600, 
        300
    )
    
    local buttonBack = widget.newButton({
        x = display.contentCenterX*1.2,
        y = display.contentCenterY*1.5,
        id = "buttonBack",
        label = "back",
        onEvent = handleButtonEvent,
        font = "fonts/BULKYPIX.TTF",
        fontSize = 25,
        labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0, 0.5 } }
    })

    local buttonApplySettings = widget.newButton({
        x = display.contentCenterX*0.5,
        y = display.contentCenterY*1.5,
        id = "buttonApplySettings",
        label = "Apply Settings",
        onEvent = handleButtonEvent,
        font = "fonts/BULKYPIX.TTF",
        fontSize = 25,
        labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0, 0.5 } }
    })

    local buttonDiscardSettings = widget.newButton({
        x = display.contentCenterX*1.9,
        y = display.contentCenterY*1.5,
        id = "buttonDiscardSettings",
        label = "Discard Settings",
        onEvent = handleButtonEvent,
        font = "fonts/BULKYPIX.TTF",
        fontSize = 25,
        labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0, 0.5 } }
    })

    sceneGroup:insert(overlayBox)
    sceneGroup:insert(buttonBack)
    sceneGroup:insert(buttonApplySettings)
    sceneGroup:insert(buttonDiscardSettings)
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
 
-- create()
function scene:create( event )
    --display.getCurrentStage():setFocus( warningmenu )
    
    loadUI()
end
 
 
-- show()
function scene:show( event )
 
    local sceneGroup = self.view
    local phase = event.phase
    parent = event.parent
 
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