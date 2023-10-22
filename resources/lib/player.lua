-- Define module
local M = {}

function M.new( instance, options )
    if not instance then error( "ERROR: Expected display object" ) end

    local composer = require( 'composer' )
    local lib = require("resources.lib.lib")

    ------------------------------------------------------------------
    -- instance variables
    ------------------------------------------------------------------
    instance.bodyContacts = 0
    instance.groundContacts = 0
    instance.rightWallContacts = 0
    instance.leftWallContacts = 0
    instance.interactionTable = {}
    instance.attackTable = {}
    instance.isDead = false
    instance.isVurnerable = true

    instance.pressingForward = false
    instance.pressingBackward = false
    instance.pressingJump = false

    instance.movement = {
        speed = 80,
        jumpHeight = -5.5
    }
    instance.health = {
        hitpoints = 10,
        maxHitpoints = 10,
        regenHitpoints = 5,
        stamina = 100,
        maxStamina = 100,
        regenStamina = 5
    }
    instance.combat = {
        strength = 5,
        lastMeleeAttack = 0,
        cooldownMeleeAttack = 1.5,
        lastRangedAttack = 0,
        cooldownRangedAttack = 3,
        lastBlock = 0,
        cooldownBlock = 5,
        isBlocking = false
    }

    ------------------------------------------------------------------
    -- Setup physics body
    ------------------------------------------------------------------

    local bodyShape = {-7,-10, 7,-10, 7,24, -7,24} --16, 34
    physics.addBody(instance, "dynamic",
        { density=3.5, friction=0, bounce=0, shape=bodyShape  },             -- 1: Main body element
        { box={ halfWidth=6, halfHeight=2, x=0, y=24 }, isSensor=true },     -- 2: Foot sensor element
        { box={ halfWidth=2, halfHeight=17, x=8, y=7 }, isSensor=true },     -- 3: Right Side sensor element
        { box={ halfWidth=2, halfHeight=17, x=-8, y=7 }, isSensor=true },    -- 4: Left Side sensor element
        { box={ halfWidth=32, halfHeight=17, x=0, y=7 }, isSensor=true } ,   -- 5: Reach/Range sensor element
        { box={ halfWidth=28, halfHeight=10, x=0, y=7 }, isSensor=true }     -- 6: Attack sensor element
    ) 
    instance.isFixedRotation = true
    
    ------------------------------------------------------------------
    -- Instance functions
    ------------------------------------------------------------------
    
    function instance:jump()
        if instance.groundContacts > 0 then
            local jumpHeight = instance.movement.jumpHeight
            local vx, vy = instance:getLinearVelocity()
            instance:setLinearVelocity(vx, 0)
            instance:applyLinearImpulse(nil, jumpHeight)
        end
    end

    function instance:interact()
        local interactions = instance.interactionTable
        local map = map

        print("ram used in kb: "..collectgarbage( 'count' ))

        local function interactWithEntity(name)
            local entity = map.layer['entities'].object[name]
            entity:onInteraction()
        end

        if (#interactions == 1) then
            local name = interactions[1]
            interactWithEntity(name)

        elseif (#interactions > 1) then
            -- multiple interactions possible, choose nearest
            local math = math
            local t = {}
            local px, py = instance.x, instance.y
            local nearest = {nil, 1000}
            for i, name in pairs(interactions) do
                local entity = map.layer['entities'].object[name]
                local ex, ey = entity.x, entity.y
                local dx, dy = px-ex, py-ey
                local d = math.sqrt((dx*dx)+(dy*dy))
                if d <= nearest[2] then nearest = {name, d} end
            end
            
            local name = nearest[1]
            interactWithEntity(name)
        else
            --
        end
    end

    function instance:die()
        if not instance.isDead then
            instance.isDead = true
            -- Set the rectangle's active state
            instance.isBodyActive = false
            -- Audio
            -- Animation

            local scene = composer.getScene( composer.getSceneName( 'current' ) )
            scene:onPlayerDeath()
        end
    end

    local function handleCollision(event)
        -- Localize
        local selfElement = event.selfElement
        local other = event.other
        local phase = event.phase
        local var

        -- distinct between body-elements
        if (selfElement == 1) and not other.isGround then
            if other.isVoid then
                instance:die()
                return
            end
            var = 'bodyContacts'
        elseif (selfElement == 2) and other.isGround then
            var = 'groundContacts'
        elseif (selfElement == 3) and other.isGround then
            var = 'rightWallContacts'
        elseif (selfElement == 4) and other.isGround then
            var = 'leftWallContacts'
        elseif (selfElement == 5) and not other.isGround then
            local isInteractive = other.isInteractive
            local name = other._name
            local t = instance.interactionTable
            if (phase == 'began') and isInteractive then
                t[#t+1] = name
            elseif (phase == 'ended') and isInteractive then
                local index = table.indexOf( t, name )
                if index then t[index] = nil end
            end
            return false
        elseif (selfElement == 6) and not other.isGround then
            local isVurnerable = other.isVurnerable
            if isVurnerable and (event.otherElement == 1) then
                local name = other._name
                local t = instance.attackTable
                if (phase == 'began') then
                    t[#t+1] = name
                elseif (phase == 'ended') then
                    local index = table.indexOf( t, name )
                    if index then t[index] = nil end
                end
            end
            return false
        else
            return false
        end

        -- change value
        if (phase == 'began') then
            instance[var] = instance[var] + 1
        elseif (phase == 'ended') then
            instance[var] = instance[var] - 1
        end

        -- special cases
        if (phase == 'ended') and (event.selfElement == 4) then
            if (instance.leftWallContacts == 0) then
                if instance.pressingBackward then
                    local _vx, vy = instance:getLinearVelocity()
                    local vx = math.abs(_vx) 
                    if (vx < 10) then
                        instance:applyLinearImpulse(-3.5, nil)
                    end
                end
            end

        elseif (phase == 'ended') and (event.selfElement == 3) then
            if (instance.rightWallContacts == 0) then
                if instance.pressingForward then
                    local vx, vy = instance:getLinearVelocity()
                    if (vx == 0) then
                        instance:applyLinearImpulse(3.5, nil)
                    end
                end
            end
        end
    end

    function instance:meleeAttack()
        local last = instance.combat.lastMeleeAttack
        local cooldown = instance.combat.cooldownMeleeAttack
        local now = os.time()
        if (now-last) >= cooldown then
            local enoughStamina = instance:handleStamina(10,false)
            if enoughStamina then
                -- localize
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
                    -- Attacks only enemies which player faces.
                    if (xScale == 1) and (x > ix)then
                        entity:handleHealth(strength)
                    elseif (xScale == -1) and (x < ix) then
                    entity:handleHealth(strength)
                    end
                end

                -- update attack cooldown
                instance.combat.lastMeleeAttack = os.time()

                -- update visual
                local hud = composer.getScene( composer.getSceneName( 'overlay' ) )
                if hud and hud._name == 'hud' then
                    hud:updateCooldown('meleeAttack')
                end
            end
        end
    end

    function instance:rangedAttack()
        -- Localize
        local last = instance.combat.lastRangedAttack
        local cooldown = instance.combat.cooldownRangedAttack
        local now = os.time()

        if (now-last) >= cooldown then
            local enoughStamina = instance:handleStamina(20,false)
            if enoughStamina then

                -- 1. create projectile
                local x, y = instance.x, instance.y
                local projectile = display.newImage('resources/graphics/projectile.png', x, y )
                projectile:scale(1.3, 1.3)

                -- 2. connect with class
                local class = require("resources.lib.projectile")
                local projectile = class.new(projectile)
            
                -- 3. insert in map
                local scene = composer.getScene(composer.getSceneName('current'))
                local map = scene.map
                map.layer['entities']:insert(projectile)
        
                -- 4. set velocity
                local xScale = instance.xScale
                projectile:setLinearVelocity(400*xScale,-70)

                -- 5. update attack cooldown
                instance.combat.lastRangedAttack = os.time()

                -- 5. update visual
                local hud = composer.getScene( composer.getSceneName( 'overlay' ) )
                if hud and hud._name == 'hud' then
                    hud:updateCooldown('rangedAttack')
                end
            end
        end
    end

    function instance:handleHealth(amount, heal)
        local before, after = instance.health.hitpoints, 0
        local maxHitpoints = instance.health.maxHitpoints
        if heal then
            after = before + amount
            -- Dont heal above maxHitpoints
            if after > maxHitpoints then after = maxHitpoints end
        else
            if instance.isBlocking then
                -- update blocking state, no damage
                instance:block('blocked')
                return
            else
                after = before - amount
            end
        end
        -- If hitpoints stay the same, don't update anything.
        if after == before then return false end

        -- update variable
        instance.health.hitpoints = after

        -- update HUD from player
        local hud = composer.getScene( composer.getSceneName( 'overlay' ) )
        if hud then hud:update() end

        -- check if dead
        if after <= 0 then
            instance:die()
        end
    end

    function instance:handleMovement()
        local vx, vy = instance:getLinearVelocity()
        local pressingForward = instance.pressingForward
        local pressingBackward = instance.pressingBackward

        if pressingForward == pressingBackward then
            vx = 0
        elseif pressingForward then
            vx = instance.movement.speed
        elseif pressingBackward then
            vx = -instance.movement.speed
        end
        
        instance:setLinearVelocity(vx, vy)
           
        -- set direction of player-displayobject (visually)
        if (vx < 0) then
            instance.xScale = -1
        elseif (vx > 0) then
            instance.xScale = 1
        end
        
        if (math.abs(vx) > 0) and not instance.tag then
            instance:handleStamina(5, true, 'runningDrain')
        elseif instance.tag then
            instance:handleStamina(nil, true, 'runningDrain')
        end
    end

    local function regenerateStamina()
        -- Localize
        local health = instance.health
        local before = health.stamina
        local amount = health.regenStamina
        local maxStamina = health.maxStamina
        local hitpoints = health.hitpoints
        local maxHitpoints = health.maxHitpoints
        local after = before + amount
        -- Start healing when full stamina

        if after >= maxStamina then
            after = maxStamina
            -- start healing if not full
            if hitpoints < maxHitpoints then
                instance:handleHealth(1, true)
            end
        end
        
        -- Only update if value changed
        if (before ~= after) then
            instance.health.stamina = after

            -- update hud
            local overlay = composer.getScene( composer.getSceneName( 'overlay' ) )
            if overlay and overlay._name == 'hud' then overlay:update() end
        end
    end

    function instance:handleStamina(amount, continuous, tag) 
        if continuous then
            -- start the drain --> for example: handleStamina(10, true, 'runningDrain') 
            if amount then
                -- Localize
                local amount = amount
            
                --stop stamina regeneration
                --timer.cancel('regenerateStamina')

                -- loop function
                local function continuousDrain()
                    local before = instance.health.stamina
                    local value = before - amount
                    if value ~= before then
                        instance.health.stamina = before - amount
                        if hud then hud:update() end
                    end
                end

                timer.performWithDelay( 500, continuousDrain, -1, tag )

                instance.tag = true
            else
                -- stop the drain --> for example: handleStamina(nil, true, 'runningDrain') 
                timer.cancel( tag )
                -- start stamina regeneration
                --timer.performWithDelay( 1000, regenerateStamina, -1, 'regenerateStamina' )

                instance.tag = nil
            end
        else
            local stamina = instance.health.stamina
            local maxStamina = instance.health.maxStamina
            local value = stamina - amount
            if value < 0 then
                return false
            else
                instance.health.stamina = value
            end
        end
        
        -- update hud
        local overlay = composer.getScene( composer.getSceneName( 'overlay' ) )
        if overlay and overlay.name == 'hud' then overlay:update() end

        -- return true
        return true
    end

    function instance:block(state)
        -- Localize
        local last = instance.combat.lastBlock
        local cooldown = instance.combat.cooldownBlock
        local now = os.time()

        if (state == 'begin') then
            if (now-last) >= cooldown then
                instance.isBlocking = true
            end
        elseif (state == 'cancel') then
            instance.isBlocking = false

        elseif (state == 'blocked') then
            instance.isBlocking = false
            -- update block cooldown
            instance.combat.lastBlock = os.time()
        end

        local hud = composer.getScene( composer.getSceneName( 'overlay' ) )
        if hud and hud._name == 'hud' then
            hud:updateCooldown('block', state)
        end
    end

    function instance:ability()
        --
    end

    -- add EventListeners
    instance:addEventListener("collision", handleCollision)
    
    -- add Loops
   timer.performWithDelay( 1000, regenerateStamina, -1, 'regenerateStamina' )

    -- Return instance
	return instance
end

return M