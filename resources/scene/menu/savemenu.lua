-- Template from Solar2D-Guide: https://docs.coronalabs.com/guide/system/composer/index.html#template

local library = require("library")
local widget = require( "widget" )
local composer = require( "composer" )
local scene = composer.newScene()
 
-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

function scene:back()
    library.handleSceneChange("resources.scene.menu.mainmenu", "menu", { effect = "fade", time = 400,})
end

function scene:checkSaveFiles()
    -- Check if any savefiles are found -------------------------------------------------
    scene.save1 = doesFileExist( "save1.json", system.DocumentsDirectory)
    scene.save2 = doesFileExist( "save2.json", system.DocumentsDirectory)
    scene.save3 = doesFileExist( "save3.json", system.DocumentsDirectory)
end

function scene:hoverObj()
    local widgetIndex = scene.widgetIndex
    for i,widget in pairs(scene.widgetsTable) do
        local params = {}
        if (i == widgetIndex) then
            params = {time = 200, transition = easing.outQuint, xScale = 1.5, yScale = 1.5, alpha = 1} 
        else
            params = {time = 200, transition = easing.outQuint, xScale = 1, yScale = 1, alpha = 0.7}
        end
        -- Prevents alpha flickering
        transition.cancel(extendMenuTransitionAlpha)
        transition.to(widget.pointer, params)
    end
end

function scene:updateUI()
    
    -- Disable/Enable saveslot-buttons
    local widgetsTable = scene.widgetsTable
    print("scene.save1:", scene.save1)
    if scene.save1 then
        widgetsTable[2].pointer:setEnabled(true)
        widgetsTable[2].pointer:setLabel("Save 1")
    else
        widgetsTable[2].pointer:setEnabled(false)
        widgetsTable[2].pointer:setLabel("-")
    end

    if scene.save2 then
        widgetsTable[3].pointer:setEnabled(true)
        widgetsTable[3].pointer:setLabel("Save 2")
    else
        widgetsTable[3].pointer:setEnabled(false)
        widgetsTable[3].pointer:setLabel("-")
    end

    if scene.save3 then
        widgetsTable[4].pointer:setEnabled(true)
        widgetsTable[4].pointer:setLabel("Save 3")
    else
        widgetsTable[4].pointer:setEnabled(false)
        widgetsTable[4].pointer:setLabel("-")
    end

    -- update UI
    scene:hoverObj()
    scene:extendMenu()
end

local function fc1(filename)
    library.newSaveFile(filename)
    scene:checkSaveFiles()
    -- Switch to saveslot-button after press
    scene.widgetIndex = scene.widgetsTable[5].navigation[3]
    scene:updateUI()
end

local function fc2(filename)
    library.deleteFile(filename)
    scene:checkSaveFiles()
    -- Switch to saveslot-button after press
    scene.widgetIndex = scene.widgetsTable[5].navigation[3]
    scene:updateUI()
end

function scene:extendMenu()
    local widgetIndex = scene.widgetIndex
    local cancelTransition = false
    print(widgetIndex)
    if (widgetIndex == 2) then
        scene.array = {x=550,y=130,
            ["fc1"] = function() fc1("save1.json") end,
            ["fc2"] = function() fc2("save1.json") end,
            ["navigation"]={2,3,2,4},
            ["hasFile"]=scene.save1,
        }
    elseif (widgetIndex == 3) then
        scene.array = {x=550,y=200,
            ["fc1"] = function() fc1("save2.json") end,
            ["fc2"] = function() fc2("save2.json") end,
            ["navigation"]={3,4,3,2},
            ["hasFile"]=scene.save2,
        }
    elseif (widgetIndex == 4) then
        scene.array = {x=550,y=270,
            ["fc1"] = function() fc1("save3.json") end,
            ["fc2"] = function() fc2("save3.json") end,
            ["navigation"]={4,2,4,3},
            ["hasFile"]=scene.save3,
        }
    elseif (widgetIndex == 1) then
        scene.array = {x=-100,y=-100,
            ["fc1"] = nil,
            ["fc2"] = nil,
            ["navigation"]=nil,
        }
    elseif (widgetIndex == 5) then
        cancelTransition = true
    end

    local object = scene.widgetsTable[5]
    local array = scene.array
    object.navigation = array.navigation
    object.pointer.x, object.pointer.y, object.pointer.alpha = array.x, array.y, 0
    -- If file doesnt exist
    if array.hasFile then
        object.pointer:setLabel("Delete")
        object["function"] = array.fc2
    else
        object.pointer:setLabel("New")
        object["function"] = array.fc1
    end
    
    -- If widgetIndex is 5, then these animations will be skipped.
    if not cancelTransition then
        extendMenuTransitionX = transition.from( object.pointer,{ time=500, transition=easing.outCubic, x=array.x-100})
        -- From 0 alpha to 0.7
        extendMenuTransitionAlpha = transition.to( object.pointer,{ time=1500, transition=easing.outCubic, alpha=0.7} )
    end

end

local function handleButtonEvent(event)
    -- Kann man sehr wahrscheinlich schöner machen...
    if (event.phase == 'ended') then
        if (event.target.id == 'buttonBack') then
            local goTo = "resources.scene.menu.mainmenu"
            local sceneType = "menu"
            local options = { effect = "fade", time = 400,}
            library.handleSceneChange(goTo, sceneType, options)
            return false
        end

        if (event.target.id == 'buttonSaveSlot1') then
            currentSaveFile = "save1.json"
            library.handleSceneChange("resources.scene.game.game", "game",{ effect = "fade", time = 800,})
        elseif (event.target.id == 'buttonSaveSlot2') then
            currentSaveFile = "save2.json"
            library.handleSceneChange("resources.scene.game.game", "game",{ effect = "fade", time = 800,})
        elseif (event.target.id == 'buttonSaveSlot3') then
            currentSaveFile = "save3.json"
            library.handleSceneChange("resources.scene.game.game", "game",{ effect = "fade", time = 800,})
        end

        if (event.target.id == 'newSaveSlot1') then
            library.newSaveFile('save1.json')
            timer.performWithDelay( 30, refreshUI())
        elseif (event.target.id == 'newSaveSlot2') then
            library.newSaveFile('save2.json')
            timer.performWithDelay( 30, refreshUI())
        elseif (event.target.id == 'newSaveSlot3') then
            library.newSaveFile('save3.json')
            timer.performWithDelay( 30, refreshUI())
        elseif (event.target.id == 'deleteSaveSlot1') then
            library.deleteFile('save1.json')
            timer.performWithDelay( 30, refreshUI())
        elseif (event.target.id == 'deleteSaveSlot2') then
            library.deleteFile('save2.json')
            timer.performWithDelay( 30, refreshUI())
        elseif (event.target.id == 'deleteSaveSlot3') then
            library.deleteFile('save3.json')
            timer.performWithDelay( 30, refreshUI())
        end
    end
end

function scene:loadUI()
    local sceneGroup = scene.view

    -- Create widgets
    for i, object in pairs(scene.widgetsTable) do
        local type = object.type

        if (type == "text") then
            scene.widgetsTable[i].pointer = display.newText( object.creation )
            sceneGroup:insert(scene.widgetsTable[i].pointer)
            if object.color then
                scene.widgetsTable[i].pointer:setFillColor(unpack(object.color))
            end

        elseif (type == "line") then
            scene.widgetsTable[i].pointer = display.newLine(unpack(object.creation))
            sceneGroup:insert(scene.widgetsTable[i].pointer)
            if object.color then
                scene.widgetsTable[i].pointer:setStrokeColor(unpack(object.color))
            end
        
        elseif (type == "button") then
            scene.widgetsTable[i].pointer = widget.newButton( object.creation )
            sceneGroup:insert(scene.widgetsTable[i].pointer)

        elseif (type == nil) then
            print("ERROR: Widget",i,"has no type attribute.")
        end
    end
end


-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
 
-- create()
function scene:create( event )
    -- Code here runs when the scene is first created but has not yet appeared on screen
    
    scene.widgetsTable = {
        [1] = {
            ["creation"] = {
                x = 50,
                y = 50,
                id = "buttonBack",
                label = "back",
                onEvent = handleButtonEvent,
                font = "fonts/BULKYPIX.TTF",
                fontSize = 25,
                labelColor = { default={ 1, 1, 1 }, over={ 1, 1, 1, 0.5 } }
            },
            ["function"] = function() scene:back() end,
            ["navigation"] = {2,2,2,4},
            ["pointer"] = {},
            ["type"] = "button",
        },
        [2] = {
            ["creation"] = {
                x = 400,
                y = 130,
                id = "buttonSaveSlot1",
                label = "Save 1",
                onEvent = handleButtonEvent,
                font = "fonts/BULKYPIX.TTF",
                fontSize = 20,
                labelColor = { default={ 1, 1, 1 }, over={ 1, 1, 1, 0.5 } }
            },
            ["function"] = "",
            ["navigation"] = {5,3,1,1},
            ["pointer"] = {},
            ["type"] = "button",
        },
        [3] = {
            ["creation"] = {
                x = 400,
                y = 200,
                id = "buttonSaveSlot2",
                label = "Save 2",
                onEvent = handleButtonEvent,
                font = "fonts/BULKYPIX.TTF",
                fontSize = 20,
                labelColor = { default={ 1, 1, 1 }, over={ 1, 1, 1, 0.5 } }
            },
            ["function"] = "",
            ["navigation"] = {5,4,1,2},
            ["pointer"] = {},
            ["type"] = "button",
        },
        [4] = {
            ["creation"] = {
                x = 400,
                y = 270,
                id = "buttonSaveSlot3",
                label = "Save 3",
                onEvent = handleButtonEvent,
                font = "fonts/BULKYPIX.TTF",
                fontSize = 20,
                labelColor = { default={ 1, 1, 1 }, over={ 1, 1, 1, 0.5 } }
            },
            ["function"] = "",
            ["navigation"] = {5,2,1,3},
            ["pointer"] = {},
            ["type"] = "button",
        },
        [5] = {
            ["creation"] = {
                x = 550,
                y = 130,
                id = "buttonInteract",
                label = "interact",
                onEvent = handleButtonEvent,
                font = "fonts/BULKYPIX.TTF",
                fontSize = 20,
                labelColor = { default={ 1, 1, 1 }, over={ 1, 1, 1, 0.5 } }
            },
            ["function"] = nil,
            ["navigation"] = {},
            ["pointer"] = {},
            ["type"] = "button",
        },
    }

    scene.widgetIndex = 2

    scene:checkSaveFiles()
    scene:loadUI()
    scene:updateUI()
end
 
 
-- show()
function scene:show( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)
        
        -- Skip the savemenu-Interface
        if (scene.save1==false) and (scene.save2==false) and (scene.save3==false) then
            print("no savefiles found")
            -- Set var to nil if no savefiles are available
            currentSaveFile = nil
            local options = {effect = "fade", time = 500,}
            composer.gotoScene("resources.scene.game.game", options)
            return
        end

        scene.widgetIndex = 2

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
 
return scene