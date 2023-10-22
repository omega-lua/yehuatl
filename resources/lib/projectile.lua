-- Define module
local M = {}

function M.new( instance, options )
    if not instance then error( "ERROR: Expected display object" ) end

    -- create physics body
    physics.addBody( instance, "dynamic", {isSensor=true})

    -- declare variables
    instance.isFixedRotation = true
    instance.isDead = false
    instance.isSensor = true
    instance.gravityScale = 0.5
    instance.damage = 5
    instance.isVisible = true
    instance.isBodyActive = true

    function instance:die()
        if not instance.isDead then
            instance.isDead = true
            local function fc()
                display.remove( instance )
                instance = nil
            end
            timer.cancel('deathTimer')
            timer.performWithDelay(20, fc)
        end
    end

    local function onCollision(event)
        local phase = event.phase
        if (phase == 'began') then
            local other = event.other
            if not (other._name == 'player') then
                if other.isVurnerable then
                    other:handleHealth(instance.damage)
                    instance:die()
                elseif other.isGround then
                    instance:die()
                end
            end
        end
    end

    -- function to let projectile despawn after 3 seconds of flight time.
    local function onDelay(event)
        instance:die()
    end
 
    timer.performWithDelay( 3000, onDelay, 'deathTimer')

    -- add eventListener
    instance:addEventListener("collision", onCollision)

    -- Return instance
	return instance
end

return M