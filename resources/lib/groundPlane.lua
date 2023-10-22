-- Define module
local M = {}

function M.new( instance, options )
    if not instance then
        error( "ERROR: Expected display object" )
    end
    
    local lib = require("resources.lib.lib")

    -- Convert bodyshape-string to table
    local json = require("json")
    local bodyShape = json.decode(instance.bodyShape)

    -- create costum physics body with multiple hitboxes.
    physics.addBody(instance, "static", { density=3.5, friction=0.1, bounce=0, shape=bodyShape}) 
        
    -- Return instance
	return instance
end

return M