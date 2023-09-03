-- Define module
local M = {}

function M.new( instance, options )
    if not instance then error( "ERROR: Expected display object" ) end

    print(options)
    
    -- Variabeln. Kommen später evt. in ein config-file.
    instance.primaryWeapon = playerData['primaryWeapon'] -- Leere Tables bekommen den Wert "emptyTable". Dieser wird bspw. beim Laden des Inventars mit if-statement überprüft.
    instance.secondaryWeapon = playerData['secondaryWeapon']

    instance.health = playerData['health']
    instance.attack = playerData['attack']
    instance.movement = playerData['movement']
    instance.inventory = playerData['inventory']

    -- Load Spritesheet; IMAGE NAME?
    --instance = display.newSprite( parent, sheet, sequenceData )

    -- Add physics
    --local image_outline = graphics.newOutline( 100, "player2.png")
    local scaleFactor = scaleFactor
    --filter = CollisionFilterPlayer
    physics.addBody(instance, "dynamic",
        { density=3.5, friction=0, bounce=0, shape={-35,-65, 35,-65, 35,65, -35,65}  }, -- 1: Main body element für abstumpfen: 5,65, -5,65 als 3- und 2-letzte einfügen.
        { box={ halfWidth=20, halfHeight=8, x=0, y=75 }, isSensor=true },               -- 2: Foot sensor element
        { box={ halfWidth=10, halfHeight=10, x=45, y=70 }, isSensor=true },             -- 3: Right Side sensor element
        { box={ halfWidth=10, halfHeight=10, x=-45, y=70 }, isSensor=true },            -- 4: Left Side sensor element
        { box={ halfWidth=100, halfHeight=20, x=0, y=20 }, isSensor=true }              -- 5: Reach/Range sensor element
        ) 
    instance.isFixedRotation = true
    instance.sensorOverlaps = 0
    
    function instance:Jump() --> siehe: https://docs.coronalabs.com/tutorial/games/allowJumps/index.html
        if (instance.sensorOverlaps > 0) then
            instance:applyLinearImpulse(nil, -60)
        end
    end
    

    instance.iOiR = 0   -- "isObjectinRange",  OiR = "ObjectinRange"
    local function SensorCollide( event )
        -- Confirm that the colliding elements are the foot sensor and a ground object
        if ( event.selfElement == 2 and event.other.interactType == "ground" ) then
            -- Foot sensor has entered (overlapped) a ground object
            if ( event.phase == "began" ) then
                instance.sensorOverlaps = instance.sensorOverlaps + 1

                -- Foot sensor has exited a ground object
            elseif ( event.phase == "ended" ) then
                instance.sensorOverlaps = instance.sensorOverlaps - 1
            end

        -- Colliding with rightside wall.
        elseif ( event.selfElement == 3) and (event.other.interactType== "ground") and (instance.sensorOverlaps == 0) then
            local vx, vy = instance:getLinearVelocity()
            if (event.phase == "ended") and (movB == false) and (movF == true) then
                instance:setLinearVelocity(instance.movement["speed"]*300, vy)
                return
            end      
        -- Colliding with leftside wall.
        elseif ( event.selfElement == 4) and (event.other.interactType == "ground") and (instance.sensorOverlaps == 0) then
            local vx, vy = instance:getLinearVelocity()
            if (event.phase == "ended") and (movF == false) and (movB == true) then
                instance:setLinearVelocity(instance.movement["speed"]*-300, vy)
                return
            end      
        -- Interact with other object.
        elseif (event.selfElement == 5) and (event.other.objType == "interaction") then
            if (event.phase == "began") then
                instance.OiR = event.other
                instance.iOiR = instance.iOiR + 1
            elseif (event.phase == "ended") then
                instance.iOiR = instance.iOiR - 1
            end 
        end
    end


    function instance:MeleeAttack()
        -- Animation
        -- SFX
        local other = instance.OiR
        if (instance.iOiR == 1) and (other.isDead == false) then
            local amount = instance.attack["strength"] * instance.attack["accuracy"]
            local options = {["type"] = "hurt",["amount"] = amount}
            other:HandleHealth(options)
            print("ATTACK")
            -- COOLDOWN!
        end
    end

    -- instance:RangedAttack()

    -- instance:SpecialAttack()

    -- instance:Dodge()

    -- instance:Block()

    function instance:Interact()
        if (instance.iOiR > 0) then
            -- Animation
            -- SFX
            -- Interaction here. Maybe send it to the other objects class.
        end
    end

    function instance:die()
        print("---------Instance died-----------")
        -- Audio
        -- Animation
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


    -- instance:Finalize()   --> Remove EventListeners when removing player
    
    -- EventListener hinzufügen
    instance:addEventListener("collision", SensorCollide)

    -- Return instance
	instance.name = "player"
	instance.type = "player"
	return instance
end

return M