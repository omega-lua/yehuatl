-- Define module
local M = {}

function M.new( instance, options )
    if not instance then error( "ERROR: Expected display object" ) end

    -- Localize
    local composer = require( 'composer' )

    ------------------------------------------------------------------
    -- instance variables
    ------------------------------------------------------------------
    instance.isDead = false
    instance.bodyContacts = 0
    instance.groundContacts = 0
    instance.rightWallContacts = 0
    instance.leftWallContacts = 0
    instance.attackTable = {}

    instance.pressingForward = false
    instance.pressingBackward = false

    instance.activeLoops = {}
    
    instance.movement = {
        speed = 50,
        jumpHeight = -22
    }
    instance.health = {
        hitpoints = 20,
        maxHitpoints = 10
    }
    instance.combat = {
        strength = 5
    }

    ------------------------------------------------------------------
    -- Setup physics body
    ------------------------------------------------------------------

    local bodyShape = {-16,-26, 16,-26, 16,31, -16,31}
    physics.addBody( instance, "dynamic", {shape=bodyShape, density=4},              -- 1: body element (hitbox)
        { box={ halfWidth=14, halfHeight=2, x=0, y=32 }, isSensor=true },     -- 2: Foot sensor element
        { box={ halfWidth=2, halfHeight=17, x=18, y=12 }, isSensor=true },    -- 3: Right Side sensor element
        { box={ halfWidth=2, halfHeight=17, x=-18, y=12 }, isSensor=true },    -- 4: Left Side sensor element
        { box={ halfWidth=32, halfHeight=17, x=0, y=7 }, isSensor=true } ,    -- 5: Reach/Range sensor element
        { box={ halfWidth=28, halfHeight=20, x=0, y=7 }, isSensor=true }     -- 6: Attack sensor element
    )
    instance.isFixedRotation = true
    
    ------------------------------------------------------------------
    -- Instance functions
    ------------------------------------------------------------------

    local function handleLoop(_tag, listener, delay)
        local activeLoops = instance.activeLoops
        
        -- stop all timers/loops
        if not _tag then
            for i, tag in pairs(activeLoops) do
                timer.cancel( tag )
            end
            instance.activeLoops = {}
            return true
        end

        local name = instance._name..":"
        local tag = name.._tag
        local index = table.indexOf(activeLoops, tag)
        
        -- add one loop
        if listener then
            if not index then
                instance.activeLoops[#activeLoops+1] = tag
            end
            timer.performWithDelay( delay, listener, -1, tag )
        
        -- stop one loop
        else
            if index then
                timer.cancel( tag )
                instance.activeLoops[index] = nil
            end
        end
    end

    function instance:die()
        local function fc(event)
            -- Set the rectangle's active state
            instance.isBodyActive = false
            
            -- Audio (with timer to later delete object)
            
            -- Animation, and then delete object (after animation/tranisition finished)

            -- delete object
            display.remove( instance )
            instance = nil
        end

        if not instance.isDead then
            -- let function run only once
            instance.isDead = true

            -- stop all timers/loops
            handleLoop(nil)
            
            -- perform action with delay to prevent bugs while in physics collision
            timer.performWithDelay(18, fc)
        end
    end

    function instance:block(state)
        if (state == 'begin') then
            print("blocking")
            instance.isBlocking = true
        
        elseif (state == 'cancel') then
            print("cancel block")
            instance.isBlocking = false
        
        elseif (state == 'blocked') then
            print("block successfull.")
            instance.isBlocking = false
        end
    end

    function instance:jump()
        if instance.groundContacts > 0 then
            local jumpHeight = instance.movement.jumpHeight
            local vx, vy = instance:getLinearVelocity()
            instance:setLinearVelocity(vx, 0)
            instance:applyLinearImpulse(nil, jumpHeight)
            
            -- cancel behaviour loop
            handleLoop('tryToJump', nil)
        end
    end
    
    function instance:goTo(target)
        if target == 'player' then

            -- activate wall encountering
            local function onWallContact(event)
                local selfElement = event.selfElement
                local other = event.other
                local phase = event.phase
                if (selfElement == 4 and instance.pressingBackward) or (selfElement == 3 and instance.pressingForward) then
                    if phase == 'began' then
                        if other.isGround then
                            -- define local function
                            local function f1() instance:jump() end
                            -- add loop
                            handleLoop('tryToJump', f1, 1200)
                            -- try on once on direct contact
                            instance:jump()
                        end
                    end
                end
            end

            instance:addEventListener('collision', onWallContact)

            -- get player table
            local scene = composer.getScene( composer.getSceneName( 'current' ) )
            local map = scene.map
            local player = map.layer['entities'].object['player']

            local function updateWalkDirection()
                -- get player coordinates
                local px, py = player.x, player.y
                -- get current instance coordinates
                local ix, iy = instance.x, instance.y

                -- set velocity
                local speed = instance.movement.speed
                if ix < px then
                    instance:setLinearVelocity( speed, nil )
                    instance.pressingForward = true
                    instance.pressingBackward = false
                    -- visual
                    instance.xScale = -1
                else
                    instance:setLinearVelocity( -speed, nil )
                    instance.pressingForward = false
                    instance.pressingBackward = true
                    -- visual
                    instance.xScale = 1
                end
            end

            -- add loop
            handleLoop('goTo', updateWalkDirection, 700)
        else
            -- stop behaviour loops
            handleLoop('goTo', nil)
            handleLoop('tryToJump', nil)

            -- stop velocity
            instance:setLinearVelocity(0, nil)

            -- deactivate jump handler
            instance:removeEventListener( 'collision', onWallContact )
        end
    end

    local function behaviour(event)
        if event.vision then -- only receives starting event
            print("- vision on player")
            -- walk to player
            instance:goTo('player')

        elseif event.health == 'low' then -- only receives starting event
            --
        elseif event.contact then -- only gets called from handleCollision on direct contact, sends start and stop input
            local tag = 'attacking'
            if event.contact.state then
                print("event.contact")
                -- define local function
                local function f1() instance:meleeAttack() end
                -- add Loop
                handleLoop(tag, f1, 2000)
            else
                -- stop attack loop
                handleLoop(tag, nil)
            end
        else
            -- go to idle
        end
    end

    function instance:meleeAttack()
        print("meleeAttack!")
        -- Localize
        local scene = composer.getScene(composer.getSceneName("current"))
        local map = scene.map
        local strength = instance.combat.strength
        local xScale = instance.xScale
        local ix = instance.x
        local t = instance.attackTable
        
        -- iterate through attackTable
        for i, name in pairs(t) do
            local entity = map.layer['entities'].object[name]
            local x = entity.x
            -- Attacks only enemies which instance faces.
            if (xScale == 1) and (x < ix) or (xScale == -1) and (x > ix)then
                entity:handleHealth(strength)
            end
        end
    end

    function instance:handleHealth(amount, heal)
        local hitpoints = instance.health.hitpoints
        local maxHitpoints = instance.health.maxHitpoints
        local ratio = hitpoints / maxHitpoints
        if heal then
            hitpoints = hitpoints + amount
            if hitpoints > maxHitpoints then hitpoints = maxHitpoints end
        else
            if instance.isBlocking then
                return false
                -- maybe play sound
            end
            hitpoints = hitpoints - amount
        end

        -- debug visual for current hitpoints
        instance.alpha = ratio

        -- update variable
        instance.health.hitpoints = hitpoints

        -- check if dead
        if hitpoints <= 0 then
            instance:die()
        end
        -- start behaviour when under 0.3
        if ratio <= 0.3 then
            behaviour({health = 'low'})
        end
    end

    local function handleCollision(event)
        -- Localize
        local selfElement = event.selfElement
        local other = event.other
        local isGround = other.isGround
        local phase = event.phase
        local str

        -- distinct between body-elements
        if (selfElement == 1) and not isGround then
            if other.isVoid then
                instance:die()
                return
            end
            str = 'bodyContacts'
        elseif (selfElement == 2) and isGround then
            str = 'groundContacts'
        elseif (selfElement == 3) and isGround then
            str = 'rightWallContacts'
        elseif (selfElement == 4) and isGround then
            str = 'leftWallContacts'
        elseif (selfElement == 5) and not isGround then
            return false
        elseif (selfElement == 6) and not isGround then
            local name = other._name
            if (name == 'player') and (event.otherElement == 1) then
                local t = instance.attackTable
                if (phase == 'began') then
                    t[1] = name
                    instance:dispatchEvent({name='behaviour', contact={state=true}})
                elseif (phase == 'ended') then
                    t[1] = nil
                    instance:dispatchEvent({name='behaviour', contact={state=false}})
                end
            end
            return false
        else
            return false
        end

        -- change value
        if (phase == 'began') then
            instance[str] = instance[str] + 1
        elseif (phase == 'ended') then
            instance[str] = instance[str] - 1
        end

        -- special cases
        if (phase == 'ended') and (event.selfElement == 4) then
            if (instance.leftWallContacts == 0) then
                if instance.pressingBackward then
                    local _vx, vy = instance:getLinearVelocity()
                    local vx = math.abs(_vx) 
                    if (vx < 10) then
                        print("want to jump sideways")
                        local function f1() instance:applyLinearImpulse(-0.08, nil) end
                        timer.performWithDelay( 200, f1, 1 )
                    end
                end
            end

        elseif (phase == 'ended') and (event.selfElement == 3) then
            if (instance.rightWallContacts == 0) then
                if instance.pressingForward then
                    local vx, vy = instance:getLinearVelocity()
                    if (vx == 0) then
                        print("want to jump sideways")
                        local function f1() instance:applyLinearImpulse(0.08, nil) end
                        timer.performWithDelay( 200, f1, 1 )
                    end
                end
            end
        end
    end

    local function updateVision()
        -- get delta position between instance and player
        local visionOnPlayer = instance.visionOnPlayer

        local scene = composer.getScene( composer.getSceneName( 'current' ) )
        local map = scene.map
        local player = map.layer['entities'].object['player']

        local px, py = player.x, player.y
        local ix, iy = instance.x, instance.y
        local dx, dy = px-ix, py-iy
        local delta = math.sqrt((dx*dx) + (dy*dy))

        -- changes only occur if value changes
        if delta < 140 and not visionOnPlayer then
            instance.visionOnPlayer = true
            instance:dispatchEvent({name='behaviour',vision=true})
        elseif delta > 140 and visionOnPlayer then
            instance.visionOnPlayer = false
            instance:dispatchEvent({name='behaviour',vision=false})
        end
    end
    
    -- add Eventlistener
    instance:addEventListener('collision', handleCollision)
    instance:addEventListener('behaviour', behaviour)
    
    -- Behaviour: Add loop for updateVision
    local fc = function() updateVision() end
    handleLoop('updateVision', fc, 1000)

    -- Return instance
	return instance
end

return M