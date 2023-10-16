-- Define module
local M = {}

function M.new( instance, options )
    if not instance then
        error( "ERROR: Expected display object" )
    else
        print("entity: "..instance._name.." extended with enemy class.")
    end

    -- create costum physics body with multiple hitboxes.
    local bodyShape = {-16,-32, 16,-32, 16,32, -16,32}
    physics.addBody(instance, "dynamic",
        { density=3.5, friction=0.1, bounce=0, shape=bodyShape},            -- 1: Hitbox element
        { box={ halfWidth=16, halfHeight=4, x=0, y=32 }, isSensor=true },   -- 2: Foot sensor element
        { box={ halfWidth=40, halfHeight=16, x=0, y=0 }, isSensor=true }    -- 3: Attack sensor element
    ) 

    
    -- initial variables. Some may get stored in savefile when level is being saved.
    instance.behaviourLoopLabel = 'behaviour:'..instance._name
    instance.isFixedRotation = true
    instance.attackTable = {}
    instance.health = {
        hitpoints = 10,
        maxHitpoints = 10
    }
    instance.combat = {
        strength = 5
    }

    function instance:behaviour()
        print("opened behaviour")
            
        instance:scanning()
    end

    function instance:die()
        local function fc(event)
            -- maybe unnecessary:
            instance.isDead = true
            -- Set the rectangle's active state
            instance.isBodyActive = false
            
            -- Audio (with timer to later delete object)
            
            -- Animation
        
            -- stop behaviour loop
            timer.cancel( instance.behaviourLoopLabel )
            print(instance._name.." died (having "..instance.health.hitpoints.." hitpoints).")

            -- delete object
            --display.remove( instance )
        end
        timer.performWithDelay(30, fc)
    end

    function instance:handleHealth(amount, heal)
        local hitpoints = instance.health.hitpoints
        local maxHitpoints = instance.health.maxHitpoints
        if heal then
            hitpoints = hitpoints + amount
            if hitpoints > maxHitpoints then hitpoints = maxHitpoints end
        else
            hitpoints = hitpoints - amount
        end

        -- debug visual for current hitpoints
        instance.alpha = hitpoints / maxHitpoints

        -- update variable
        instance.health.hitpoints = hitpoints

        -- check if dead
        if hitpoints <= 0 then
            instance:die()
        end
        
        print(instance._name.." has now "..instance.health.hitpoints.." hitpoints.")
    end

    function instance:meleeAttack()
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
    end

    local function handleCollision(event)
        local phase = event.phase
        local other = event.other
        selfElement = event.selfElement
        if (selfElement == 3) then
            if other.isVurnerable then
                local name = other._name
                if (name == 'player') then
                    if (event.otherElement ~= 1) then
                        return false
                    end
                end
                local t = instance.attackTable
                if (phase == 'began') then
                    t[#t+1] = name
                elseif (phase == 'ended') then
                    t[table.indexOf( t, name )] = nil
                end 
            end
        end
    end

    -- add Eventlistener
    instance:addEventListener('collision', handleCollision)
    
    -- Add enemy behaviour loop
    local function loop1() instance:meleeAttack() end
    timer.performWithDelay( 1000, loop1, -1, instance.behaviourLoopLabel)

    -- Return instance
	return instance
end

return M