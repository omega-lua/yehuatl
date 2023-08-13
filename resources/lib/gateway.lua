-- Define module
local M = {}

function M.new( instance, options )
    if not instance then error( "ERROR: Expected display object" ) end

    local composer = require( "composer" )

    function instance:ChangeScene()
        print("---------ChangeScene----------")
        
        local options = {effect = "slideUp", time = 800}
        print(instance.MoveTo)
        composer.gotoScene(instance.MoveTo, options)
    end

    
    function instance:collision(event)
        if (event.phase == "began") and (event.other == player) then
            -- Audio
            -- Transition
            instance:ChangeScene()
        end
    end
    
    instance:addEventListener("collision", collision)

    -- Return instance
	instance.name = "gateway"
	instance.type = "gateway"
	return instance
end

return M