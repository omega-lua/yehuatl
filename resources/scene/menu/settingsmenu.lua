-- Template from Solar2D-Guide: https://docs.coronalabs.com/guide/system/composer/index.html#template

local widget = require( "widget" )
local composer = require( "composer" )
local library = require("library")
local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function scene:showToast(message)
    sceneGroup = scene.view
    
    local toast = display.newText({
        text = message,     
        x = display.contentCenterX,
        y = display.contentCenterX*0.1,
        width = 256,
        font = "fonts/BULKYPIX.TTF",   
        fontSize = 18,
        align = "center"
    })
 
    local params = {
        time = 1000,
        tag = "toast",
        transition = easing.outQuart,
        delay = 1500,
        alpha = 0
    }
    
    toast:setFillColor(0, 255, 0)
    sceneGroup:insert(toast)
    transition.to(toast, params)
end

local function handleScrollView()     
    local widget = scene.widgetsTable[scene.widgetIndex]
    local m,n = widget.pointer:localToContent(0,0)
    local x,y = widget.pointer.x, widget.pointer.y
    -- Upscrolling
    if (n <= display.contentCenterY - scrollView.height*0.5) then
        --scrollView:scrollToPosition({y=-(y-110), time=1000} ) 
        scrollView:scrollToPosition({y=-(y-100), time=1000} ) 
    -- Downscrolling
    elseif (n+150 >= display.contentCenterY + scrollView.height*0.5) then
        --scrollView:scrollToPosition({y=-(y-110), time=1000} )
        scrollView:scrollToPosition({y=-(y-300), time=1000} ) 
    end
end

function scene:hoverObj()
    local widgetIndex = scene.widgetIndex
    for i,widget in pairs(scene.widgetsTable) do
        local params = {}
        if (i == widgetIndex) then 
            params = {time = 200, transition = easing.outQuint, xScale = 1.5, yScale = 1.5}     
        else
            params = {time = 200, transition = easing.outQuint, xScale = 1, yScale = 1}
        end
        transition.to(widget.pointer, params)
    end
end

function scene:updateUI()
    scene:hoverObj()
    handleScrollView()
end

function scene:back()
    if (scene.isSaved == false) then
        -- Darken scene behind...
        
        -- Show Overlay... Overlay hat drei Buttons, Speichern, Abbrechen, nicht speichern
        composer.showOverlay("resources.scene.menu.warningmenu", {isModal=true})
    else
        -- if settings are saved
        library.handleSceneChange("resources.scene.menu.mainmenu", "menu", { effect = "fade", time = 400,})
        
        tmpSettings = nil
        scene.isSaved = true
    end
end

function scene:handleSegment(index, value)
    local widget = scene.widgetsTable[index]

    -- Music Volume Segment
    if (index == 12) then
        -- For touchcontrol
        if not value then
            local value = widget.pointer.segmentNumber
            tmpSettings.sound.volumeMusic = value
            scene.isSaved = false
            return
        end

        local old = tmpSettings.sound.volumeMusic
        local value = old + value
        if (value <= 5 ) and (value >= 1 ) then
            tmpSettings.sound.volumeMusic = value
            widget.pointer:setActiveSegment(value)
            scene.isSaved = false
        end
    
    -- Sound Effects Volume Segment
    elseif (index == 14) then
        -- For touchcontrol
        if not value then
            local value = widget.pointer.segmentNumber
            tmpSettings.sound.volumeSoundEffects = value
            scene.isSaved = false
            return
        end

        local old = tmpSettings.sound.volumeSoundEffects
        local value = old + value
        if (value <= 5 ) and (value >= 1 ) then
            tmpSettings.sound.volumeSoundEffects = value
            widget.pointer:setActiveSegment(value)
            scene.isSaved = false
        end
    
    -- Difficutly Segment
    elseif (index == 26) then
        -- For touchcontrol
        if not value then
            local value = widget.pointer.segmentNumber
            tmpSettings.ingame.difficulty = value
            scene.isSaved = false
            return
        end
        
        local old = tmpSettings.ingame.difficulty
        local value = old + value
        if (value <= 3 ) and (value >= 1 ) then
            tmpSettings.ingame.difficulty = value
            widget.pointer:setActiveSegment(value)
            scene.isSaved = false
        end
    end
end

function scene:handleSwitch(index, boolean)
    local widget = scene.widgetsTable[index]
    -- Enable Stereo Widget
    if (index == 16) then
        -- Touchcontrol
        if (boolean == nil) then
            local state = widget.pointer.isOn
            tmpSettings.sound.playStereo = state
            scene.isSaved = false
            return
        end
        
        local state = tmpSettings.sound.playStereo
        if state and not boolean then
            widget.pointer:setState( {isOn = false, isAnimated = true} )
            tmpSettings.sound.playStereo = false 
            scene.isSaved = false
        elseif not state and boolean then
            widget.pointer:setState( {isOn = true, isAnimated = true} )
            tmpSettings.sound.playStereo = true 
            scene.isSaved = false
        end

    elseif (index == 21) then
        -- Touchcontrol
        if (boolean == nil) then
            local state = widget.pointer.isOn
            tmpSettings.sound.playStereo = state
            scene.isSaved = false
            return
        end
        
        local state = tmpSettings.visual.renderParticles
        if state and not boolean then
            widget.pointer:setState( {isOn = false, isAnimated = true} )
            tmpSettings.visual.renderParticles = false 
            scene.isSaved = false
        elseif not state and boolean then
            widget.pointer:setState( {isOn = true, isAnimated = true} )
            tmpSettings.visual.renderParticles = true 
            scene.isSaved = false
        end
    end
end

function scene:applySettings()
    local data = tmpSettings

    -- Save to file
    library.saveSettings(data)

    -- Initiate Settings
    library.initiateSettings(data)
    library.initiateKeybinds(data.controls.keybinds[runtime.currentInputDevice])

    tmpSettings = deepcopy(runtime.settings)
    scene.isSaved = true

    scene:showToast("settings apllied!")
end

function scene:resetSettings()
    -- Get default_settings and save as settings.json
    local data = library.resetSettings()

    -- Initiate Settings
    library.initiateSettings(data)

    tmpSettings = deepcopy(runtime.settings)
    scene.isSaved = true

    scene:updateUI()

    scene:showToast("settings reset!")
end

local function handleInteraction(event)
    if (event.phase == 'ended') then
        local id = event.target.id
        if (id == 'buttonBack') then
            scene:back()

        elseif (id == 'buttonApplySettings') then
            scene:applySettings()

        elseif (id == 'buttonResetSettings') then
            scene:resetSettings()

        elseif (id == 'buttonKeybinds') then
            library.handleSceneChange("resources.scene.menu.keybindoverlay", "menu", {effect='fade', time=400})

        elseif (id == 'buttonInputDevice') then
            library.handleSceneChange("resources.scene.menu.inputdevicemenu", "menu", {effect='fade', time=400})

        elseif (id == 'buttonOutputDevice') then
            library.handleSceneChange("resources.scene.menu.outputdeviceoverlay", "menu", {effect='fade', time=400})
        end
    end 
end

function scene:loadUI()
    sceneGroup = scene.view

    scrollView = widget.newScrollView({
        id = "scrollView",
        x = display.contentCenterX,
        y = display.contentCenterY,
        width = 800,
        height = 400,
        horizontalScrollDisabled = true,
        friction = 0.985,
        scrollWidth = 800,
        scrollHeight = 1200,
        backgroundColor = { 0, 0, 0},
    })

    -- Create widgets
    for i, object in pairs(scene.widgetsTable) do
        local type = object.type

        if (type == "text") then
            scene.widgetsTable[i].pointer = display.newText( object.creation )
            scrollView:insert(scene.widgetsTable[i].pointer)
            if object.color then
                scene.widgetsTable[i].pointer:setFillColor(unpack(object.color))
            end

        elseif (type == "line") then
            scene.widgetsTable[i].pointer = display.newLine(unpack(object.creation))
            scrollView:insert(scene.widgetsTable[i].pointer)
            if object.color then
                scene.widgetsTable[i].pointer:setStrokeColor(unpack(object.color))
            end
        
        elseif (type == "button") then
            scene.widgetsTable[i].pointer = widget.newButton( object.creation )
            scrollView:insert(scene.widgetsTable[i].pointer)

        elseif (type == "segment") then
            scene.widgetsTable[i].pointer = widget.newSegmentedControl( object.creation )
            scrollView:insert(scene.widgetsTable[i].pointer)

        elseif (type == "switch") then
            scene.widgetsTable[i].pointer = widget.newSwitch( object.creation )
            scrollView:insert(scene.widgetsTable[i].pointer)

        elseif (type == nil) then
            print("ERROR: Widget",i,"has no type attribute.")
        end
    end
    sceneGroup:insert(scrollView)
end

-- create()
function scene:create( event )
    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen

    -- Has to be set before widgetsTable
    tmpSettings = deepcopy(runtime.settings)
    
    scene.isSaved = true

    -- Only the first time in center; if reshown, then last state
    scene.widgetIndex = 6
end

-- show()
function scene:show( event )
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)

        if tmpSettings == nil then
            print("tmpSettings is nil")
            tmpSettings = deepcopy(runtime.settings)
            scene.isSaved = true
        end

        -- Has to be here, so that it refreshes the UI everytime. Has to be set before scene:loadUI()
        scene.widgetsTable = {
            [1] = {
                ["creation"] = {
                    x = 50,
                    y = 50,
                    id = "buttonBack",
                    label = "back",
                    onEvent = handleInteraction,
                    font = "fonts/BULKYPIX.TTF",
                    fontSize = 20,
                    labelColor = { default={ 1, 1, 1 }, over={ 1, 1, 1, 0.5 } }
                },
                ["function"] = function() scene:dispatchEvent({ name="interaction", target={id="buttonBack"}, phase="ended"}) end,
                ["navigation"] = {5,5,5,27},
                ["pointer"] = {},
                ["type"] = "button"
            },
            [2] = {
                ["creation"] = {100,50,320,50},
                ["function"] = nil,
                ["navigation"] = {},
                ["pointer"] = {},
                ["type"] = "line",
                ["color"] = { 1, 1, 1, 0.6},
            },
            [3] = {
                ["creation"] = {
                    x = 400, 
                    y = 50,
                    id = "textControls",
                    text = "Controls",
                    font = "fonts/BULKYPIX.TTF",
                    fontSize = 20,
                },
                ["function"] = nil,
                ["navigation"] = {},
                ["pointer"] = {},
                ["type"] = "text",
                ["color"] = { 1, 1, 1, 0.6}
            },
            [4] = {
                ["creation"] = {480,50,700,50},
                ["function"] = nil,
                ["navigation"] = {},
                ["pointer"] = {},
                ["type"] = "line",
                ["color"] = { 1, 1, 1, 0.6},
            },
            [5] = {
                ["creation"] = {
                    x = 400,
                    y = 100,
                    id = "buttonKeybinds",
                    label = "Keybinds",
                    onEvent = handleInteraction,
                    font = "fonts/BULKYPIX.TTF",
                    fontSize = 20,
                    labelColor = { default={ 1, 1, 1 }, over={ 1, 1, 1, 0.5 } }
                },
                ["function"] = function() scene:dispatchEvent({ name="interaction", target={id="buttonKeybinds"}, phase="ended"}) end,
                ["navigation"] = {nil,6,nil,1},
                ["pointer"] = {},
                ["type"] = "button",
            },
            [6] = {
                ["creation"] = {
                    x = 400,
                    y = 150,
                    id = "buttonInputDevice",
                    label = "Input Device",
                    onEvent = handleInteraction,
                    font = "fonts/BULKYPIX.TTF",
                    fontSize = 20,
                    labelColor = { default={ 1, 1, 1 }, over={ 1, 1, 1, 0.5 } }
                },
                ["function"] = function() scene:dispatchEvent({ name="interaction", target={id="buttonInputDevice"}, phase="ended"}) end,
                ["navigation"] = {nil,10,nil,5},
                ["pointer"] = {},
                ["type"] = "button",
            },
            [7] = {
                ["creation"] = {100,200,340,200},
                ["function"] = nil,
                ["navigation"] = {},
                ["pointer"] = {},
                ["type"] = "line",
                ["color"] = { 1, 1, 1, 0.6},
            },
            [8] = {
                ["creation"] = {
                    x = 400,
                    y = 200,
                    text = "Sound",
                    font = "fonts/BULKYPIX.TTF",
                    fontSize = 20},
                ["function"] = nil,
                ["navigation"] = {},
                ["pointer"] = {},
                ["type"] = "text",
                ["color"] = { 1, 1, 1, 0.6},
            },
            [9] = {
                ["creation"] = {460,200,700,200},
                ["function"] = nil,
                ["navigation"] = {},
                ["pointer"] = {},
                ["type"] = "line",
                ["color"] = { 1, 1, 1, 0.6},
            },
            [10] = {
                ["creation"] = {
                    x = 400,
                    y = 250,
                    id = "buttonOutputDevice",
                    label = "Output Device",
                    onEvent = handleInteraction,
                    font = "fonts/BULKYPIX.TTF",
                    fontSize = 20,
                    labelColor = { default={ 1, 1, 1}, over={ 1, 1, 1, 0.5 } }
                },
                ["function"] = function() scene:dispatchEvent({ name="interaction", target={id="buttonOutputDevice"}, phase="ended"}) end,
                ["navigation"] = {nil,12,nil,6},
                ["pointer"] = {},
                ["type"] = "button",
            },
            [11] = {
                ["creation"] = {
                    text = "Music Volume",
                    x = 280,
                    y = 300,
                    font = "fonts/BULKYPIX.TTF",
                    fontSize = 20,
                },
                ["function"] = nil,
                ["navigation"] = {},
                ["pointer"] = {},
                ["type"] = "text",
            },
            [12] = {
                ["creation"] = {
                    x = 520,
                    y = 300,
                    id = "segmentMusicVolume",
                    segmentWidth = 35,
                    segments = { "0", "1", "2", "3", "4" },
                    defaultSegment = tmpSettings.sound.volumeMusic,
                    labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
                    labelFont = "fonts/BULKYPIX.TTF",
                    onPress = function() scene:handleSegment(12) end,
                },
                ["function"] = nil, --function()  end
                ["navigation"] = {function() scene:handleSegment(12,1) end,14, function() scene:handleSegment(12,-1) end,10},
                ["pointer"] = {},
                ["type"] = "segment",
            },
            [13] = {
                ["creation"] = {
                    text = "Effects Volume",
                    x = 280,
                    y = 350,
                    font = "fonts/BULKYPIX.TTF",
                    fontSize = 20,
                },
                ["function"] = nil,
                ["navigation"] = {},
                ["pointer"] = {},
                ["type"] = "text",
            },
            [14] = {
                ["creation"] = {
                    x = 520,
                    y = 350,
                    id = "segmentEffectsVolume",
                    segmentWidth = 35,
                    segments = { "0", "1", "2", "3", "4" },
                    defaultSegment = tmpSettings.sound.volumeSoundEffects,
                    labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
                    labelFont = "fonts/BULKYPIX.TTF",
                    onPress = function() scene:handleSegment(14) end,
                },
                ["function"] = nil,
                ["navigation"] = {function() scene:handleSegment(14,1) end, 16, function() scene:handleSegment(14,-1) end,12},
                ["pointer"] = {},
                ["type"] = "segment",
            },
            [15] = {
                ["creation"] = {
                    text = "Stereo",
                    x = 320,
                    y = 400,
                    font = "fonts/BULKYPIX.TTF",
                    fontSize = 20,
                },
                ["function"] = nil,
                ["navigation"] = {},
                ["pointer"] = {},
                ["type"] = "text",
            },
            [16] = {
                ["creation"] = {
                    id = "switchStereo",
                    x = 480,
                    y = 400,
                    initialSwitchState = tmpSettings.sound.playStereo,
                    onRelease = function() scene:handleSwitch(16) end,
                },
                ["function"] = nil,
                ["navigation"] = {function() scene:handleSwitch(16,true) end,21, function()scene:handleSwitch(16,false) end,14},
                ["pointer"] = {},
                ["type"] = "switch",
            },
            [17] = {
                ["creation"] = {100,450,340,450},
                ["function"] = nil,
                ["navigation"] = {},
                ["pointer"] = {},
                ["type"] = "line",
                ["color"] = { 1, 1, 1, 0.6},
            },
            [18] = {
                ["creation"] = {
                    x = 400,
                    y = 450,
                    text = "Visual",
                    font = "fonts/BULKYPIX.TTF",
                    fontSize = 20,
                },
                ["function"] = nil,
                ["navigation"] = {},
                ["pointer"] = {},
                ["type"] = "text",
                ["color"] = { 1, 1, 1, 0.6},
            },
            [19] = {
                ["creation"] = {460,450,700,450},
                ["function"] = nil,
                ["navigation"] = {},
                ["pointer"] = {},
                ["type"] = "line",
                ["color"] = { 1, 1, 1, 0.6},
            },
            [20] = {
                ["creation"] = {
                    text = "Particles",
                    x = 320,
                    y = 500,
                    font = "fonts/BULKYPIX.TTF",
                    fontSize = 20,
                },
                ["function"] = nil,
                ["navigation"] = {},
                ["pointer"] = {},
                ["type"] = "text",
            },
            [21] = {
                ["creation"] = {
                    id = "switchParticles",
                    x = 480,
                    y = 500,
                    initialSwitchState = tmpSettings.visual.renderParticles,
                    -- onRelease (for Touchcontrol)
                },
                ["function"] = nil,
                ["navigation"] = {function() scene:handleSwitch(21,true) end,26,function() scene:handleSwitch(21,false) end,16},
                ["pointer"] = {},
                ["type"] = "switch",
            },
            [22] = {
                ["creation"] = {100,550,340,550},
                ["function"] = nil,
                ["navigation"] = {},
                ["pointer"] = {},
                ["type"] = "line",
                ["color"] = { 1, 1, 1, 0.6},
            },
            [23] = {
                ["creation"] = {
                    x = 400,
                    y = 550,
                    text = "Ingame",
                    font = "fonts/BULKYPIX.TTF",
                    fontSize = 20,
                },
                ["function"] = nil,
                ["navigation"] = {},
                ["pointer"] = {},
                ["type"] = "text",
                ["color"] = { 1, 1, 1, 0.6},
            },
            [24] = {
                ["creation"] = {460,550,700,550},
                ["function"] = nil,
                ["navigation"] = {},
                ["pointer"] = {},
                ["type"] = "line",
                ["color"] = { 1, 1, 1, 0.6},
            },
            [25] = {
                ["creation"] = {
                    text = "Difficulty",
                    x = 320,
                    y = 600,
                    font = "fonts/BULKYPIX.TTF",
                    fontSize = 20,
                },
                ["function"] = nil,
                ["navigation"] = {},
                ["pointer"] = {},
                ["type"] = "text",
            },
            [26] = {
                ["creation"] = {
                    x = 480,
                    y = 600,
                    id = "segmentDifficulty",
                    segmentWidth = 35,
                    segments = {"1", "2", "3"},
                    defaultSegment = tmpSettings.ingame.difficulty,
                    labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
                    labelFont = "fonts/BULKYPIX.TTF",
                    onPress = function() scene:handleSegment(26) end,
                },
                ["function"] = nil,
                ["navigation"] = {function() scene:handleSegment(26,1) end,27,function() scene:handleSegment(26,-1) end,21},
                ["pointer"] = {},
                ["type"] = "segment",
            },
            [27] = {
                ["creation"] = {
                    x = 250,
                    y = 700,
                    id = "buttonApplySettings",
                    label = "Apply Settings",
                    onEvent = handleInteraction,
                    font = "fonts/BULKYPIX.TTF",
                    fontSize = 20,
                    labelColor = { default={ 1, 1, 1 }, over={ 1, 1, 1, 0.5 } }
                },
                ["function"] = function() scene:dispatchEvent({ name="interaction", target={id="buttonApplySettings"}, phase="ended"}) end,
                ["navigation"] = {28, 1, 28, 26},
                ["pointer"] = {},
                ["type"] = "button",
            },
            [28] = {
                ["creation"] = {
                    x = 550,
                    y = 700,
                    id = "buttonResetSettings",
                    label = "Reset Settings",
                    onEvent = handleInteraction,
                    font = "fonts/BULKYPIX.TTF",
                    fontSize = 20,
                    labelColor = { default={ 1, 1, 1 }, over={ 1, 1, 1, 0.5 } }
                },
                ["function"] = function() scene:dispatchEvent({ name="interaction", target={id="buttonResetSettings"}, phase="ended"}) end,
                ["navigation"] = {27, 1, 27, 26},
                ["pointer"] = {},
                ["type"] = "button",
            },
        }

        -- UI sollte jedesmal neu geladen werden, nicht aber die ganze Szene, darum kein removeScene().
        scene:loadUI()
        scene:updateUI()

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

    end
end
 
 
-- destroy()
function scene:destroy( event )
    print("----------scene destroyed---------------")
    local sceneGroup = self.view
    -- Code here runs prior to the removal of scene's view

    tmpSettings = nil
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
scene:addEventListener("interaction", handleInteraction)
 
return scene