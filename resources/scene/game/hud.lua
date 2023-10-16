local composer = require( 'composer' )
local lib = require( 'resources.lib.lib' )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Scene variables
-- -----------------------------------------------------------------------------------

scene._name = 'hud'
scene.type = 'game'
scene.parent = nil
scene.healthbar = {imageSheet=nil, object=nil}
scene.staminabar = {imageSheet=nil, object=nil}

-- -----------------------------------------------------------------------------------
-- Scene functions
-- -----------------------------------------------------------------------------------

local function updateCooldowns()
    -- Localize
    local map = scene.parent.map
    local player = map.layer['entities'].object['player']
    local lastMeleeAttack = player.lastMeleeAttack
    local lastRangedAttack = player.lastRangedAttack
    local lastBlock = player.lastBlock
    local lastAbility = player.lastAbility

    -- we have to use transitions here, so its smooth.
end

local function buildTouchControls()
    -- ----------------------------------
    -- Create buttons
    -- ----------------------------------
    local sceneGroup = scene.view
    local rightBorder = 600 + (display.actualContentWidth - 600)*0.5
    local leftBorder = -(display.actualContentWidth - 600)*0.5
    
    local moveBackward = display.newImage(sceneGroup,'resources/graphics/hud/arrow_left.png', -20, 300)
    moveBackward.command = 'pressingBackward'
    moveBackward:scale(1.2, 1.2)
    moveBackward:toFront()
    
    local moveForward = display.newImage(sceneGroup,'resources/graphics/hud/arrow_right.png', 80, 300)
    moveForward.command = 'pressingForward'
    moveForward:scale(1.2, 1.2)
    moveForward:toFront()

    local jump = display.newImage(sceneGroup,'resources/graphics/hud/jump.png', rightBorder-65, 200)
    jump.command = 'jump'
    jump:scale(1.2, 1.2)
    jump:toFront()

    local meleeAttack = display.newImage(sceneGroup,'resources/graphics/hud/meleeAttack.png', rightBorder-145, 280 )
    meleeAttack:scale(1.5, 1.5)
    meleeAttack.command = 'meleeAttack'
    meleeAttack:scale(1.2, 1.2)
    meleeAttack:toFront()

    local rangedAttack = display.newImage(sceneGroup,'resources/graphics/hud/rangedAttack.png', rightBorder-235, 350)
    rangedAttack.command = 'rangedAttack'
    rangedAttack:scale(1.2, 1.2)
    rangedAttack:toFront()
    
    local block = display.newImage(sceneGroup,'resources/graphics/hud/block.png', rightBorder-175, 180 )
    block.command = 'block'
    block:scale(1.2, 1.2)
    block:toFront()
    
    local ability = display.newImage(sceneGroup,'resources/graphics/hud/ability.png', rightBorder-250, 255)
    ability.command = 'ability'
    ability:scale(1.2, 1.2)
    ability:toFront()
    
    local pause = display.newImage(sceneGroup,'resources/graphics/hud/pause.png', leftBorder+30, 25 )
    pause.command = 'pause'
    pause:scale(1.2, 1.2)
    pause:toFront()

    local interact = display.newImage(sceneGroup,'resources/graphics/hud/interact.png', rightBorder-55, 350 )
    interact.command = 'interact'
    interact:scale(1.2, 1.2)
    interact:toFront()

    -- ----------------------------------
    -- Add touch eventListener
    -- ----------------------------------
    local listener = lib.control.touch.game
    moveBackward:addEventListener( 'touch', listener )
    moveForward:addEventListener( 'touch', listener )
    jump:addEventListener( 'touch', listener )
    meleeAttack:addEventListener( 'touch', listener )
    rangedAttack:addEventListener( 'touch', listener )
    block:addEventListener( 'touch', listener )
    ability:addEventListener( 'touch', listener )
    pause:addEventListener( 'touch', listener )
    interact:addEventListener( 'touch', listener )
end

function scene:build()
    -- Localize
    local sceneGroup = scene.view

    -- ----------------------------------
    -- Create healthbar
    -- ----------------------------------
    local options = {width = 200, height = 11, numFrames = 10}
    local imageSheet = graphics.newImageSheet( "resources/graphics/hud/healthbar.png", options )
    local image = display.newImage(sceneGroup, imageSheet, 10 )
    -- transform
    image:scale(2.2, 2.2)
    image.x = 300
    image.y = 30
    image:toFront()
    -- Set variables
    scene.healthbar.imageSheet = imageSheet
    scene.healthbar.object = image
    
    -- ----------------------------------
    -- Create staminabar
    -- ----------------------------------
    local options = {
        frames =
        {
            -- Frame 1
            {
                x = 0,
                y = 0,
                width = 100,
                height = 3
            },         
            -- Frame 2
            {
                x = 0,
                y = 3,
                width = 100,
                height = 3
            },
            -- Frame 3
            {
                x = 0,
                y = 6,
                width = 100,
                height = 3
            },         
            -- Frame 4
            {
                x = 0,
                y = 9,
                width = 100,
                height = 3
            },
            -- Frame 5
            {
                x = 0,
                y = 12,
                width = 100,
                height = 3
            },         
            -- Frame 6
            {
                x = 0,
                y = 15,
                width = 100,
                height = 3
            },
            -- Frame 7
            {
                x = 0,
                y = 18,
                width = 100,
                height = 3
            },         
            -- Frame 8
            {
                x = 0,
                y = 21,
                width = 100,
                height = 3
            },
            -- Frame 9
            {
                x = 0,
                y = 24,
                width = 100,
                height = 3
            },         
            -- Frame 10
            {
                x = 0,
                y = 27,
                width = 100,
                height = 3
            },
            -- Frame 11
            {
                x = 0,
                y = 30,
                width = 100,
                height = 3
            },         
            -- Frame 12
            {
                x = 0,
                y = 33,
                width = 100,
                height = 3
            },
            -- Frame 13
            {
                x = 0,
                y = 36,
                width = 100,
                height = 3
            },         
            -- Frame 14
            {
                x = 0,
                y = 39,
                width = 100,
                height = 3
            },
            -- Frame 15
            {
                x = 0,
                y = 42,
                width = 100,
                height = 3
            },         
            -- Frame 16
            {
                x = 0,
                y = 45,
                width = 100,
                height = 3
            },
            -- Frame 17
            {
                x = 0,
                y = 48,
                width = 100,
                height = 3
            },         
            -- Frame 18
            {
                x = 0,
                y = 51,
                width = 100,
                height = 3
            },
            -- Frame 19
            {
                x = 0,
                y = 54,
                width = 100,
                height = 3
            },         
            -- Frame 20
            {
                x = 0,
                y = 57,
                width = 100,
                height = 3
            },
            -- Frame 21
            {
                x = 0,
                y = 60,
                width = 100,
                height = 3
            }
        }
    }
    local imageSheet = graphics.newImageSheet( "resources/graphics/hud/staminabar.png", options )
    local image = display.newImage( sceneGroup, imageSheet, 21 )
    -- transform
    image:scale(2.2, 2.2)
    image.x = 290
    image.y = 13
    image:toFront()
    -- Set variables
    scene.staminabar.imageSheet = imageSheet
    scene.staminabar.object = image

    -- ----------------------------------
    -- Show current level
    -- ----------------------------------
    local scene = composer.getScene( composer.getSceneName( 'current' ) )
    local currentLevel = scene.level
    local rightBorder = 600 + (display.actualContentWidth - 600)*0.5
    local options = {
        parent = sceneGroup,
        text = currentLevel,
        x = rightBorder-100,
        y = 25,
        font = "fonts/BULKYPIX.TTF",
        fontSize = 20
    }
    local text = display.newText( options )
    text:setFillColor( 0.2, 0.2, 0.2 )

    -- add touchscreen-controls if type is 'touch'
    --local inputDeviceType = lib.inputdevice.current.type
    local inputDeviceType = 'touch' --DEBUG
    if inputDeviceType == 'touch' then
        buildTouchControls()
    else
        -- show ability cooldown
    end
end

function scene:update()
    print("udpate hud...")
    -- ----------------------------------
    -- Localize
    -- ----------------------------------
    local math = math
    local sceneGroup = scene.view
    local levelScene = composer.getScene( composer.getSceneName( 'current' ) )
    local map = levelScene.map
    local player = map.layer["entities"].object['player']

    -- ----------------------------------
    -- Update Healthbar
    -- ----------------------------------
    -- get variables and framenumber
    local hitpoints = player.health.hitpoints
    local maxHitpoints = player.health.maxHitpoints
    local ratio = hitpoints / maxHitpoints
    local frameNumber = math.round( ratio * 10 ) + 1
    if frameNumber == 11 then frameNumber = 10 end
    -- remove old image
    local image = scene.healthbar.object
    image:removeSelf()
    -- load new image
    local imageSheet = scene.healthbar.imageSheet
    local image = display.newImage( sceneGroup, imageSheet, frameNumber )
    -- transform
    image:scale(2.2, 2.2)
    image.x = 300
    image.y = 30
    -- set variable
    scene.healthbar.object = image

    -- ----------------------------------
    -- Update Staminabar
    -- ----------------------------------
    -- get variables and framenumber
    local stamina = player.health.stamina
    local maxStamina = player.health.maxStamina
    local ratio = stamina / maxStamina
    local frameNumber = (math.round( ratio * 20)) + 1 -- (0-20) --> (1-21)
    -- remove old image
    local image = scene.staminabar.object
    image:removeSelf()
    -- load new image
    local imageSheet = scene.staminabar.imageSheet
    local image = display.newImage( sceneGroup, imageSheet, frameNumber )

    -- transform 
    image:scale(2.2, 2.2)
    image.x = 290
    image.y = 13

    -- set variable
    scene.staminabar.object = image

    -- add touchscreen-controls if type is 'touch'
    --local inputDeviceType = lib.inputdevice.current.type
    local inputDeviceType = 'touch'
    if inputDeviceType == 'touch' then
        updateCooldowns()
    else
        --
    end
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
    scene.parent = event.parent
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)

        scene:update()
 
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