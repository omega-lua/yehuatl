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
scene.buttonTable = {}

-- -----------------------------------------------------------------------------------
-- Scene functions
-- -----------------------------------------------------------------------------------

function scene:updateCooldown( instance, state )
    -- Localize
    local map = scene.parent.map
    local player = map.layer['entities'].object['player']

    local function update(cooldown, last)
        local now = os.time()
        local delta = now - last
        local remaining = cooldown - delta
        if remaining >= 0 then
            local button = scene.buttonTable[instance] or {}
            local time = remaining * 1000
            button.alpha = 0.1
            local function fc()
                button.alpha = 0
                transition.to(button, {time=200, transisition=easing.inExpo, alpha=1})
            end
            transition.to(button, {time=time, transisition=easing.inExpo, alpha=1, onComplete=fc})
        end
    end

    if instance == 'all' then
        --
    elseif instance == 'meleeAttack' then
        local cooldown = player.combat.cooldownMeleeAttack
        local last = player.combat.lastMeleeAttack  
        update(cooldown, last)
    
    elseif instance == 'rangedAttack' then
        local cooldown = player.combat.cooldownRangedAttack
        local last = player.combat.lastRangedAttack
        update(cooldown, last)
    
    elseif instance == 'block' then
        local cooldown = player.combat.cooldownBlock
        local last = player.combat.lastBlock
        local isBlocking = player.isBlocking

        local button = scene.buttonTable[instance] or {}
        
        if state == 'blocked' then
            update(cooldown, last)
        elseif state == 'cancel' then
            transition.cancel( scene.transitionBlockingPressing )
            button.alpha = 1
        elseif state == 'begin' then
            scene.transitionBlockingPressing = transition.to(button, {time=1000, easing=easing.continuousLoop, alpha=0, iterations=-1})
        end

    elseif instance == 'ability' then
        --
    end
end

local function buildButtons()
    -- ----------------------------------
    -- Create buttons
    -- ----------------------------------
    local sceneGroup = scene.view
    local rightBorder = 600 + (display.actualContentWidth - 600)*0.5
    local leftBorder = -(display.actualContentWidth - 600)*0.5
    local listener = lib.control.touch.game
    local t = {}
    
    -- differentiate between control modes
    if lib.control.mode == 'key' then
        t['meleeAttack'] = display.newImage(sceneGroup,'resources/graphics/hud/meleeAttack.png', 380, 350 )
        t['rangedAttack'] = display.newImage(sceneGroup,'resources/graphics/hud/rangedAttack.png', 300, 350)
        t['block'] = display.newImage(sceneGroup,'resources/graphics/hud/block.png', 220, 350 )

        -- iterate through all buttons
        for name, button in pairs(t) do
            -- transform button
            button:scale(1.6, 1.6)
            button:toFront()
            -- add a handle
            scene.buttonTable[name] = button
        end

    else
        t['pressingBackward'] = display.newImage(sceneGroup,'resources/graphics/hud/arrow_left.png', -20, 300)
        t['pressingForward'] = display.newImage(sceneGroup,'resources/graphics/hud/arrow_right.png', 80, 300)
        t['jump'] = display.newImage(sceneGroup,'resources/graphics/hud/jump.png', rightBorder-65, 200)
        t['meleeAttack'] = display.newImage(sceneGroup,'resources/graphics/hud/meleeAttack.png', rightBorder-145, 280 )
        t['rangedAttack'] = display.newImage(sceneGroup,'resources/graphics/hud/rangedAttack.png', rightBorder-235, 350)
        t['block'] = display.newImage(sceneGroup,'resources/graphics/hud/block.png', rightBorder-175, 180 )
        t['ability'] = display.newImage(sceneGroup,'resources/graphics/hud/ability.png', rightBorder-250, 255)
        t['interact'] = display.newImage(sceneGroup,'resources/graphics/hud/interact.png', rightBorder-55, 350 )
        t['pause'] = display.newImage(sceneGroup,'resources/graphics/hud/pause.png', leftBorder+30, 25 )

        -- iterate through all buttons
        for name, button in pairs(t) do
            -- add event listener
            button:addEventListener( 'touch', listener )
            -- add command variable for handleInteraction()
            button.command = name
            -- transform button
            button:scale(1.6, 1.6)
            button:toFront()
            -- add a handle
            scene.buttonTable[name] = button
        end

        -- small visual adjustments
        t['pause']:scale(0.7,0.7)
        t['meleeAttack']:scale(1.7, 1.7)
    end
end

function scene:build()
    -- Localize
    local sceneGroup = scene.view

    -- ----------------------------------
    -- Create healthbar
    -- ----------------------------------
    local options = { frames = {
        -- Frame 1
        {
            x = 0,
            y = 0,
            width = 86,
            height = 4
        },  
        -- Frame 2
        {
            x = 0,
            y = 4,
            width = 86,
            height = 4
        }, 
        -- Frame 3
        {
            x = 0,
            y = 8,
            width = 86,
            height = 4
        }, 
        -- Frame 4
        {
            x = 0,
            y = 12,
            width = 86,
            height = 4
        }, 
        -- Frame 5
        {
            x = 0,
            y = 16,
            width = 86,
            height = 4
        }, 
        -- Frame 6
        {
            x = 0,
            y = 20,
            width = 86,
            height = 4
        }, 
        -- Frame 7
        {
            x = 0,
            y = 24,
            width = 86,
            height = 4
        }, 
        -- Frame 8
        {
            x = 0,
            y = 28,
            width = 86,
            height = 4
        }, 
        -- Frame 9
        {
            x = 0,
            y = 32,
            width = 86,
            height = 4
        }, 
        -- Frame 10
        {
            x = 0,
            y = 36,
            width = 86,
            height = 4
        }, 
        -- Frame 11
        {
            x = 0,
            y = 40,
            width = 86,
            height = 4
        }}
    }
    local imageSheet = graphics.newImageSheet( "resources/graphics/hud/healthbar.png", options )
    local image = display.newImage(sceneGroup, imageSheet, 1 )
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
    image.x = 300
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

    buildButtons()
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
    -- remove old image
    local image = scene.healthbar.object
    image:removeSelf()
    -- load new image
    local imageSheet = scene.healthbar.imageSheet
    local image = display.newImage( sceneGroup, imageSheet, frameNumber )
    -- transform
    image:scale(3, 2.2)
    image.x = 300
    image.y = 22
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
    image.x = 300
    image.y = 13

    -- set variable
    scene.staminabar.object = image

    -- add touchscreen-controls if type is 'touch'
    --local inputDeviceType = lib.inputdevice.current.type
    local inputDeviceType = 'touch'
    if inputDeviceType == 'touch' then
        scene:updateCooldown('all')
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