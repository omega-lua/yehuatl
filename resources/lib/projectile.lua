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
        local function fc()
            instance:removeSelf()
            instance = nil
        end
        timer.performWithDelay(20, fc)
    end

    local function onCollision(event)
        local phase = event.phase
        if (phase == 'began') then
            local other = event.other
            if not (other._name == 'player') then
                if other.isVurnerable then
                    other:handleHealth(instance.damage)
                    instance:die()
                end
            end
        end
    end

    instance:addEventListener("collision", onCollision)

    -- Return instance
	return instance
end

return M