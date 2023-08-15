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
    --sliderLoudnessMusic:setValue( loudnessMusic )
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

local function handleScrollView(k,o)     
    if (k ~= "buttonBack")  and (k ~= "buttonResetSettings") and (k ~= "buttonApplySettings")then
        local x,y = o:localToContent(0,0)
        if (y+10 <= display.contentCenterY - scrollView.height*0.5) then
            scrollView:scrollToPosition({y=o.y, time=750} ) 
        elseif (y+10 >= display.contentCenterY + scrollView.height*0.5) then
            scrollView:scrollToPosition({y=-(o.y-50), time=750} )
        end
    end
end

function scene:hoverObj(nextObj)
    for k,o in pairs(scene.objTable) do
        if (k == nextObj) then
            handleScrollView(k,o)
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
    elseif (object == "buttonControlSettings") then
        library.handleSceneChange("resources.scene.menu.controlsettingsmenu", "menu", { effect = "fade", time = 400,})
    elseif (object == "buttonSoundSettings") then
        -- library.handleSceneChange()
    elseif (object == "buttonVisualSettings") then
        -- library.handleSceneChange()
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

function scene:loadUI()
    local sceneGroup = scene.view

    ------------------------------------------------------
    -- Other Widgets
    ------------------------------------------------------
    scrollView = widget.newScrollView({
        id="scrollView",
        x = display.contentCenterX,
        y = display.contentCenterY,
        width = 500,
        height = 300,
        horizontalScrollDisabled = true,
        scrollWidth = 500,
        scrollHeight = 1000,
        backgroundColor = { 0.1, 0.1, 0.1 },
    })
    
    buttonBack = widget.newButton({
        x = display.contentCenterX*0,
        y = display.contentCenterY*0.2,
        id = "buttonBack",
        label = "back",
        onEvent = handleButtonEvent,
        font = "fonts/BULKYPIX.TTF",
        fontSize = 20,
        labelColor = { default={ 1, 1, 1 }, over={ 1, 1, 1, 0.5 } }
    })

    buttonApplySettings = widget.newButton({
        x = display.contentCenterX*0.6,
        y = display.contentCenterY*1.9,
        id = "buttonApplySettings",
        label = "Apply Settings",
        onEvent = handleButtonEvent,
        font = "fonts/BULKYPIX.TTF",
        fontSize = 15,
        labelColor = { default={ 1, 1, 1 }, over={ 1, 1, 1, 0.5 } }
    })

    buttonResetSettings = widget.newButton({
        x = display.contentCenterX*1.5,
        y = display.contentCenterY*1.9,
        id = "buttonResetSettings",
        label = "Reset Settings",
        onEvent = handleButtonEvent,
        font = "fonts/BULKYPIX.TTF",
        fontSize = 15,
        labelColor = { default={ 1, 1, 1 }, over={ 1, 1, 1, 0.5 } }
    })

    sceneGroup:insert(buttonBack)
    sceneGroup:insert(buttonApplySettings)
    sceneGroup:insert(buttonResetSettings)
    
    ------------------------------------------------------
    -- Control Settings Widgets
    ------------------------------------------------------

    buttonControlSettings = widget.newButton({
        x = 250, 
        y = 50,
        id = "buttonControlSettings",
        label = "Controls",
        onEvent = handleButtonEvent,
        font = "fonts/BULKYPIX.TTF",
        fontSize = 20,
        labelColor = { default={ 1, 1, 1, 0.7 }, over={ 1, 1, 1, 0.5 } }
    })

    buttonKeybinds = widget.newButton({
        x = 250,
        y = 100,
        id = "buttonKeybinds",
        label = "Keybinds",
        onEvent = handleButtonEvent,
        font = "fonts/BULKYPIX.TTF",
        fontSize = 20,
        labelColor = { default={ 1, 1, 1 }, over={ 1, 1, 1, 0.5 } }
    })

    buttonInputDevice = widget.newButton({
        x = 250,
        y = 150,
        id = "buttonInputDevice",
        label = "Input Device",
        onEvent = handleButtonEvent,
        font = "fonts/BULKYPIX.TTF",
        fontSize = 20,
        labelColor = { default={ 1, 1, 1 }, over={ 1, 1, 1, 0.5 } }
    })

    line1 = display.newLine(100,50,180,50)
    line2 = display.newLine(320,50,400,50)

    scrollView:insert(buttonControlSettings)
    scrollView:insert(buttonKeybinds)
    scrollView:insert(buttonInputDevice)
    scrollView:insert(line1)
    scrollView:insert(line2)
    
    ------------------------------------------------------
    -- Sound Settings Widgets
    ------------------------------------------------------
    buttonSoundSettings = widget.newButton({
        x = 250,
        y = 200,
        id = "buttonSoundSettings",
        label = "Sound",
        onEvent = handleButtonEvent,
        font = "fonts/BULKYPIX.TTF",
        fontSize = 20,
        labelColor = { default={ 1, 1, 1, 0.7 }, over={ 1, 1, 1, 0.5 } }
    })

    textMusicVolume = display.newText({
        text = "Music Volume",
        x = 150,
        y = 250,
        font = "fonts/BULKYPIX.TTF",
        fontSize = 20,
    })

    segmentMusicVolume = widget.newSegmentedControl({
        x = 350,
        y = 250,
        id = "segmentMusicVolume",
        segmentWidth = 35,
        segments = { "0", "1", "2", "3", "4" },
        -- defaultSegment = settings.musicVolume oder so.
        labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
        labelFont = "fonts/BULKYPIX.TTF",
    })

    textEffectsVolume = display.newText({
        text = "Effects Volume",
        x = 140,
        y = 300,
        font = "fonts/BULKYPIX.TTF",
        fontSize = 20,
    })

    segmentEffectsVolume = widget.newSegmentedControl({
        x = 350,
        y = 300,
        id = "segmentEffectsVolume",
        segmentWidth = 35,
        segments = { "0", "1", "2", "3", "4" },
        -- defaultSegment = settings.musicVolume oder so.
        labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
        labelFont = "fonts/BULKYPIX.TTF",
    })

    line3 = display.newLine(100,200,190,200)
    line4 = display.newLine(300,200,400,200)

    scrollView:insert(buttonSoundSettings)
    scrollView:insert(textMusicVolume)
    scrollView:insert(segmentMusicVolume)
    scrollView:insert(textEffectsVolume)
    scrollView:insert(segmentEffectsVolume)
    scrollView:insert(line3)
    scrollView:insert(line4)
    ------------------------------------------------------
    -- Visual Settings Widgets
    ------------------------------------------------------
    buttonVisualSettings = widget.newButton({
        x = 250,
        y = 350,
        id = "buttonVisualSettings",
        label = "Visual",
        onEvent = handleButtonEvent,
        font = "fonts/BULKYPIX.TTF",
        fontSize = 20,
        labelColor = { default={ 1, 1, 1, 0.7 }, over={ 1, 1, 1, 0.5 } }
    })

    switchParticles = widget.newSwitch({
        id = "switchParticles",
        x = 310,
        y = 400,
        initialSwitchState = false, --from settings
        -- onRelease (for Touchcontrol)
    })

    textParticles = display.newText({
        text = "Particles",
        x = 190,
        y = 400,
        font = "fonts/BULKYPIX.TTF",
        fontSize = 20,
    })

    line5 = display.newLine(100,350,190,350)
    line6 = display.newLine(300,350,400,350)

    scrollView:insert(buttonVisualSettings)
    scrollView:insert(switchParticles)
    scrollView:insert(textParticles)
    scrollView:insert(line5)
    scrollView:insert(line6)
    ------------------------------------------------------
    -- Ingame Settings Widgets
    ------------------------------------------------------
    buttonIngameSettings = widget.newButton({
        x = 250,
        y = 450,
        id = "buttonIngameSettings",
        label = "Ingame",
        onEvent = handleButtonEvent,
        font = "fonts/BULKYPIX.TTF",
        fontSize = 20,
        labelColor = { default={ 1, 1, 1, 0.7 }, over={ 1, 1, 1, 0.5 } }
    })

    segmentDifficulty = widget.newSegmentedControl({
        x = 330,
        y = 500,
        id = "segmentDifficulty",
        segmentWidth = 35,
        segments = {"1", "2", "3"},
        -- defaultSegment = settings.musicVolume oder so.
        labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
        labelFont = "fonts/BULKYPIX.TTF",
    })

    textDifficulty = display.newText({
        text = "Difficulty",
        x = 190,
        y = 500,
        font = "fonts/BULKYPIX.TTF",
        fontSize = 20,
    })

    line7 = display.newLine(100, 450, 190, 450)
    line8 = display.newLine(310, 450, 400, 450)

    scrollView:insert(buttonIngameSettings)
    scrollView:insert(segmentDifficulty)
    scrollView:insert(textDifficulty)
    scrollView:insert(line7)
    scrollView:insert(line8)

    ------------------------------------------------------
    -- sceneGroup:insert()
    ------------------------------------------------------
    sceneGroup:insert(scrollView)
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

        scene.navigationMatrix = {
            ["center"] = {"buttonKeybinds", "buttonKeybinds", "buttonKeybinds", "buttonBack"},
            ["buttonBack"] = {"buttonApplySettings","buttonKeybinds", "buttonApplySettings", "buttonResetSettings"},
            ["buttonApplySettings"] = {"buttonKeybinds", "buttonResetSettings", "buttonBack", "buttonBack"},
            ["buttonResetSettings"] = {"buttonKeybinds", "buttonBack", "buttonBack", "buttonApplySettings"},
            ["buttonKeybinds"] = {"buttonBack", "buttonResetSettings", "buttonInputDevice", "buttonBack"},
            ["buttonInputDevice"] = {"buttonKeybinds", "buttonResetSettings", "segmentMusicVolume", "buttonBack"},
            ["segmentMusicVolume"] = {"buttonInputDevice", "____", "segmentEffectsVolume", "_____"},
            ["segmentEffectsVolume"] = {"segmentMusicVolume", "_____", "switchParticles", "_____"},
            ["switchParticles"] = {"segmentEffectsVolume", "____", "segmentDifficulty", "____"},
            ["segmentDifficulty"] = {"switchParticles", "____", "buttonApplySettings", "____"}
            }
        scene.objTable = {["center"]=nil,
            ["buttonBack"] = buttonBack,
            ["buttonApplySettings"] = buttonApplySettings,
            ["buttonResetSettings"] = buttonResetSettings,
            ["buttonKeybinds"] = buttonKeybinds,
            ["buttonInputDevice"] = buttonInputDevice,
            ["segmentMusicVolume"] = segmentMusicVolume,
            ["segmentEffectsVolume"] = segmentEffectsVolume,
            ["switchParticles"] = switchParticles,
            ["segmentDifficulty"] = segmentDifficulty,
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