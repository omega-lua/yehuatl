-- Scene Template from Solar2D-Guide: https://docs.coronalabs.com/guide/system/composer/index.html#template

local dusk = require("Dusk.Dusk")
local composer = require( "composer" )
local scene = composer.newScene()
 

-- -----------------------------------------------------------------------------------
-- Scene variables
-- -----------------------------------------------------------------------------------
map = {}
map.extensions = "resources.lib."
dusk.setPreference('detectMapPath', true)
scene.mapPath = "resources/scene/game/map1/tiledMapTEST.tmj"

-- Get Settings
-- local trackingLevel = settings.tracklingLevel

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

local function onEnterFrame(event)
    map.updateView() -- Tracks the camera to the focus and updates culling

end

function scene:makeMap()
    sceneGroup = scene.view
    map = dusk.buildMap(scene.mapPath)

    map.extend('player')
    player = map.layer['Object Layer 1'].object["player"] -- The object named "player" in Tiled

    map.enableFocusTracking(true)
    map.setCameraFocus(player)
    map.setTrackingLevel(0.1)
    
    sceneGroup:insert(map)
    
    Runtime:addEventListener( "enterFrame", onEnterFrame)
end

function scene:pauseGame()
    print("Game paused")
    -- Stop physics
    physics.pause()
    -- Stop audio

    -- Stop animations

    -- Make darker
    --self.view.alpha = 0.5
    transition.fadeOut( sceneGroup, {time=1000, transition=easing.inOutCubic} )
end

function scene:resumeGame()
    print("Game resumed")
    -- Start physics
    physics.start()
    -- Play audio

    -- Start animation

    -- Make brighter
    --self.view.alpha = 1
    transition.fadeIn( sceneGroup, {time=2000, transition=easing.inOutCubic} )
end

-- create()
function scene:create( event )
    sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen

    scene:makeMap()
end

-- show()
function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        physics.start()
    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen
    end
end

 
-- hide()
function scene:hide( event )
    local sceneGroup = self.view
    local phase = event.phase

    physics.pause()
    local current = composer.getSceneName("current")
    composer.removeScene(current)
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is on screen (but is about to go off screen)
    elseif ( phase == "did" ) then
        -- Code here runs immediately after the scene goes entirely off screen
        transition.cancel()
    end
end
 
 
-- destroy()
function scene:destroy( event )

    local sceneGroup = self.view
    -- Code here runs prior to the removal of scene's view
    print("Map1 destroyed")

    -- Remove event function listeners
    scene:removeEventListener( "create", scene)
    scene:removeEventListener( "show", scene)
    scene:removeEventListener( "hide", scene)
    scene:removeEventListener( "destroy", scene)
    Runtime:removeEventListener( "enterFrame", onEnterFrame)
end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

--Runtime:addEventListener( "enterFrame", onEnterFrame)
-- -----------------------------------------------------------------------------------

return scene