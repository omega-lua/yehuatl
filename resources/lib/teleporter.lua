-- Define module
local M = {}

function M.new( instance, options )
    if not instance then error( "ERROR: Expected display object" ) end

    local function teleport(event)
        -- teleporting
    end


    local function showNarrative()
        -- get scene table
        local composer = require( 'composer' )
        local json = require( 'json' )
        local scene = composer.getScene( composer.getSceneName( 'current' ) )
        local lib = require("resources.lib.lib")
        
        local encoded = instance.text
        local text = json.decode(encoded)
        local listener

        if instance.exitAfterNarrative then
            listener = function()
                --scene:destroy()
                local parent = composer.getSceneName( 'current' )
                composer.removeScene( parent )
                lib.scene.show('resources.scene.menu.mainmenu', {'fade', 1500})
            end
        end
        scene:showNarrative(true, text, listener)
    end
    
    local function handleCollision(event)
        local phase = event.phase
        local other = event.other
        if (phase == 'began') then
            if (other._name == 'player') and (event.otherElement == 1) then
                -- remove EventListener so handleCollision() gets only called once.
                instance:removeEventListener( "collision", handleCollision )

                showNarrative()
            end
        end
    end

    -- add EventListeners
    instance:addEventListener( "collision", handleCollision )

    -- Return instance
	return instance
end

return M