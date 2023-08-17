-- Template from Solar2D-Guide: https://docs.coronalabs.com/guide/system/composer/index.html#template

local widget = require( "widget" )
local composer = require( "composer" )
local library = require("library")
local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Scene event functions
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

local function handleScrollView(i,o)     
    if (i == 1) or (i == 10) or (i == 11) then
        -- We dont want to scroll because these buttons arent in the scrollView
        return
    end
    
    local m, n = scrollView:getContentPosition()
    local x,y = o:localToContent(0,0)
    -- Upscrolling
    if (y <= display.contentCenterY - scrollView.height*0.5) then
        scrollView:scrollToPosition({y=-(o.y-110), time=1000} ) 
    -- Downscrolling
    elseif (y+20 >= display.contentCenterY + scrollView.height*0.5) then
        scrollView:scrollToPosition({y=-(o.y-110), time=1000} )
    end
end

function scene:hoverObj()
    local currObject = scene.currObject
    for i,object in pairs(scene.referenceTable) do
        local params = {}
        if (i == currObject) then
            handleScrollView(i,object)
            params = {time = 200, transition = easing.outQuint, xScale = 1.5, yScale = 1.5,}     
        else
            params = {time = 200, transition = easing.outQuint, xScale = 1, yScale = 1,}
        end
        transition.to(object, params)
    end
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

function scene:handleSegment(index, value)
    if (index == 4) then
        local old = tmpSettings.volumeMusic
        local check = old + value
        if (check <= 4 ) and (check >= 0 ) then
            tmpSettings.volumeMusic = check
            segmentMusicVolume:setActiveSegment(tmpSettings.volumeMusic + 1) -- +1 because the segment needs minimum "1"
            scene.isSaved = false
        end
    elseif (index == 5) then
        local old = tmpSettings.volumeSoundEffects
        local check = old + value
        if (check <= 4 ) and (check >= 0 ) then
            tmpSettings.volumeSoundEffects = check
            segmentEffectsVolume:setActiveSegment(tmpSettings.volumeSoundEffects + 1) -- +1 because the segment needs minimum "1"
            scene.isSaved = false
        end
    elseif (index == 9) then
        local old = tmpSettings.difficulty
        local check = old + value
        if (check <= 3 ) and (check >= 1 ) then
            tmpSettings.difficulty = check
            segmentDifficulty:setActiveSegment(tmpSettings.difficulty) -- +1 because the segment needs minimum "1"
            scene.isSaved = false
        end
    end
end

function scene:handleSwitch(index, boolean)
    if (index == 7) then
        local status = tmpSettings.playStereo
        if status and not boolean then
            switchStereo:setState( {isOn = false, isAnimated = true} )
            tmpSettings.playStereo = false 
            scene.isSaved = false
        elseif not status and boolean then
            switchStereo:setState( {isOn = true, isAnimated = true} )
            tmpSettings.playStereo = true 
            scene.isSaved = false
        end
    elseif (index == 8) then
        local status = tmpSettings.renderParticles
        if status and not boolean then
            switchParticles:setState( {isOn = false, isAnimated = true} )
            tmpSettings.renderParticles = false 
            scene.isSaved = false
        elseif not status and boolean then
            switchParticles:setState( {isOn = true, isAnimated = true} )
            tmpSettings.renderParticles = true 
            scene.isSaved = false
        end
    end
end

local function handleButtonEvent(event)
    if (event.phase == 'ended') then
        local id = event.target.id
        if (id == 'buttonBack') then
            scene:handleObjectInteraction('buttonBack')
            return

        elseif (id == 'buttonApplySettings') then
            scene:handleObjectInteraction('buttonApplySettings')
            return

        elseif (id == 'buttonResetSettings') then
            scene:handleObjectInteraction('buttonResetSettings')
            return
        end
    end 
end

function scene:handleObjectInteraction(object, param)
    if (object == "buttonBack") then
        scene:back()
    elseif (object == "buttonResetSettings") then
        scene:resetSettings()
    elseif (object == "buttonApplySettings") then
        scene:applySettings(scene.tmpSettings)
    elseif (object == "buttonKeybinds") then
        -- composer.showOverlay(keybindsoverlay.lua)
    elseif (object == "buttonInputDevice") then
        -- composer.showOverlay(inputdeviceoverlay.lua)
    elseif (object == "segmentMusicVolume") then
        scene:handleSegment(param)
    elseif (object == "segmentEffectsVolume") then
        scene:handleSegment(param)
    elseif (object == "switchParticles") then
        scene:handleSwitch(param)
    elseif (object == "segmentDifficulty") then
        scene:handleSegment(param) ------------------------- wo andere Variable?
    end
end

function scene:applySettings(tmpSettings)
    -- Save to file
    library.saveSettings(tmpSettings)

    -- Initiate Settings
    library.initiateSettings(tmpSettings)

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

function scene:showOverlay(overlay)
    composer.showOverlay(overlay, {isModal=true, effect="fade", time=400})
    transition.fadeOut( sceneGroup, {time=1000, transition=easing.inOutCubic} )
    print("DARKER")
end

function scene:hideOverlay()
    -- We dont hive Overlay here but directly in the overlay.
    -- This functions only purpose is to change alpha of scene.
    composer.hideOverlay({isModal=true, effect="fade", time=400})
    transition.fadeIn( sceneGroup, {time=1000, transition=easing.inOutCubic} )
end

function scene:loadUI()
    sceneGroup = scene.view

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
        defaultSegment = tmpSettings.volumeMusic+1,
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
        defaultSegment = tmpSettings.volumeSoundEffects,
        labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
        labelFont = "fonts/BULKYPIX.TTF",
    })

    buttonOutputDevice = widget.newButton({
        x = 240,
        y = 350,
        id = "buttonOutputDevice",
        label = "Output Device",
        onEvent = handleButtonEvent,
        font = "fonts/BULKYPIX.TTF",
        fontSize = 20,
        labelColor = { default={ 1, 1, 1}, over={ 1, 1, 1, 0.5 } }
    })

    switchStereo = widget.newSwitch({
        id = "switchStereo",
        x = 310,
        y = 400,
        initialSwitchState = tmpSettings.playStereo,
        -- onRelease (for Touchcontrol)
    })

    textStero = display.newText({
        text = "Stereo",
        x = 190,
        y = 400,
        font = "fonts/BULKYPIX.TTF",
        fontSize = 20,
    })

    line3 = display.newLine(100,200,190,200)
    line4 = display.newLine(300,200,400,200)

    scrollView:insert(buttonSoundSettings)
    scrollView:insert(textMusicVolume)
    scrollView:insert(segmentMusicVolume)
    scrollView:insert(textEffectsVolume)
    scrollView:insert(segmentEffectsVolume)
    scrollView:insert(buttonOutputDevice)
    scrollView:insert(switchStereo)
    scrollView:insert(textStero)
    scrollView:insert(line3)
    scrollView:insert(line4)
    ------------------------------------------------------
    -- Visual Settings Widgets
    ------------------------------------------------------
    buttonVisualSettings = widget.newButton({
        x = 250,
        y = 450,
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
        y = 500,
        initialSwitchState = tmpSettings.renderParticles,
        -- onRelease (for Touchcontrol)
    })

    textParticles = display.newText({
        text = "Particles",
        x = 190,
        y = 500,
        font = "fonts/BULKYPIX.TTF",
        fontSize = 20,
    })

    line5 = display.newLine(100,450,190,450)
    line6 = display.newLine(300,450,400,450)

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
        y = 550,
        id = "buttonIngameSettings",
        label = "Ingame",
        onEvent = handleButtonEvent,
        font = "fonts/BULKYPIX.TTF",
        fontSize = 20,
        labelColor = { default={ 1, 1, 1, 0.7 }, over={ 1, 1, 1, 0.5 } }
    })

    segmentDifficulty = widget.newSegmentedControl({
        x = 330,
        y = 600,
        id = "segmentDifficulty",
        segmentWidth = 35,
        segments = {"1", "2", "3"},
        defaultSegment = tmpSettings.difficulty,
        labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
        labelFont = "fonts/BULKYPIX.TTF",
    })

    textDifficulty = display.newText({
        text = "Difficulty",
        x = 190,
        y = 600,
        font = "fonts/BULKYPIX.TTF",
        fontSize = 20,
    })

    line7 = display.newLine(100, 550, 190, 550)
    line8 = display.newLine(310, 550, 400, 550)

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
    tmpSettings = runtime.settings
    scene.isSaved = true

    -- Only the first time in center; if reshown, then last state
    scene.currObject = 2
end
 

-- show()
function scene:show( event )
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)

        -- UI sollte jedesmal neu geladen werden, nicht aber die ganze Szene, darum kein removeScene().
        scene:loadUI()

        scene.matrix = {
            {2, 2, 2, 10},
            {1, 3, 1, 1},
            {nil, 4, 1, 2},
            {4.2, 5, 4.1, 3},
            {5.2, 6, 5.1, 4},
            {nil, 7, nil, 5},
            {7.2, 8, 7.1, 6},
            {8.2, 9, 8.1, 7},
            {9.2, 10, 9.1, 8},
            {11, 1, 1, 1},
            {10, 1, 10, 9}
        }

        scene.referenceTable = {
            [1] = buttonBack,
            [2] = buttonKeybinds,
            [3] = buttonInputDevice,
            [4] = segmentMusicVolume,
            [5] = segmentEffectsVolume,
            [6] = buttonOutputDevice,
            [7] = switchStereo,
            [8] = switchParticles,
            [9] = segmentDifficulty,
            [10] = buttonApplySettings,
            [11] = buttonResetSettings,
        }
        -- Things to run when object is confirmed
        scene.functionsTable = {
            [1] = function() scene:back() end,
            [2] = function() scene:showOverlay("resources.scene.menu.keybindoverlay") end,
            [3] = function() scene:showOverlay("resources.scene.menu.inputdeviceoverlay") end,
            [4] = nil,
            [4.1] = function() scene:handleSegment(4, -1) end,
            [4.2] = function() scene:handleSegment(4, 1) end,
            [5] = nil,
            [5.1] = function() scene:handleSegment(5, -1) end,
            [5.2] = function() scene:handleSegment(5, 1) end,
            [6] = function() scene:showOverlay("resources.scene.menu.outputdeviceoverlay") end,
            [7] = nil,
            [7.1] = function() scene:handleSwitch(7, false) end,
            [7.2] = function() scene:handleSwitch(7, true) end,
            [8] = nil,
            [8.1] = function() scene:handleSwitch(8, false) end,
            [8.2] = function() scene:handleSwitch(8, true) end,
            [9] = nil,
            [9.1] = function() scene:handleSegment(9, -1) end,
            [9.2] = function() scene:handleSegment(9, 1) end,
            [10] = function() scene:applySettings(tmpSettings) end,
            [11] = function() scene:resetSettings() end,
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