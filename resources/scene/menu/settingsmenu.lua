-- Template from Solar2D-Guide: https://docs.coronalabs.com/guide/system/composer/index.html#template

local widget = require( "widget" )
local composer = require( "composer" )
local library = require("library")
local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- Still not so elegant, but better than before.
function scene:reload()
    sliderLoudnessMusic:setValue( loudnessMusic )
end

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

function scene:interactWithObj(object)
    if (object == "buttonBack") then
        scene:back()
    elseif (object == "buttonResetSettings") then
        scene:resetSettings()
    elseif (object == "buttonApplySettings") then
        scene:applySettings(scene.tmpSettings)
    end
end

function scene:applySettings(tmp)
    -- Save to file
    library.saveSettings(tmp)

    -- Initiate Settings
    library.initiateSettings(tmp)

    -- Set variable
    scene.isSaved = true

    scene:showToast("Settings applied!")
end

function scene:resetSettings()
    -- Get initial_settings and save as settings.json
    local data = library.resetSettings()

    -- Initiate Settings
    library.initiateSettings(data)

    scene:reload()

    scene.isSaved = true

    scene:showToast("Settings reset!")
end

function scene:back()
    if (scene.isSaved == false) then
        -- Darken scene behind...
        
        -- Show Overlay... Overlay hat drei Buttons, Speichern, Abbrechen, nicht speichern
        composer.showOverlay("resources.scene.menu.warningmenu")
    else
        -- if settings are saved
        library.handleSceneChange("resources.scene.menu.mainmenu", "menu", { effect = "fade", time = 400,})
    end
end

local function handleButtonEvent(event)
    if (event.phase == 'ended') then
        if (event.target.id == 'buttonBack') then
            scene:back()
            return

        elseif (event.target.id == 'buttonApplySettings') then
            scene:applySettings(scene.tmpSettings) 
            return

        elseif (event.target.id == 'buttonResetSettings') then
            scene:resetSettings()
            return
        end
    end 
end

local function handleSliderEvent(event)
    if (event.phase == 'moved' or 'ended') then
        if (event.target.id == 'sliderLoudnessMusic') then
            -- Change value in tempSettings
            scene.tmpSettings.loudnessMusic = event.value

            -- Set variable
            scene.isSaved = false
        end
    end
end

function scene:loadUI()
    local sceneGroup = scene.view

    buttonBack = widget.newButton({
        x = display.contentCenterX*0.1,
        y = display.contentCenterY*0.2,
        id = "buttonBack",
        label = "back",
        onEvent = handleButtonEvent,
        font = "fonts/BULKYPIX.TTF",
        fontSize = 30,
        labelColor = { default={ 1, 1, 1 }, over={ 1, 1, 1, 0.5 } }
    })

    sliderLoudnessMusic = widget.newSlider({
        id = "sliderLoudnessMusic", 
        x = display.contentCenterX,
        y = display.contentCenterY,
        width = 400,
        value = loudnessMusic,
        listener = handleSliderEvent
    })

    buttonApplySettings = widget.newButton({
        x = display.contentCenterX*0.7,
        y = display.contentCenterY*1.8,
        id = "buttonApplySettings",
        label = "Apply Settings",
        onEvent = handleButtonEvent,
        font = "fonts/BULKYPIX.TTF",
        fontSize = 20,
        labelColor = { default={ 1, 1, 1 }, over={ 1, 1, 1, 0.5 } }
    })

    buttonResetSettings = widget.newButton({
        x = display.contentCenterX*1.4,
        y = display.contentCenterY*1.8,
        id = "buttonResetSettings",
        label = "Reset Settings",
        onEvent = handleButtonEvent,
        font = "fonts/BULKYPIX.TTF",
        fontSize = 20,
        labelColor = { default={ 1, 1, 1 }, over={ 1, 1, 1, 0.5 } }
    })

    sceneGroup:insert(buttonBack)
    sceneGroup:insert(sliderLoudnessMusic)
    sceneGroup:insert(buttonApplySettings)
    sceneGroup:insert(buttonResetSettings)
end

-- create()
function scene:create( event )
    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen
    scene.tmpSettings = runtime.settings
    scene.isSaved = true

    -- Only the first time in center; if reshown, then last state
    scene.currentObj = "center"
end
 

-- show()
function scene:show( event )
 
    
    --local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)

        -- UI sollte jedesmal neu geladen werden, nicht aber die ganze Szene, darum kein removeScene().
        scene:loadUI()
        
        scene.objectMatrix = {
            ["center"] = {"buttonBack", "buttonResetSettings", nil, "buttonBack"},
            ["buttonBack"] = {nil, "buttonApplySettings", "buttonApplySettings", "buttonResetSettings"},
            ["buttonApplySettings"] = {"buttonBack", "buttonResetSettings", nil, "buttonBack"},
            ["buttonResetSettings"] = {"buttonBack", "buttonBack", nil, "buttonApplySettings"},
            }
        scene.objTable = {["center"]=nil,
            ["buttonBack"] = buttonBack,
            ["buttonApplySettings"] = buttonApplySettings,
            ["buttonResetSettings"] = buttonResetSettings,
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

        composer.removeScene("resources.scene.menu.settingsmenu")
    end
end
 
 
-- destroy()
function scene:destroy( event )
    print("scene destroyed")
    local sceneGroup = self.view
    -- Code here runs prior to the removal of scene's view
 
    scene.tmpSettings = nil
    scene.isSaved = true
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