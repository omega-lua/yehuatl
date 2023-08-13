-- Define module
local M = {}

function M.new( instance, options )
    if not instance then error( "ERROR: Expected display object" ) end
    print("enemy loaded")
    -- Variabeln. Kommen später evt. in ein config-file.

    instance.isDead = false

    instance.health = {
        ["currentHealth"] = 10,
        ["maxHealth"] = 10,
	    ["regeneration"] = 0.1,
	    ["defense"] = 1,
	    ["statusEffect"] = {"isStunned", "isPoisened"}
    }    
    instance.attack = {
        ["strength"] = 1, 
	    ["speed"] = 1, 
	    ["cooldown"] = 1, 
	    ["accuracy"] = 1
    }
    instance.movement = {
        ["speed"] = 1, 
	    ["jumpHeight"] = 1,
	    ["randomness"] = 0,
	    ["stealth"] = 1
    }
    instance.inventory = {
        "TEST_ITEM"
    }

    --physics.addBody(instance, "dynamic", { density=2.5, friction=0, bounce=0, shape={-35,-65, 35,-65, 35,75, -35,75}  }) -- 1: Main body element 
    instance.isFixedRotation = true
    instance.sensorOverlaps = 0

    function instance:die()
        print("---------Instance died-----------")
        -- Audio
        -- Animation
        -- self.isSensor = true   -> Damit man nicht mehr interagieren kann, wenn die Sterbeanimation abläuft.
        display.remove( instance )
        table.remove( instance, i )
    end

    function instance:HandleHealth(options)
        local HealthChange
        -- distinguish between "hurt" and "heal".
        if (options["type"] == "hurt") then
            HealthChange = - ( options["amount"] * instance.health["defense"] )

        elseif (options["type"] == "heal") then
            HealthChange = options["amount"]
        end

        -- Change the currentHealth of instance by the amount of "HealthChange"
        local currentHealth = ( instance.health["currentHealth"] + HealthChange )
        instance.health["currentHealth"] = currentHealth
    
        -- temporary visual for currentHealth
        instance.alpha = currentHealth / instance.health["maxHealth"]
        
        -- Handle Death
        if (currentHealth <= 0) then
            instance.isDead = true
            instance:die()
        end
    end


    -- Return instance
	instance.name = "enemy"
	instance.type = "enemy"
	return instance
end

return M