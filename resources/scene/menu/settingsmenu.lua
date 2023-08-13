-- Template from Solar2D-Guide: https://docs.coronalabs.com/guide/system/composer/index.html#template

local widget = require( "widget" )
local composer = require( "composer" )
local scene = composer.newScene()
local library = library

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- Not the most elegant way.
function scene:reload()
    local currScene = composer.getSceneName( "current" )
    composer.gotoScene( currScene )
end

function scene:showToast(message)
    local toast = display.newText({
        text = message,     
        x = display.contentCenterX,
        y = display.contentCenterX*0.1,
        width = 256,
        font = native.systemFont,   
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

function scene:applySettings()
    -- Save to file
    library.saveSettings(scene.tmpSettings)

    -- Initiate Settings
    library.initiateSettings(scene.tmpSettings)

    -- Set variable
    scene.isSaved = true

    scene:showToast("Settings applied!")
end

function scene:resetSettings()
    -- Get initial_settings and save as settings.json
    local data = library.resetSettings()

    -- Initiate Settings
    library.initiateSettings(data)

    scene.isSaved = true

    scene:showToast("Settings reset!")
end

local function handleButtonEvent(event)
    if (event.phase == 'ended') then
        if (event.target.id == 'buttonBack') then
            if (scene.isSaved == false) then
                -- Darken scene behind...
                
                -- Show Overlay... Overlay hat drei Buttons, Speichern, Abbrechen, nicht speichern
                composer.showOverlay("resources.scene.menu.warningmenu")
            else
                library.handleSceneChange("resources.scene.menu.mainmenu", "menu", { effect = "fade", time = 400,})
            end

        elseif (event.target.id == 'buttonApplySettings') then
            scene:applySettings(scene.tmpSettings)

            scene.isSaved = true

        elseif (event.target.id == 'buttonResetSettings') then
            scene:resetSettings()
            scene:reload()
            
            scene.isSaved = true
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
            
            --print("loudness:", scene.tmpSettings.loudnessMusic)
        end
    end
end

local function loadUI()
    local sceneGroup = scene.view

    local buttonBack = widget.newButton({
        x = display.contentCenterX*0.1,
        y = display.contentCenterY*0.2,
        id = "buttonBack",
        label = "back",
        onEvent = handleButtonEvent,
        fontSize = 30,
        labelColor = { default={ 255, 255, 255, 1}}
    })

    local sliderLoudnessMusic = widget.newSlider({
        id = "sliderLoudnessMusic", 
        x = display.contentCenterX,
        y = display.contentCenterY,
        width = 400,
        value = loudnessMusic,
        listener = handleSliderEvent
    })

    local buttonApplySettings = widget.newButton({
        x = display.contentCenterX*0.7,
        y = display.contentCenterY*1.8,
        id = "buttonApplySettings",
        label = "Apply Settings",
        onEvent = handleButtonEvent,
        fontSize = 20,
        labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } }
    })

    local buttonResetSettings = widget.newButton({
        x = display.contentCenterX*1.4,
        y = display.contentCenterY*1.8,
        id = "buttonResetSettings",
        label = "Reset Settings",
        onEvent = handleButtonEvent,
        fontSize = 20,
        labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } }
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
    
    local s = settings 
    scene.tmpSettings = settings 
    scene.isSaved = true

    -- UI sollte jedesmal neu geladen werden, nicht aber die ganze Szene, darum kein removeScene().
    loadUI()
end
 
 
-- show()
function scene:show( event )
 
    
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)
        
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

        scene.tmpSettings = nil
        scene.isSaved = true

        composer.removeScene("resources.scene.menu.settingsmenu" )
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