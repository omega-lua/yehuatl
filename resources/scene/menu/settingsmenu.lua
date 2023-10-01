-- Template from Solar2D-Guide: https://docs.coronalabs.com/guide/system/composer/index.html#template

local lib = require( "resources.lib.lib" )
local widget = require( "widget" )
local composer = require( "composer" )
local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Scene variables
-- -----------------------------------------------------------------------------------

scene.type = "menu"
scene.isSaved = true

-- -----------------------------------------------------------------------------------
-- Scene functions
-- -----------------------------------------------------------------------------------

local function deepcopy(orig)
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
    local pointer = scene.widgetsTable[scene.widgetIndex].pointer
    local m,n = pointer:localToContent(0,0)
    local x,y = pointer.x, pointer.y
    -- Upscrolling
    if (n <= display.contentCenterY - scrollView.height*0.5) then
        scrollView:scrollToPosition({y=-(y-100), time=1000} ) 
    -- Downscrolling
    elseif (n+150 >= display.contentCenterY + scrollView.height*0.5) then
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
    if (lib.control.mode == "key") then
        scene:hoverObj()
        handleScrollView()
    end
end

function scene:back()
    if (scene.isSaved == false) then
        -- Darken scene behind...
        
        -- Show Overlay... Overlay hat drei Buttons, Speichern, Abbrechen, nicht speichern
        composer.showOverlay("resources.scene.menu.warningoverlay", {effect = "fade", time = 200,isModal=true})
    else
        -- if settings are saved
        lib.scene.show("resources.scene.menu.mainmenu", { effect = "fade", time = 400,})
        
        lib.settings.tmpTable = nil
        scene.isSaved = true
    end
end

function scene:handleSegment(index, value)
    local widget = scene.widgetsTable[index]

    -- Music Volume Segment
    if (index == 11) then
        -- For touchcontrol
        if not value then
            local value = widget.pointer.segmentNumber
            lib.settings.tmpTable.sound.volumeMusic = value
            scene.isSaved = false
            return
        end

        local old = lib.settings.tmpTable.sound.volumeMusic
        local value = old + value
        if (value <= 5 ) and (value >= 1 ) then
            lib.settings.tmpTable.sound.volumeMusic = value
            widget.pointer:setActiveSegment(value)
            scene.isSaved = false
        end
    
    -- Sound Effects Volume Segment
    elseif (index == 13) then
        -- For touchcontrol
        if not value then
            local value = widget.pointer.segmentNumber
            lib.settings.tmpTable.sound.volumeSoundEffects = value
            scene.isSaved = false
            return
        end

        local old = lib.settings.tmpTable.sound.volumeSoundEffects
        local value = old + value
        if (value <= 5 ) and (value >= 1 ) then
            lib.settings.tmpTable.sound.volumeSoundEffects = value
            widget.pointer:setActiveSegment(value)
            scene.isSaved = false
        end
    
    -- Difficutly Segment
    elseif (index == 25) then
        -- For touchcontrol
        if not value then
            local value = widget.pointer.segmentNumber
            lib.settings.tmpTable.ingame.difficulty = value
            scene.isSaved = false
            return
        end
        
        local old = lib.settings.tmpTable.ingame.difficulty
        local value = old + value
        if (value <= 3 ) and (value >= 1 ) then
            lib.settings.tmpTable.ingame.difficulty = value
            widget.pointer:setActiveSegment(value)
            scene.isSaved = false
        end
    end
end

function scene:handleSwitch(index, action)
    local widget = scene.widgetsTable[index]
    
    -- Enable Stereo Widget
    if (index == 15) then
        -- Touchcontrol
        if (action == 'touch') then
            local state = widget.pointer.isOn
            lib.settings.tmpTable.sound.playStereo = state
            scene.isSaved = false
            return
        -- Keycontrol
        elseif (action == 'key') then
            local state = not widget.pointer.isOn
            lib.settings.tmpTable.sound.playStereo = state
            scene.isSaved = false

            widget.pointer:setState( {isOn = state, isAnimated = true} )
            return
        end

    -- Enable particles widget
    elseif (index == 20) then
        -- Touchcontrol
        if (action == 'touch') then
            local state = widget.pointer.isOn
            lib.settings.tmpTable.visual.renderParticles = state
            scene.isSaved = false
            return
        -- Keycontrol
        elseif (action == 'key') then
            local state = not widget.pointer.isOn
            lib.settings.tmpTable.visual.renderParticles = state
            scene.isSaved = false

            widget.pointer:setState( {isOn = state, isAnimated = true} )
            return
        end
    end
end

function scene:applySettings()
    local data = lib.settings.tmpTable

    -- Save to file
    lib.settings.save(data)

    -- Initiate Settings
    lib.settings.initiate(data)
    lib.inputdevice.initiateKeybinds(data.controls.keybinds[lib.inputdevice.current.name])

    lib.settings.tmpTable = deepcopy(lib.settings.table)
    scene.isSaved = true

    scene:showToast("settings apllied!")
end

function scene:resetSettings()
    -- Get default_settings and save as settings.json
    local data = lib.settings.reset()

    -- Initiate Settings
    lib.settings.initiate(data)

    lib.settings.tmpTable = deepcopy(lib.settings.table)
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
            lib.scene.show("resources.scene.menu.keybindoverlay", {effect='fade', time=400})

        elseif (id == 'buttonInputDevice') then
            lib.scene.show("resources.scene.menu.inputdevicemenu", {effect='fade', time=400})

        elseif (id == 'buttonOutputDevice') then
            lib.scene.show("resources.scene.menu.outputdeviceoverlay", {effect='fade', time=400})
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
        friction = 0.85,
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
    lib.settings.tmpTable = deepcopy(lib.settings.table)
    
    -- Only the first time in center; if reshown, then last state
    scene.widgetIndex = 6
end

-- show()
function scene:show( event )
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)

        if lib.settings.tmpTable == nil then
            print("lib.settings.tmpTable is nil")
            lib.settings.tmpTable = deepcopy(lib.settings.table)
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
                ["pointer"] = {},
                ["type"] = "line",
                ["color"] = {1,1,1,0.6},
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
                ["pointer"] = {},
                ["type"] = "text",
                ["color"] = {1,1,1,0.6}
            },
            [4] = {
                ["creation"] = {480,50,700,50},
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
                ["navigation"] = {nil,11,nil,5},
                ["pointer"] = {},
                ["type"] = "button",
            },
            [7] = {
                ["creation"] = {100,200,340,200},
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
                ["pointer"] = {},
                ["type"] = "text",
                ["color"] = { 1, 1, 1, 0.6},
            },
            [9] = {
                ["creation"] = {460,200,700,200},
                ["pointer"] = {},
                ["type"] = "line",
                ["color"] = { 1, 1, 1, 0.6},
            },
            [10] = {
                ["creation"] = {
                    text = "Music Volume",
                    x = 280,
                    y = 250,
                    font = "fonts/BULKYPIX.TTF",
                    fontSize = 20,
                },
                ["pointer"] = {},
                ["type"] = "text",
            },
            [11] = {
                ["creation"] = {
                    x = 520,
                    y = 250,
                    id = "segmentMusicVolume",
                    segmentWidth = 35,
                    segments = { "0", "1", "2", "3", "4" },
                    defaultSegment = lib.settings.tmpTable.sound.volumeMusic,
                    labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
                    labelFont = "fonts/BULKYPIX.TTF",
                    onPress = function() scene:handleSegment(11) end,
                },
                ["function"] = function()  end,
                ["navigation"] = {function() scene:handleSegment(11,1) end,13, function() scene:handleSegment(11,-1) end,6},
                ["pointer"] = {},
                ["type"] = "segment",
            },
            [12] = {
                ["creation"] = {
                    text = "Effects Volume",
                    x = 280,
                    y = 300,
                    font = "fonts/BULKYPIX.TTF",
                    fontSize = 20,
                },
                ["pointer"] = {},
                ["type"] = "text",
            },
            [13] = {
                ["creation"] = {
                    x = 520,
                    y = 300,
                    id = "segmentEffectsVolume",
                    segmentWidth = 35,
                    segments = { "0", "1", "2", "3", "4" },
                    defaultSegment = lib.settings.tmpTable.sound.volumeSoundEffects,
                    labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
                    labelFont = "fonts/BULKYPIX.TTF",
                    onPress = function() scene:handleSegment(13) end,
                },
                ["function"] = function()  end,
                ["navigation"] = {function() scene:handleSegment(13,1) end, 15, function() scene:handleSegment(13,-1) end,11},
                ["pointer"] = {},
                ["type"] = "segment",
            },
            [14] = {
                ["creation"] = {
                    text = "Stereo",
                    x = 320,
                    y = 350,
                    font = "fonts/BULKYPIX.TTF",
                    fontSize = 20,
                },
                ["pointer"] = {},
                ["type"] = "text",
            },
            [15] = {
                ["creation"] = {
                    id = "switchStereo",
                    x = 480,
                    y = 350,
                    initialSwitchState = lib.settings.tmpTable.sound.playStereo,
                    onRelease = function() scene:handleSwitch(15, 'touch') end,
                },
                ["function"] = function() scene:handleSwitch(15, 'key') end,
                ["navigation"] = {function() scene:handleSwitch(15,'key') end,20, function()scene:handleSwitch(15,'key') end,13},
                ["pointer"] = {},
                ["type"] = "switch",
            },
            [16] = {
                ["creation"] = {100,400,340,400},
                ["pointer"] = {},
                ["type"] = "line",
                ["color"] = { 1, 1, 1, 0.6},
            },
            [17] = {
                ["creation"] = {
                    x = 400,
                    y = 400,
                    text = "Visual",
                    font = "fonts/BULKYPIX.TTF",
                    fontSize = 20,
                },
                ["pointer"] = {},
                ["type"] = "text",
                ["color"] = { 1, 1, 1, 0.6},
            },
            [18] = {
                ["creation"] = {460,400,700,400},
                ["pointer"] = {},
                ["type"] = "line",
                ["color"] = { 1, 1, 1, 0.6},
            },
            [19] = {
                ["creation"] = {
                    text = "Particles",
                    x = 320,
                    y = 450,
                    font = "fonts/BULKYPIX.TTF",
                    fontSize = 20,
                },
                ["pointer"] = {},
                ["type"] = "text",
            },
            [20] = {
                ["creation"] = {
                    id = "switchParticles",
                    x = 480,
                    y = 450,
                    initialSwitchState = lib.settings.tmpTable.visual.renderParticles,
                    onRelease = function() scene:handleSwitch(20, 'touch') end,
                },
                ["function"] = function() scene:handleSwitch(20, 'key') end,
                ["navigation"] = {function() scene:handleSwitch(20, 'key') end,25,function() scene:handleSwitch(20, 'key') end,15},
                ["pointer"] = {},
                ["type"] = "switch",
            },
            [21] = {
                ["creation"] = {100,500,340,500},
                ["pointer"] = {},
                ["type"] = "line",
                ["color"] = { 1, 1, 1, 0.6},
            },
            [22] = {
                ["creation"] = {
                    x = 400,
                    y = 500,
                    text = "Ingame",
                    font = "fonts/BULKYPIX.TTF",
                    fontSize = 20,
                },
                ["pointer"] = {},
                ["type"] = "text",
                ["color"] = { 1, 1, 1, 0.6},
            },
            [23] = {
                ["creation"] = {460,500,700,500},
                ["pointer"] = {},
                ["type"] = "line",
                ["color"] = { 1, 1, 1, 0.6},
            },
            [24] = {
                ["creation"] = {
                    text = "Difficulty",
                    x = 320,
                    y = 550,
                    font = "fonts/BULKYPIX.TTF",
                    fontSize = 20,
                },
                ["pointer"] = {},
                ["type"] = "text",
            },
            [25] = {
                ["creation"] = {
                    x = 480,
                    y = 550,
                    id = "segmentDifficulty",
                    segmentWidth = 35,
                    segments = {"1", "2", "3"},
                    defaultSegment = lib.settings.tmpTable.ingame.difficulty,
                    labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
                    labelFont = "fonts/BULKYPIX.TTF",
                    onPress = function() scene:handleSegment(25) end,
                },
                ["function"] = function()  end,
                ["navigation"] = {function() scene:handleSegment(25,1) end,26,function() scene:handleSegment(25,-1) end,20},
                ["pointer"] = {},
                ["type"] = "segment",
            },
            [26] = {
                ["creation"] = {
                    x = 250,
                    y = 650,
                    id = "buttonApplySettings",
                    label = "Apply Settings",
                    onEvent = handleInteraction,
                    font = "fonts/BULKYPIX.TTF",
                    fontSize = 20,
                    labelColor = { default={ 1, 1, 1 }, over={ 1, 1, 1, 0.5 } }
                },
                ["function"] = function() scene:dispatchEvent({ name="interaction", target={id="buttonApplySettings"}, phase="ended"}) end,
                ["navigation"] = {27, 1, 27, 25},
                ["pointer"] = {},
                ["type"] = "button",
            },
            [27] = {
                ["creation"] = {
                    x = 550,
                    y = 650,
                    id = "buttonResetSettings",
                    label = "Reset Settings",
                    onEvent = handleInteraction,
                    font = "fonts/BULKYPIX.TTF",
                    fontSize = 20,
                    labelColor = { default={ 1, 1, 1 }, over={ 1, 1, 1, 0.5 } }
                },
                ["function"] = function() scene:dispatchEvent({ name="interaction", target={id="buttonResetSettings"}, phase="ended"}) end,
                ["navigation"] = {26, 1, 26, 25},
                ["pointer"] = {},
                ["type"] = "button",
            },
        }

        scene:loadUI()
        scene:updateUI()

    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen

        scene:addEventListener("interaction", handleInteraction)

    end
end
 
 
-- hide()
function scene:hide( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is on screen (but is about to go off screen)
 
        scene:removeEventListener("interaction", handleInteraction)

    elseif ( phase == "did" ) then
        -- Code here runs immediately after the scene goes entirely off screen

    end
end
 
 
-- destroy()
function scene:destroy( event )
    local sceneGroup = self.view
    -- Code here runs prior to the removal of scene's view

    lib.settings.tmpTable = nil
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