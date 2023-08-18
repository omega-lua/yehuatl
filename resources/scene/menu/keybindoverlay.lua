local composer = require( "composer" )
local widget = require( "widget" )
local library = require("library")

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
        delay = 00,
        alpha = 0
    }
    
    toast:setFillColor(0, 255, 0)
    transition.to(toast, params)
end

local function handleScrollView(i,o)     
    --local m, n = scrollView:getContentPosition()
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

function scene:handleKeybindChange()
    --
end

function scene:setKeybind(keybind, keyName)
    tmpSettings.keybind = keyName
end

function scene:loadUI()
    local sceneGroup = scene.view

    scrollView = widget.newScrollView({
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
    for i, widget in pairs(scene.widgetsTable) do
        local type = widget.type
        if (type == "text") then
            scene.widgetsTable[i].pointer = display.newText( widget.creation )
            scrollView:insert(scene.widgetsTable[i].pointer)
        elseif (type == "button") then
            --
        end
    end

    sceneGroup:insert(scrollView)
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
 
-- create()
function scene:create( event )
 
    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen

    scene.currObject = 1
end
 
 
-- show()
function scene:show( event )
 
    local sceneGroup = self.view
    local phase = event.phase
    local parent = event.parent

 
    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)
        
        runtime.currentScene = scene
        runtime.currentSceneType = "menu"
        scene.widgetsTable = {
            [1] = {
                ["creation"] = {x=50,y=display.contentCenterY*0.2,text="back",font="fonts/BULKYPIX.TTF",fontSize=20,},
                ["function"] = function() scene:hideOverlay() end,
                ["navigation"] = {nil,5,nil,25},
                ["pointer"] = {},
                ["type"] = "text",
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
                ["creation"] = {x=520,y=150,text=tmpSettings.keybindEscape,font="fonts/BULKYPIX.TTF",fontSize=20},
                ["function"] = function() scene:changeKeybind() end,
                ["navigation"] = {nil,7,nil,1},
                ["pointer"] = {},
                ["type"] = "text",
            },
            [6] = {
                ["creation"] = {x=280,y=200,text="Interact",font="fonts/BULKYPIX.TTF",fontSize=20},
                ["function"] = nil,
                ["navigation"] = {nil,nil,nil,nil},
                ["pointer"] = {},
                ["type"] = "text",
            },
            [7] = {
                ["creation"] = {x=520,y=200,text=tmpSettings.keybindInteract,font="fonts/BULKYPIX.TTF",fontSize=20},
                ["function"] = function() scene:changeKeybind() end,
                ["navigation"] = {nil,9,nil,5},
                ["pointer"] = {},
                ["type"] = "text",
            },
            [8] = {
                ["creation"] = {x=280,y=250,text="Forward",font="fonts/BULKYPIX.TTF",fontSize=20},
                ["function"] = nil,
                ["navigation"] = {nil,nil,nil,nil},
                ["pointer"] = {},
                ["type"] = "text",
            },
            [9] = {
                ["creation"] = {x=520,y=250,text=tmpSettings.keybindForward,font="fonts/BULKYPIX.TTF",fontSize=20},
                ["function"] = function() scene:changeKeybind() end,
                ["navigation"] = {nil,11,nil,7},
                ["pointer"] = {},
                ["type"] = "text",
            },
            [10] = {
                ["creation"] = {x=280,y=300,text="Backward",font="fonts/BULKYPIX.TTF",fontSize=20},
                ["function"] = nil,
                ["navigation"] = {nil,nil,nil,nil},
                ["pointer"] = {},
                ["type"] = "text",
            },
            [11] = {
                ["creation"] = {x=520,y=300,text=tmpSettings.keybindBackward,font="fonts/BULKYPIX.TTF",fontSize=20},
                ["function"] = function() scene:changeKeybind() end,
                ["navigation"] = {nil,13,nil,9},
                ["pointer"] = {},
                ["type"] = "text",
            },
            [12] = {
                ["creation"] = {x=280,y=350,text="Jump",font="fonts/BULKYPIX.TTF",fontSize=20},
                ["function"] = nil,
                ["navigation"] = {nil,nil,nil,nil},
                ["pointer"] = {},
                ["type"] = "text",
            },
            [13] = {
                ["creation"] = {x=520,y=350,text=tmpSettings.keybindJump,font="fonts/BULKYPIX.TTF",fontSize=20},
                ["function"] = function() scene:changeKeybind() end,
                ["navigation"] = {nil,15,nil,11},
                ["pointer"] = {},
                ["type"] = "text",
            },
            [14] = {
                ["creation"] = {x=280,y=400,text="Sneak",font="fonts/BULKYPIX.TTF",fontSize=20},
                ["function"] = nil,
                ["navigation"] = {nil,nil,nil,nil},
                ["pointer"] = {},
                ["type"] = "text",
            },
            [15] = {
                ["creation"] = {x=520,y=400,text=tmpSettings.keybindSneak,font="fonts/BULKYPIX.TTF",fontSize=20},
                ["function"] = function() scene:changeKeybind() end,
                ["navigation"] = {nil,17,nil,13},
                ["pointer"] = {},
                ["type"] = "text",
            },
            [16] = {
                ["creation"] = {x=280,y=450,text="Primary Weapon",font="fonts/BULKYPIX.TTF",fontSize=20},
                ["function"] = nil,
                ["navigation"] = {nil,nil,nil,nil},
                ["pointer"] = {},
                ["type"] = "text",
            },
            [17] = {
                ["creation"] = {x=520,y=450,text=tmpSettings.keybindPrimaryWeapon,font="fonts/BULKYPIX.TTF",fontSize=20},
                ["function"] = function() scene:changeKeybind() end,
                ["navigation"] = {nil,19,nil,15},
                ["pointer"] = {},
                ["type"] = "text",
            },
            [18] = {
                ["creation"] = {x=280,y=500,text="Secondary Weapon",font="fonts/BULKYPIX.TTF",fontSize=20},
                ["function"] = nil,
                ["navigation"] = {nil,nil,nil,nil},
                ["pointer"] = {},
                ["type"] = "text",
            },
            [19] = {
                ["creation"] = {x=520,y=500,text=tmpSettings.keybindSecondaryWeapon,font="fonts/BULKYPIX.TTF",fontSize=20},
                ["function"] = function() scene:changeKeybind() end,
                ["navigation"] = {nil,21,nil,17},
                ["pointer"] = {},
                ["type"] = "text",
            },
            [20] = {
                ["creation"] = {x=280,y=550,text="Block",font="fonts/BULKYPIX.TTF",fontSize=20},
                ["function"] = nil,
                ["navigation"] = {nil,nil,nil,nil},
                ["pointer"] = {},
                ["type"] = "text",
            },
            [21] = {
                ["creation"] = {x=520,y=550,text=tmpSettings.keybindBlock,font="fonts/BULKYPIX.TTF",fontSize=20},
                ["function"] = function() scene:changeKeybind() end,
                ["navigation"] = {nil,23,nil,19},
                ["pointer"] = {},
                ["type"] = "text",
            },
            [22] = {
                ["creation"] = {x=280,y=600,text="Ability",font="fonts/BULKYPIX.TTF",fontSize=20},
                ["function"] = nil,
                ["navigation"] = {nil,nil,nil,nil},
                ["pointer"] = {},
                ["type"] = "text",
            },
            [23] = {
                ["creation"] = {x=520,y=600,text=tmpSettings.keybindAbility,font="fonts/BULKYPIX.TTF",fontSize=20},
                ["function"] = function() scene:changeKeybind() end,
                ["navigation"] = {nil,25,nil,21},
                ["pointer"] = {},
                ["type"] = "text",
            },
            [24] = {
                ["creation"] = {x=280,y=650,text="Inventory",font="fonts/BULKYPIX.TTF",fontSize=20},
                ["function"] = nil,
                ["navigation"] = {nil,nil,nil,nil},
                ["pointer"] = {},
                ["type"] = "text",
            },
            [25] = {
                ["creation"] = {x=520,y=650,text=tmpSettings.keybindInventory,font="fonts/BULKYPIX.TTF",fontSize=20},
                ["function"] = function() scene:changeKeybind() end,
                ["navigation"] = {nil,27,nil,23},
                ["pointer"] = {},
                ["type"] = "text",
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
        parent:hideOverlay()
 
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
 
return scene