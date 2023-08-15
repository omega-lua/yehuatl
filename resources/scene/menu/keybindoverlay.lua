local composer = require( "composer" )
 
local scene = composer.newScene()
 
-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
 
function scene:showToast(message)
    local toast = display.newText({
        text = message,     
        x = display.contentCenterX,
        y = display.contentCenterX*0.1,
        width = 256,
        font = "fonts/BULKYPIX.TTF",   
        fontSize = 18,
        align = "center"  -- Alignment parameter
    })
 
    local params = {
        time = 1000,
        tag = "toast",
        transition = easing.outQuart,
        delay = 1500,
        alpha = 0
    }
    
    toast:setFillColor(0, 255, 0)
    transition.to(toast, params)
end

function scene:hoverObj(nextObj)
    for k,o in pairs(scene.objTable) do
        if (k == nextObj) then
            local params = {
                time = 200,
                transition = easing.outQuint,
                xScale = 1.5,
                yScale = 1.5,
            }
            
            transition.to(o, params)
        elseif (k== nil) then
            
        else
            local params = {
                time = 200,
                transition = easing.outQuint,
                xScale = 1,
                yScale = 1,
            }
            transition.to(o, params)
        end
    end
end

-- OUTDATED
function scene:handleObjectInteraction(object)
    if (object == "buttonBack") then
        library.handleSceneChange("resources.scene.menu.settingsmenu", "menu", { effect = "fade", time = 400,})
    elseif (object == "buttonInputDevice") then
        -- showOverlay
    elseif (object == "buttonKeybinds") then
        --  showOverlay
    end
end

-- Für Touch-Steuerung??
local function handleButtonEvent(event)
    if (event.phase == 'ended') then
        if (event.target.id == 'buttonBack') then
            scene:back()
            return

        elseif (event.target.id == 'buttonKeybinds') then
            scene:applySettings(scene.tmpSettings) 
            --

        elseif (event.target.id == 'buttonInputDevice') then
            --
        end
    end 
end


 
function scene:loadUI()
    --
end
 
-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
 
-- create()
function scene:create( event )
 
    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen
 
end
 
 
-- show()
function scene:show( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)
 
        scene:loadUI()
        
        scene.navigationMatrix = {
            ["center"] = {"buttonInputDevice", "buttonBack", "buttonKeybinds", "buttonBack"},
            ["buttonBack"] = {"buttonKeybinds","buttonInputDevice", "buttonInputDevice", "buttonKeybinds"},
            ["buttonInputDevice"] = {"buttonBack", "buttonBack", "buttonKeybinds", "buttonBack"},
            ["buttonKeybinds"] = {"buttonInputDevice", "buttonBack", "buttonBack", "buttonInputDevice"},
            }
        scene.objTable = {["center"]=nil,
            ["buttonBack"] = buttonBack,
            ["buttonInputDevice"] = buttonInputDevice,
            ["buttonKeybinds"] = buttonKeybinds,
        }
        runtime.currentScene = scene
        runtime.currentSceneType = "menu"


    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen
 
    end
end
 
 
-- hide()
function scene:hide( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is on screen (but is about to go off screen)
 
    elseif ( phase == "did" ) then
        -- Code here runs immediately after the scene goes entirely off screen

        composer.removeScene("resources.scene.menu.keybindoverlay")
    end
end
 
 
-- destroy()
function scene:destroy( event )
 
    local sceneGroup = self.view
    -- Code here runs prior to the removal of scene's view
 
end
 
 
-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------
 
return scene