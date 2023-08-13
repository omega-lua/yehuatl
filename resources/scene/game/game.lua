-- Scene Template from Solar2D-Guide: https://docs.coronalabs.com/guide/system/composer/index.html#template
local composer = require "composer"
local library = require "library"
local scene = composer.newScene()

local json = require "json"
local physics = require "physics"
-- -----------------------------------------------------------------------------------

overlaySceneStatus = false
function handlePauseScreen()
    local currScene = composer.getSceneName( "current" )
    local map = composer.getScene( currScene )

    -- Show Overlay
    if (overlaySceneStatus == false) then
        -- For Consistency Reasons
        overlaySceneStatus = nil
        
        -- pause map
        map:pauseGame()
        
        -- Show pausescreen-Overlay
        local options = { effect = "fade", time = 500, isModal = true,}
        composer.showOverlay("resources.scene.menu.pausescreen", options)

    -- Hide Overlay
    elseif (overlaySceneStatus == true) then
        -- For Consistency Reasons
        overlaySceneStatus = nil
        
        -- Hide pausescrean-Overlay
        composer.hideOverlay(false, "fade", 500)
        
        -- unpause map
        map:resumeGame()
    end
end


function saveGameProgress()
    -- >> ACHTUNG: Normales saveGameProgress() in den früheren Versionen zu finden, da hier ist EXPERIMENTELL <<
    
    local filePath = "testSAVE"
    local data = map
    print("---------------------------------------")
    --library.printTable(data)

    --Encode data to JSON-format
    local encoded = json.encode( data, { indent=true } )

    -- Write to current savefile.
    
end


-- create()
function scene:create( event )
    -- Code here runs when the scene is first created, but has not yet appeared on screen
    local sceneGroup = self.view

    -- Only occurs when no savefiles found, and user presses play. For example during first time launching.
    if not currentSaveFile then
        library.newSaveFile()
    end
    library.loadSaveFile(currentSaveFile)
end

 
-- show()
function scene:show( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)

        library.handleSceneChange(currentMapPath, "game", {})
    
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