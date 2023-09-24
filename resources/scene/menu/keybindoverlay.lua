-- Localize
local lib = require( "resources.lib.lib" )
local composer = require( "composer" )
local widget = require( "widget" )

local scene = composer.newScene()
 
-- -----------------------------------------------------------------------------------
-- Scene variables
-- -----------------------------------------------------------------------------------

scene.type = 'menu'
scene.selectedKeybind = nil

-- -----------------------------------------------------------------------------------
-- Scene functions
-- -----------------------------------------------------------------------------------
 
function scene:showToast(message)
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
        alpha = 0
    }
    
    toast:setFillColor(0, 255, 0)
    transition.to(toast, params)
end

local function handleScrollView(i,o)     
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
    local widgetIndex = scene.widgetIndex
    for i,widget in pairs(scene.widgetsTable) do
        local params = {}
        if (i == widgetIndex) then
            params = {time = 200, transition = easing.outQuint, xScale = 1.3, yScale = 1.3,alpha=1}     
        else
            params = {time = 200, transition = easing.outQuint, xScale = 1, yScale = 1,alpha=0.7}
        end
        transition.to(widget.pointer, params)
    end
end

local function listener(event)
    if (event.phase == "up" ) then
        -- Set pressed key as new keybind in lib.settings.tmpTable
        local inputDevice = lib.inputdevice.current.name
        local keybindName = scene.selectedKeybind.name
        lib.settings.tmpTable.controls.keybinds[inputDevice][keybindName] = event.keyName

        -- Reload widget text
        local index = scene.selectedKeybind.index
        local widget = scene.widgetsTable[index].pointer
        widget:setLabel(lib.settings.tmpTable.controls.keybinds[inputDevice][keybindName])
        transition.cancel( scene.transitionBlinking )
        widget.alpha = 1

        -- Change isSaved variable
        local _scene = composer.getScene( "resources.scene.menu.settingsmenu" )
        _scene.isSaved = false
        
        -- Change selectedKeybind variable
        scene.selectedKeybind = nil

        -- Change EventListeners
        Runtime:removeEventListener("key", listener)
        Runtime:addEventListener("key", lib.control.key.menu)
    end
end

local function addListener()
    -- Change EventListeners
    Runtime:removeEventListener("key", lib.control.key.menu)
    Runtime:addEventListener("key", listener)

    -- Change buttonlable to a blinking undercase.
    local index = scene.selectedKeybind.index
    local widget = scene.widgetsTable[index].pointer
    widget:setLabel("_")
    scene.transitionBlinking = transition.to( widget, {time=1000,transition=easing.continuousLoop,alpha=0, iterations=-1} )
end

local function handleInteraction(event)
    if (event.phase == "ended") and (not scene.selectedKeybind) then
        local id = event.target.id
        if (id == "buttonBack") then
            lib.scene.show("resources.scene.menu.settingsmenu", {time=400, effect='fade'})
            return

        elseif (id == "escape") then
            scene.selectedKeybind = {name=id, index=5}
            addListener()

        elseif (id == "interact") then
            scene.selectedKeybind = {name=id, index=7}
            addListener()

        elseif (id == "forward") then
            scene.selectedKeybind = {name=id, index=9}
            addListener()

        elseif (id == "backward") then
            scene.selectedKeybind = {name=id, index=11}
            addListener()

        elseif (id == "jump") then
            scene.selectedKeybind = {name=id, index=13}
            addListener()

        elseif (id == "sneak") then
            scene.selectedKeybind = {name=id, index=15}
            addListener()

        elseif (id == "primaryWeapon") then
            scene.selectedKeybind = {name=id, index=17}
            addListener()

        elseif (id == "secondaryWeapon") then
            scene.selectedKeybind = {name=id, index=19}
            addListener()

        elseif (id == "block") then
            scene.selectedKeybind = {name=id, index=21}
            addListener()

        elseif (id == "ability") then
            scene.selectedKeybind = {name=id, index=23}
            addListener()

        elseif (id == "inventory") then
            scene.selectedKeybind = {name=id, index=25}
            addListener()
        end
    end
end


local function handleScrollView()     
    local widget = scene.widgetsTable[scene.widgetIndex]
    local m,n = widget.pointer:localToContent(0,0)
    local x,y = widget.pointer.x, widget.pointer.y
    local scrollView = scene.scrollView
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
            params = {time = 200, transition = easing.outQuint, xScale = 1.5, yScale = 1.8, alpha=1}     
        else
            -- Excludes "Keybind" and "Current" text objects
            if (i ~= 2) and (i ~= 3) then
                params = {time = 200, transition = easing.outQuint, xScale = 1, yScale = 1,alpha=0.7}
            end
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

function scene:loadUI()
    local sceneGroup = scene.view

    -- Declared as scene variable, so it doesn't mess with the scrollView of settingsmenu.lua
    scene.scrollView = widget.newScrollView({
        id="scrollView",
        x = display.contentCenterX,
        y = display.contentCenterY,
        width = 800,
        height = 400,
        horizontalScrollDisabled = true,
        scrollWidth = 800,
        scrollHeight = 1200,
        backgroundColor = { 0, 0, 0},
    })

    -- Create widgets
    for i, w in pairs(scene.widgetsTable) do
        local type = w.type
        if (type == "text") then
            scene.widgetsTable[i].pointer = display.newText( w.creation )
            scene.scrollView:insert(scene.widgetsTable[i].pointer)
        elseif (type == "button") then
            scene.widgetsTable[i].pointer = widget.newButton( w.creation )
            scene.scrollView:insert(scene.widgetsTable[i].pointer)
        end
    end
    sceneGroup:insert(scene.scrollView)
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
 
-- create()
function scene:create( event )
 
    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen

    scene.widgetIndex = 5
end
 
 
-- show()
function scene:show( event )
 
    local sceneGroup = self.view
    local phase = event.phase
    parent = event.parent

 
    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)

        scene.widgetIndex = 5
        scene.widgetsTable = {
            [1] = {
                ["creation"] = {x=50,y=50,
                    id = "buttonBack",   
                    label="back",
                    font="fonts/BULKYPIX.TTF",
                    fontSize=20,
                    onEvent=handleInteraction,
                    labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
                },
                ["function"] = function() scene:dispatchEvent({ name="interaction", target={id="buttonBack"}, phase="ended"}) end,
                ["navigation"] = {nil,5,nil,25},
                ["pointer"] = {},
                ["type"] = "button",
            },
            [2] = {
                ["creation"] = {x=280,y=80,text="Keybinds",font="fonts/BULKYPIX.TTF",fontSize=28},
                ["function"] = nil,
                ["navigation"] = {nil,nil,nil,nil},
                ["pointer"] = {},
                ["type"] = "text",
            },
            [3] = {
                ["creation"] = {x=520,y=80,text="Current",font="fonts/BULKYPIX.TTF",fontSize=28},
                ["function"] = nil,
                ["navigation"] = {nil,nil,nil,nil},
                ["pointer"] = {},
                ["type"] = "text",
            },
            [4] = {
                ["creation"] = {x=280,y=150,text="Escape",font="fonts/BULKYPIX.TTF",fontSize=20},
                ["function"] = nil,
                ["navigation"] = {nil,nil,nil,nil},
                ["pointer"] = {},
                ["type"] = "text",
            },
            [5] = {
                ["creation"] = {x=520,y=150,
                    id="escape",
                    label=lib.settings.tmpTable.controls.keybinds[lib.inputdevice.current.name].escape,
                    font="fonts/BULKYPIX.TTF",
                    fontSize=20,
                    onEvent=handleInteraction,
                    labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
                },
                ["function"] = function() scene:dispatchEvent({name="interaction", target={id="escape"}, phase="ended"}) end,
                ["navigation"] = {nil,7,nil,1},
                ["pointer"] = {},
                ["type"] = "button",
            },
            [6] = {
                ["creation"] = {x=280,y=200,text="Interact",font="fonts/BULKYPIX.TTF",fontSize=20},
                ["function"] = nil,
                ["navigation"] = {nil,nil,nil,nil},
                ["pointer"] = {},
                ["type"] = "text",
            },
            [7] = {
                ["creation"] = {x=520,y=200,
                    id="interact",
                    label=lib.settings.tmpTable.controls.keybinds[lib.inputdevice.current.name].interact,
                    font="fonts/BULKYPIX.TTF",
                    fontSize=20,
                    onEvent=handleInteraction,
                    labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
                },
                ["function"] = function() scene:dispatchEvent({name="interaction", target={id="interact"}, phase="ended"}) end,
                ["navigation"] = {nil,9,nil,5},
                ["pointer"] = {},
                ["type"] = "button",
            },
            [8] = {
                ["creation"] = {x=280,y=250,text="Forward",font="fonts/BULKYPIX.TTF",fontSize=20},
                ["function"] = nil,
                ["navigation"] = {nil,nil,nil,nil},
                ["pointer"] = {},
                ["type"] = "text",
            },
            [9] = {
                ["creation"] = {x=520,y=250,
                    id="forward",
                    label=lib.settings.tmpTable.controls.keybinds[lib.inputdevice.current.name].forward,
                    font="fonts/BULKYPIX.TTF",
                    fontSize=20,
                    onEvent=handleInteraction,
                    labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
                },
                ["function"] = function() scene:dispatchEvent({ name="interaction", target={id="forward"}, phase="ended"}) end,
                ["navigation"] = {nil,11,nil,7},
                ["pointer"] = {},
                ["type"] = "button",
            },
            [10] = {
                ["creation"] = {x=280,y=300,text="Backward",font="fonts/BULKYPIX.TTF",fontSize=20},
                ["function"] = nil,
                ["navigation"] = {nil,nil,nil,nil},
                ["pointer"] = {},
                ["type"] = "text",
            },
            [11] = {
                ["creation"] = {x=520,y=300,
                    id="backward",    
                    label=lib.settings.tmpTable.controls.keybinds[lib.inputdevice.current.name].backward,
                    font="fonts/BULKYPIX.TTF",
                    fontSize=20,
                    onEvent=handleInteraction,
                    labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
                },
                ["function"] = function() scene:dispatchEvent({ name="interaction", target={id="backward"}, phase="ended"}) end,
                ["navigation"] = {nil,13,nil,9},
                ["pointer"] = {},
                ["type"] = "button",
            },
            [12] = {
                ["creation"] = {x=280,y=350,text="Jump",font="fonts/BULKYPIX.TTF",fontSize=20},
                ["function"] = nil,
                ["navigation"] = {nil,nil,nil,nil},
                ["pointer"] = {},
                ["type"] = "text",
            },
            [13] = {
                ["creation"] = {x=520,y=350,
                    id="jump",
                    label=lib.settings.tmpTable.controls.keybinds[lib.inputdevice.current.name].jump,
                    font="fonts/BULKYPIX.TTF",
                    fontSize=20,
                    onEvent=handleInteraction,
                    labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
                },
                ["function"] = function() scene:dispatchEvent({ name="interaction", target={id="jump"}, phase="ended"}) end,
                ["navigation"] = {nil,15,nil,11},
                ["pointer"] = {},
                ["type"] = "button",
            },
            [14] = {
                ["creation"] = {x=280,y=400,text="Sneak",font="fonts/BULKYPIX.TTF",fontSize=20},
                ["function"] = nil,
                ["navigation"] = {nil,nil,nil,nil},
                ["pointer"] = {},
                ["type"] = "text",
            },
            [15] = {
                ["creation"] = {x=520,y=400,
                    id="sneak",
                    label=lib.settings.tmpTable.controls.keybinds[lib.inputdevice.current.name].sneak,
                    font="fonts/BULKYPIX.TTF",
                    fontSize=20,
                    onEvent=handleInteraction,
                    labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
                },
                ["function"] = function() scene:dispatchEvent({ name="interaction", target={id="sneak"}, phase="ended"}) end,
                ["navigation"] = {nil,17,nil,13},
                ["pointer"] = {},
                ["type"] = "button",
            },
            [16] = {
                ["creation"] = {x=280,y=450,text="Primary Weapon",font="fonts/BULKYPIX.TTF",fontSize=20},
                ["function"] = nil,
                ["navigation"] = {nil,nil,nil,nil},
                ["pointer"] = {},
                ["type"] = "text",
            },
            [17] = {
                ["creation"] = {x=520,y=450,
                    id="primaryWeapon",
                    label=lib.settings.tmpTable.controls.keybinds[lib.inputdevice.current.name].primaryWeapon,
                    font="fonts/BULKYPIX.TTF",
                    fontSize=20,
                    onEvent=handleInteraction,
                    labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
                },
                ["function"] = function() scene:dispatchEvent({ name="interaction", target={id="primaryWeapon"}, phase="ended"}) end,
                ["navigation"] = {nil,19,nil,15},
                ["pointer"] = {},
                ["type"] = "button",
            },
            [18] = {
                ["creation"] = {x=280,y=500,text="Secondary Weapon",font="fonts/BULKYPIX.TTF",fontSize=20},
                ["function"] = nil,
                ["navigation"] = {nil,nil,nil,nil},
                ["pointer"] = {},
                ["type"] = "text",
            },
            [19] = {
                ["creation"] = {x=520,y=500,
                    id="secondaryWeapon",
                    label=lib.settings.tmpTable.controls.keybinds[lib.inputdevice.current.name].secondaryWeapon,
                    font="fonts/BULKYPIX.TTF",
                    fontSize=20,
                    onEvent=handleInteraction,
                    labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
                },
                ["function"] = function() scene:dispatchEvent({ name="interaction", target={id="secondaryWeapon"}, phase="ended"}) end,
                ["navigation"] = {nil,21,nil,17},
                ["pointer"] = {},
                ["type"] = "button",
            },
            [20] = {
                ["creation"] = {x=280,y=550,text="Block",font="fonts/BULKYPIX.TTF",fontSize=20},
                ["function"] = nil,
                ["navigation"] = {nil,nil,nil,nil},
                ["pointer"] = {},
                ["type"] = "text",
            },
            [21] = {
                ["creation"] = {x=520,y=550,
                    id="block",
                    label=lib.settings.tmpTable.controls.keybinds[lib.inputdevice.current.name].block,
                    font="fonts/BULKYPIX.TTF",
                    fontSize=20,
                    onEvent=handleInteraction,
                    labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
                },
                ["function"] = function() scene:dispatchEvent({ name="interaction", target={id="block"}, phase="ended"}) end,
                ["navigation"] = {nil,23,nil,19},
                ["pointer"] = {},
                ["type"] = "button",
            },
            [22] = {
                ["creation"] = {x=280,y=600,text="Ability",font="fonts/BULKYPIX.TTF",fontSize=20},
                ["function"] = nil,
                ["navigation"] = {nil,nil,nil,nil},
                ["pointer"] = {},
                ["type"] = "text",
            },
            [23] = {
                ["creation"] = {x=520,y=600,
                    id="ability",
                    label=lib.settings.tmpTable.controls.keybinds[lib.inputdevice.current.name].ability,
                    font="fonts/BULKYPIX.TTF",
                    fontSize=20,
                    onEvent=handleInteraction,
                    labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
                },
                ["function"] = function() scene:dispatchEvent({ name="interaction", target={id="ability"}, phase="ended"}) end,
                ["navigation"] = {nil,25,nil,21},
                ["pointer"] = {},
                ["type"] = "button",
            },
            [24] = {
                ["creation"] = {x=280,y=650,text="Inventory",font="fonts/BULKYPIX.TTF",fontSize=20},
                ["function"] = nil,
                ["navigation"] = {nil,nil,nil,nil},
                ["pointer"] = {},
                ["type"] = "text",
            },
            [25] = {
                ["creation"] = {x=520,y=650,
                    id="inventory",
                    label=lib.settings.tmpTable.controls.keybinds[lib.inputdevice.current.name].inventory,
                    font="fonts/BULKYPIX.TTF",
                    fontSize=20,
                    onEvent=handleInteraction,
                    labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
                },
                ["function"] = function() scene:dispatchEvent({ name="interaction", target={id="inventory"}, phase="ended"}) end,
                ["navigation"] = {nil,1,nil,23},
                ["pointer"] = {},
                ["type"] = "button",
            },
            [26] = {
                ["creation"] = {x=520,y=750,text="",font="fonts/BULKYPIX.TTF",fontSize=20},
                ["function"] = nil,
                ["navigation"] = {nil,nil,nil,nil},
                ["pointer"] = {},
                ["type"] = "text",
            },

        }

        scene:loadUI()
        scene:updateUI()

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
scene:addEventListener( "interaction", handleInteraction )

return scene