local composer = require( "composer" )
local scene = composer.newScene()

local lib = require("resources.lib.lib")
local dusk = require("Dusk.Dusk")

-- -----------------------------------------------------------------------------------
-- Scene variables
-- -----------------------------------------------------------------------------------

scene.type = 'game'
scene.map = {}
scene.lastOverlay = nil
scene.level = 'level 1'

-- -----------------------------------------------------------------------------------
-- Scene functions
-- -----------------------------------------------------------------------------------

local function onEnterFrame(event)
    local map = scene.map
    map.updateView() -- Tracks the camera to the focus and updates culling
end

function scene:_showLastOverlay()
    local lastOverlay = scene.lastOverlay
    if lastOverlay then
        local options = {effect='fade', time=500}
        if lastOverlay == 'resources.scene.game.narrative' then
            options = scene.narrativeOptions
        end
        composer.showOverlay( scene.lastOverlay, options )
    end
end

function scene:pause()
    -- pause physics
    physics.pause()
    -- pause enemy loops
        -- behaviour

    --pause player loops
        -- stamina regeneration

    -- store last overlay
    scene.lastOverlay = composer.getSceneName( 'overlay' ) 
    -- Show pausescreen
    local options = {isModal=true, effect='fade', time=300}
    -- show overlay
    composer.showOverlay( 'resources.scene.menu.pausescreen', options )
    -- switch control-mode
    lib.control.setMode('menu', false)
end

function scene:resume()
    -- unpause physics
    physics.start()
    -- unpause enemy behaviour
    
    -- hide pausescreen
    composer.hideOverlay( true, 'fade', 500)
    -- show last overlay
    scene:_showLastOverlay()
    -- switch control-mode
    lib.control.setMode('game', false)
end

function scene:showNarrative(state, text, listener)
    local scenePath = 'resources.scene.game.narrative'
    if state then
        scene.lastOverlay = composer.getSceneName( 'overlay' )
        local options = {
            isModal = true,
            effect = "fade",
            time = 400,
            params = {
                text = text,
                fullscreen = false,
                pausePhysics = true,
                showHUD = true,
                fc = listener
            }
        }
        scene.narrativeOptions = options
        composer.showOverlay( scenePath, options )
    else
        -- function only works when this is the current overlay
        local currentOverlay = composer.getSceneName( 'overlay' )
        if currentOverlay == scenePath then
            composer.hideOverlay( true, 'fade', 500 )
            scene:_showLastOverlay()
        end
    end
end

function scene:showHUD(state)
    if state then
        local scenePath = 'resources.scene.game.hud'
        scene.lastOverlay = composer.getSceneName( 'overlay' )
        -- load HUD
        composer.showOverlay( scenePath, {isModal=true, effect='fade', time=1500} )
    else
        -- hide HUD
        composer.hideOverlay( true, options )
        -- show last overlay
        scene:_showLastOverlay()
    end
end

function scene:destroy()
    local map = scene.map
    map.destroy()

    -- stop enemy behaviour loop (map.destroy() doesnt cancel that...)
    timer.cancel('enemyBehaviourLoop')
end

function scene:onPlayerDeath()
    print("scene:onPlayerDeath")

    -- deactivate controls
    lib.control.setMode(nil, true)
    
    -- fade out music
    
    -- fade out scene

    -- stop animations

    -- get map and last overlay
    local overlay = composer.getScene( composer.getSceneName( 'overlay' ) )
    local overlayView = overlay.view
    local map = scene.map
    
    local function load()
        -- stop all loops (map.destroy() doesnt cancel that...)
        timer.cancelAll()

        -- destroy old map
        local map = scene.map
        map.destroy()
        local map = nil

        -- load level again
        lib.level.load('reload')
        local map = scene.map
        
        -- fade in music

        -- update HUD
        --hud:update()

        -- visual
        transition.from(map, {time=1500, transition=easing.inOutQuad, alpha=0})
        transition.to(overlayView, {time=1500, transition=easing.inOutQuad, alpha=1})

        -- activate controls
        lib.control.setMode(nil, false)
    end
    
    -- make screen fade (visual)
    transition.to( map, {time=500, transition=easing.inOutExpo, alpha=0, onComplete=load} )
    transition.to(overlayView, {time=500, transition=easing.inOutQuad, alpha=0})
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
 
-- create()
function scene:create( event )

    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen
 
end
 
 
-- show()
function scene:show( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)

        -- insert into sceneGroup
        local map = scene.map
        sceneGroup:insert(map)

        --show HUD
        scene:showHUD(true)
 
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
    
    Runtime:removeEventListener( "enterFrame", onEnterFrame )
    scene.map.destroy()
    --map = nil
end
 
 
-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------
Runtime:addEventListener( "enterFrame", onEnterFrame )

return scene