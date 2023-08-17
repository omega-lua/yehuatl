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
    print("check2")
    local currObject = scene.currObject
    for i,object in pairs(scene.referenceTable) do
        print("i:", i)
        print("currObj:", currObject)
        local params = {}
        if (i == currObject) then
            print("check3")
            handleScrollView(i,object)
            params = {time = 200, transition = easing.outQuint, xScale = 1.3, yScale = 1.3,}     
        else
            params = {time = 200, transition = easing.outQuint, xScale = 1, yScale = 1,}
        end
        transition.to(object, params)
    end
end


--------------------------------------------------------------------------
-- Jede Spalte ist ein groupOObject. jedes groupoject wird x,y angepasst. Jedoch ist es nicht mehr zentral, wenn sich die Breite des Groupobjects ändert (wenn man anderen Keybind abspeichert).
-- Vlt. sollte man irgendwie die Breite des Groupobjects/BreiteScrollView oder so, damit groupObject wirklich zentriert ist.
-------------------------------------------------------------------------
function scene:loadUI()
    local sceneGroup = scene.view

    scrollView = widget.newScrollView({
        id="scrollView",
        x = display.contentCenterX,
        y = display.contentCenterY,
        width = 600,
        height = 350,
        horizontalScrollDisabled = true,
        scrollWidth = 600,
        scrollHeight = 1200,
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

    textKeybinds = display.newText({
        text = "Keybinds",
        x = 180,
        y = 20,
        font = "fonts/BULKYPIX.TTF",
        fontSize = 28,
    })

    textCurrent = display.newText({
        text = "Current",
        x = 420,
        y = 20,
        font = "fonts/BULKYPIX.TTF",
        fontSize = 28,
    })

    scrollView:insert(textKeybinds)
    scrollView:insert(textCurrent)

    -----------
    groupEscape = display.newGroup()

    textKeybindEscape = display.newText({
        x = 150, 
        y = 100,
        text = "Escape",
        font = "fonts/BULKYPIX.TTF",
        fontSize = 20,
    })

    textKeybindEscapeCurrent = display.newText({
        x = 450,
        y = 100,
        text = tmpSettings.keybindEscape,
        font = "fonts/BULKYPIX.TTF",
        fontSize = 20,
    })

    scrollView:insert(textKeybindEscape)
    scrollView:insert(textKeybindEscapeCurrent)
    -----------

    textKeybindInteract = display.newText({
        x = 150,
        y = 150,
        text = "Interact",
        font = "fonts/BULKYPIX.TTF",
        fontSize = 20,
    })

    textKeybindInteractCurrent = display.newText({
        x = 450,
        y = 150,
        text = tmpSettings.keybindInteract,
        font = "fonts/BULKYPIX.TTF",
        fontSize = 20,
    })

    scrollView:insert(textKeybindInteract)
    scrollView:insert(textKeybindInteractCurrent)
    
    -----------

    textKeybindForward = display.newText({
        x = 150,
        y = 200,
        text = "Forward",
        font = "fonts/BULKYPIX.TTF",
        fontSize = 20,
    })

    textKeybindForwardCurrent = display.newText({
        x = 450,
        y = 200,
        text = "halohalohalohalo", --tmpSettings.keybindForward,
        font = "fonts/BULKYPIX.TTF",
        fontSize = 20,
    })

    scrollView:insert(textKeybindForward)
    scrollView:insert(textKeybindForwardCurrent)
    -----------

    textKeybindBackward = display.newText({
        x = 150,
        y = 250,
        text = "Backward",
        font = "fonts/BULKYPIX.TTF",
        fontSize = 20,
    })

    textKeybindBackwardCurrent = display.newText({
        x = 450,
        y = 250,
        text = tmpSettings.keybindBackward,
        font = "fonts/BULKYPIX.TTF",
        fontSize = 20,
    })

    scrollView:insert(textKeybindBackward)
    scrollView:insert(textKeybindBackwardCurrent)
    -----------

    textKeybindJump = display.newText({
        x = 150,
        y = 300,
        text = "Jump",
        font = "fonts/BULKYPIX.TTF",
        fontSize = 20,
    })

    textKeybindJumpCurrent = display.newText({
        x = 450,
        y = 300,
        text = tmpSettings.keybindJump,
        font = "fonts/BULKYPIX.TTF",
        fontSize = 20,
    })

    scrollView:insert(textKeybindJump)
    scrollView:insert(textKeybindJumpCurrent)

    -----------

    textKeybindSneak = display.newText({
        x = 150,
        y = 350,
        text = "Sneak",
        font = "fonts/BULKYPIX.TTF",
        fontSize = 20,
    })

    textKeybindSneakCurrent = display.newText({
        x = 450,
        y = 350,
        text = tmpSettings.keybindSneak,
        font = "fonts/BULKYPIX.TTF",
        fontSize = 20,
    })

    scrollView:insert(textKeybindSneak)
    scrollView:insert(textKeybindSneakCurrent)

    -----------

    textKeybindPrimaryWeapon = display.newText({
        x = 150,
        y = 400,
        text = "Primary Weapon",
        font = "fonts/BULKYPIX.TTF",
        fontSize = 20,
    })

    textKeybindPrimaryWeaponCurrent = display.newText({
        x = 450,
        y = 400,
        text = tmpSettings.keybindPrimaryWeapon,
        font = "fonts/BULKYPIX.TTF",
        fontSize = 20,
    })

    scrollView:insert(textKeybindPrimaryWeapon)
    scrollView:insert(textKeybindPrimaryWeaponCurrent)

    -----------

    textKeybindSecondaryWeapon = display.newText({
        x = 150,
        y = 450,
        text = "Secondary Weapon",
        font = "fonts/BULKYPIX.TTF",
        fontSize = 20,
    })

    textKeybindSecondaryWeaponCurrent = display.newText({
        x = 450,
        y = 450,
        text = tmpSettings.keybindSecondaryWeapon,
        font = "fonts/BULKYPIX.TTF",
        fontSize = 20,
    })

    scrollView:insert(textKeybindSecondaryWeapon)
    scrollView:insert(textKeybindSecondaryWeaponCurrent)

    -----------


    textKeybindBlock = display.newText({
        x = 150,
        y = 500,
        text = "Block",
        font = "fonts/BULKYPIX.TTF",
        fontSize = 20,
    })

    textKeybindBlockCurrent = display.newText({
        x = 450,
        y = 500,
        text = tmpSettings.keybindBlock,
        font = "fonts/BULKYPIX.TTF",
        fontSize = 20,
    })

    scrollView:insert(textKeybindBlock)
    scrollView:insert(textKeybindBlockCurrent)

    -----------

    textKeybindAbility = display.newText({
        x = 150,
        y = 550,
        text = "Ability",
        font = "fonts/BULKYPIX.TTF",
        fontSize = 20,
    })

    textKeybindAbilityCurrent = display.newText({
        x = 450,
        y = 550,
        text = tmpSettings.keybindAbility,
        font = "fonts/BULKYPIX.TTF",
        fontSize = 20,
    })

    scrollView:insert(textKeybindAbility)
    scrollView:insert(textKeybindAbilityCurrent)

    -----------

    textKeybindInventory = display.newText({
        x = 150,
        y = 600,
        text = "Inventory",
        font = "fonts/BULKYPIX.TTF",
        fontSize = 20,
    })

    textKeybindInventoryCurrent = display.newText({
        x = 450,
        y = 600,
        text = tmpSettings.keybindInventory,
        font = "fonts/BULKYPIX.TTF",
        fontSize = 20,
    })

    scrollView:insert(textKeybindInventory)
    scrollView:insert(textKeybindInventoryCurrent)

    ----------

    sceneGroup:insert(scrollView)
    sceneGroup:insert(buttonBack)
end
 
function scene:changeKeybind()
    --
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
 
-- create()
function scene:create( event )
 
    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen

    scene.currObject = 2
end
 
 
-- show()
function scene:show( event )
 
    local sceneGroup = self.view
    local phase = event.phase
    local parent = event.parent

 
    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)

        scene:loadUI()
        
        scene.widgetsTable = {
            [1] = {
                ["creation"] = {x,y,label},
                ["function"] = function() print("hi samurai") end,
                ["navigation"] = {1,2,3,4},
                ["pointer"] = {buttonBlabla},
                ["type"] = ["button"],
            },
            [2] = {
                ["creation"] = {x,y,label},
                ["function"] = function() print("hi samurai") end,
                ["navigation"] = {1,2,3,4},
                ["pointer"] = {buttonBlabla},
                ["type"] = ["button"],
            },
            [3] = {
                ["creation"] = {x,y,label},
                ["function"] = function() print("hi samurai") end,
                ["navigation"] = {1,2,3,4},
                ["pointer"] = {buttonBlabla},
                ["type"] = ["button"],
            },
            [4] = {
                ["creation"] = {x,y,label},
                ["function"] = function() print("hi samurai") end,
                ["navigation"] = {1,2,3,4},
                ["pointer"] = {buttonBlabla},
                ["type"] = ["button"],
            },
        }



        scene.matrix = {
            {2, 2, 2, 12},
            {nil, 3, nil, 1},
            {nil, 4, nil, 2},
            {nil, 5, nil, 3},
            {nil, 6, nil, 4},
            {nil, 7, nil, 5},
            {nil, 8, nil, 6},
            {nil, 9, nil, 7},
            {nil, 10, nil, 8},
            {nil, 11, nil, 9},
            {nil, 12, nil, 10},
            {nil, 1, nil, 11}

        }
        scene.referenceTable = {
            [1] = buttonBack,
            [2] = groupEscape,
            [3] = groupInteract,
            [4] = groupForward,
            [5] = groupBackward,
            [6] = groupJump,
            [7] = groupSneak,
            [8] = groupPrimaryWeapon,
            [9] = groupSecondaryWeapon,
            [10] = groupBlock,
            [11] = groupAbility,
            [12] = groupInventory,
        }

        scene.functionsTable = {
            [1] = "test"
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