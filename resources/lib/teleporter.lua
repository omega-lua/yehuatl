-- Define module
local M = {}

function M.new( instance, options )
    if not instance then error( "ERROR: Expected display object" ) end
    print("Object has been extended with teleporter class.")

    local function teleport(event)
        print("teleporting...")
    end
    
    local function handleCollision(event)
        local phase = event.phase
        local other = event.other
        if (phase == 'began') then
            if (other._name == 'player') and (event.otherElement == 1) then
                -- remove EventListener so handleCollision() gets only called once.
                instance:removeEventListener("collision", handleCollision)

                -- get scene table
                local composer = require("composer")
                local scene = composer.getScene( composer.getSceneName( 'current' ) )
                
                local text = {'..Where am I?', "...", "What happened?", "Is this hell?"}
                local listener = function() print("function after narrative.") end
                scene:showNarrative(true, text, listener)
            end
        end
    end

    -- add EventListeners
    instance:addEventListener("collision", handleCollision)

    -- Return instance
	return instance
end

return M