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
scene.gamePaused = false

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

    scene.gamePaused = true

    -- store last overlay
    scene.lastOverlay = composer.getSceneName( 'overlay' ) 
    
    -- show pausescreen
    local options = {isModal=true, effect='fade', time=300} 
    composer.showOverlay( 'resources.scene.menu.pausescreen', options )
    
    -- reset player movement variables
    local player = scene.map.layer['entities'].object['player']
    player.pressingForward = false
    player.pressingBackward = false
    player.pressingJump = false
    
    -- switch control-mode
    lib.control.setMode('menu', false)
end

function scene:resume()
    -- unpause physics
    physics.start()
    
    scene.gamePaused = false
    
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

function scene:onPlayerDeath()
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
        -- destroy map
        scene:destroy()

        -- build level/map again
        scene:build()
        local map = scene.map

        -- update HUD
        if overlay._name == 'hud' then
            overlay:update()
        end

        -- fade in music

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

function scene:build()
    savefile = lib.savefile.current.data
    -- setup and pause physics
    lib.level.setUpPhysics()

    -- build map with dusk engine
    local filePath = "resources/scene/game/level1/map.lua"
    local dusk = require("Dusk.Dusk")
    -- make map a global variable for easier access?
    local map = dusk.buildMap( filePath )
    scene.map = map

    -- insert into sceneGroup
    local sceneGroup = scene.view
    sceneGroup:insert(map)

    -- get all classes
    local classes = {}
    for object in map.layer['entities'].objects() do
        local class = object._type
        if (class ~= "") then
            if not table.indexOf(classes, class) then
                classes[#classes+1] = class
            end
        end
    end

    -- extend classes
    map.extend(unpack(classes))

    -- update entities, if the level was found in savefile
    if savefile.levels[level] then
        local entities = savefile.levels[level].entities
        for name, data in pairs(entities) do
            if not (name == 'player') then
                -- update other entities
                local entity = map.layer["entities"].object[name]
                entity.x = data.x
                entity.y = data.y
                if data.health then entity.health = data.health end
                entity.isDead = data.isDead
                entity.inventory = data.inventory
            end
        end
    end

    -- update player object
    local player = map.layer['entities'].object['player']

    -- add frame update
    Runtime:addEventListener( "enterFrame", onEnterFrame )

    -- camera setup
    map:scale(3.5, 3.5)
    map.enableFocusTracking(true)
    map.setCameraFocus(player)
    map.setTrackingLevel(0.1)

    -- start physics
    physics.start()
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
 
-- create()
function scene:create( event )

    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen

    scene:build()
end
 
 
-- show()
function scene:show( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)

        --show HUD
        scene:showHUD(true)

        -- fade in visual
        local rectangle = display.newRect( sceneGroup, 300, 200, 1200, 500 )
        local function fc() rectangle:removeSelf() end
        rectangle:setFillColor(0,0,0,1)
        rectangle:toFront()

        transition.to(rectangle, {transition=easing.inOutSine, time=2000, alpha=0, onComplete=fc})
 
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
    -- Code here runs prior to the removal of scene's view
    local sceneGroup = self.view
    local map = scene.map
    
    -- Remove frame refreshing
    Runtime:removeEventListener( "enterFrame", onEnterFrame )
    
    -- cancel all timers
    timer.cancelAll()

    -- destroy map
    map.destroy()
    map = nil
end
 
 
-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

return scene