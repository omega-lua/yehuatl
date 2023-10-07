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
        { density=3.5, friction=0, bounce=0, shape=bodyShape},              -- 1: Main body element für abstumpfen: 5,65, -5,65 als 3- und 2-letzte einfügen.
        { box={ halfWidth=40, halfHeight=16, x=0, y=0 }, isSensor=true }    -- 2: Attack sensor element
    ) 

    
    -- initial variables. Some get stored in savefile when level is being saved.
    instance.isFixedRotation = true
    instance.attackTable = {}
    instance.health = {
        hitpoints = 10,
        maxHitpoints = 10
    }
    instance.combat = {
        strength = 5
    }

    function instance:walking(event)
        print("walking...")
        local direction, dir = math.random(0,1), -1
        if direction == 1 then dir = 1 end
        local vx = math.random(3,5) * 10 * dir
        instance:setLinearVelocity(vx, nil)
        local delay = math.random(1.5, 3) * 1000
        local function fc()
            instance:scanning()
        end
        timer.performWithDelay(delay, fc, 1, "behaviour")
    end

    function instance:scanning(event)
        print("bip bip....")
        local function fc()
            instance:walking()
        end
        local delay = math.random(1.5, 3) * 1000
        timer.performWithDelay(delay, fc, 1, "behaviour")
        local chance = math.random(1,5)
        if chance == 5 then
            print("chance!")
            timer.cancel("behaviour")
            instance:attack()
        end
    end

    function instance:behaviour()
        print("opened behaviour")
            
        instance:scanning()
    end

    function instance:behaviourX()
        local lib = require("resources.lib.lib")
        local math = math
        local ai = nil
        instance.delay = 1000
        local function onTimer(event)
            local delay = math.random(1,4) * 1000
            instance.delay = delay
            print(instance.delay)
    
            --timer.performWithDelay(instance.delay, onTimer, -1, "ai")
        end
        
        local ai = timer.performWithDelay(instance.delay, onTimer, -1)
    end

    function instance:die()
        local function fc(event)
            instance.isDead = true
            -- Set the rectangle's active state
            instance.isBodyActive = false
            --display.remove( instance )
            --table.remove( instance, i )
            -- Audio
            -- Animation
        
            print(instance._name.." died (having "..instance.health.hitpoints.." hitpoints).")
        end
        timer.performWithDelay(30, fc)
    end

    function instance:handleHealth(amount, heal)
        print(amount, heal)
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
        print("enemy attacks.") -- DEBUG
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

    function instance:fc1(event)
        local function f() 
            instance:fc2()
        end
        timer.performWithDelay(1000, f)
    end

    function instance:fc2(event)
        local function f() 
            instance:fc1()
            instance:meleeAttack()
        end
        print("attacking in 1 second")
        timer.performWithDelay(1000, f)
    end

    --instance:fc1()

    local function handleCollision(event)
        local phase = event.phase
        local other = event.other
        if (event.selfElement == 2) then
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

    -- Return instance
	return instance
end

return M