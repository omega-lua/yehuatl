-- Define module
local M = {}

function M.new( instance, options )
    if not instance then error( "ERROR: Expected display object" ) end
    print("Object has been extended with player class.")

    ------------------------------------------------------------------
    -- instance variables
    ------------------------------------------------------------------
    instance.bodyContacts = 0
    instance.groundContacts = 0
    instance.rightWallContacts = 0
    instance.leftWallContacts = 0
    instance.interactionTable = {}
    instance.attackTable = {}

    instance.pressingForward = false
    instance.pressingBackward = false
    instance.pressingJump = false
    instance.isSneaking = false

    instance.movement = {
        speed = 200,
        jumpHeight = -32
    }
    instance.health = {
        hitpoints = 15,
        maxHitpoints = 15,
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

    local bodyShape = {-16,-32, 16,-32, 16,32, -16,32}
    physics.addBody(instance, "dynamic",
        { density=3.5, friction=0, bounce=0, shape= bodyShape  },            -- 1: Main body element für abstumpfen: 5,65, -5,65 als 3- und 2-letzte einfügen.
        { box={ halfWidth=16, halfHeight=4, x=0, y=32 }, isSensor=true },    -- 2: Foot sensor element
        { box={ halfWidth=4, halfHeight=32, x=20, y=0 }, isSensor=true },    -- 3: Right Side sensor element
        { box={ halfWidth=4, halfHeight=32, x=-20, y=0 }, isSensor=true },   -- 4: Left Side sensor element
        { box={ halfWidth=64, halfHeight=32, x=0, y=0 }, isSensor=true } ,   -- 5: Reach/Range sensor element
        { box={ halfWidth=32, halfHeight=16, x=0, y=0 }, isSensor=true }     -- 6: Attack sensor element
    ) 
    instance.isFixedRotation = true
    
    function instance:jump()
        if instance.groundContacts > 0 then
            local jumpHeight = instance.movement.jumpHeight
            instance:setLinearVelocity(nil, 0)
            instance:applyLinearImpulse(nil, jumpHeight)
        end
    end

    -- not finished
    function instance:interact()
        local interactions = player.interactionTable

        if (#interactions == 1) then
            print("only one interaction possible.")
            -- pick it. But how?
        elseif (#interactions > 1) then
            print("multiple interactions possible.")
            -- multiple interactions possible, choose nearest
        else
            print("no interactions possible.")
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
                    t[table.indexOf( t, name )] = nil
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
                        local x = instance.movement.jumpHeight
                        instance:applyLinearImpulse(x, nil)
                    end
                end
            end

        elseif (phase == 'ended') and (event.selfElement == 3) then
            if (instance.rightWallContacts == 0) then
                if instance.pressingForward then
                    local vx, vy = instance:getLinearVelocity()
                    if (vx == 0) then
                        local x = instance.movement.jumpHeight
                        instance:applyLinearImpulse(-x, nil)
                    end
                end
            end
        end
    end

    function instance:meleeAttack()
        local last = instance.combat.lastMeleeAttack
        local cooldown = instance.combat.cooldownMeleeAttack
        local now = os.clock()
        if (now-last) >= cooldown then
            print("player attacks.") -- DEBUG

            local composer = require("composer")
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
            instance.combat.lastMeleeAttack = os.clock()
        end
    end

    function instance:rangedAttack()
        -- Localize
        local last = instance.combat.lastRangedAttack
        local cooldown = instance.combat.cooldownRangedAttack
        local now = os.clock()
        if (now-last) >= cooldown then
            print("player makes ranged attack.")
            
            -- 1. create projectile
            local x, y = instance.x, instance.y
            local projectile = display.newImage('resources/graphics/projectile.png', x, y )
            projectile:scale(1.3, 1.3)

            -- 2. connect with class
            local class = require("resources.lib.projectile")
            local projectile = class.new(projectile)
            
            -- 3. insert in map
            local composer = require("composer")
            local scene = composer.getScene(composer.getSceneName('current'))
            local map = scene.map
            map.layer['entities']:insert(projectile)
        
            -- 4. set velocity
            local xScale = instance.xScale
            projectile:setLinearVelocity(300*xScale,-100)

            -- 5. update attack cooldown
            instance.combat.lastRangedAttack = os.clock()
        end
    end

    function instance:die()
        print(">> GAME OVER <<")
        -- Set the rectangle's active state
        instance.isBodyActive = false
        -- Audio
        -- Animation
    end

    function instance:handleHealth(amount, heal)
        local hitpoints = instance.health.hitpoints
        local maxHitpoints = instance.health.maxHitpoints
        if heal then
            hitpoints = hitpoints + amount
            if hitpoints > maxHitpoints then hitpoints = maxHitpoints end
        else
            if instance.isBlocking then
                -- update blocking state, no damage
                instance:block('blocked')
            else
                hitpoints = hitpoints - amount
            end
        end

        -- debug visual for current hitpoints
        instance.alpha = hitpoints / maxHitpoints

        -- update variable
        instance.health.hitpoints = hitpoints

        -- check if dead
        if hitpoints <= 0 then
            instance:die()
        end

        print("player now has "..hitpoints.. " out of max. "..maxHitpoints.." hitpoints.")
        -- update HUD from player
    end

    function instance:block(state)
        -- Localize
        local last = instance.combat.lastBlock
        local cooldown = instance.combat.cooldownBlock
        local now = os.clock()

        if (state == 'begin') then
            if (now-last) >= cooldown then
                print("blocking")
                instance.isBlocking = true
            end
        elseif (state == 'cancel') then
            print("cancel block")
            instance.isBlocking = false

        elseif (state == 'blocked') then
            print("block successfull.")
            instance.isBlocking = false
            -- update block cooldown
            instance.combat.lastBlock = os.clock()
        end
    end

    function instance:ability()
        --
    end
    
    -- add EventListeners
    instance:addEventListener("collision", handleCollision)

    -- Return instance
	return instance
end

return M