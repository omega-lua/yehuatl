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

function scene:extend()
    local widgetIndex = scene.widgetIndex
    local array = nil

    if (widgetIndex == 2) then
        array = {x=550,y=130,
            ["fc1"]= function() print("save1, fc1") end,
            ["fc2"]= function() print("save1, fc2") end,
            ["navigation"]={2,3,2,4},
            ["hasFile"]=scene.save1,
        }

    elseif (widgetIndex == 3) then
        array = {x=550,y=200,
            ["fc1"]= function() print("save2, fc1") end,
            ["fc2"]= function() print("save2, fc2") end,
            ["navigation"]={3,4,3,2},
            ["hasFile"]=scene.save2,
        }

    elseif (widgetIndex == 4) then
        array = {x=550,y=270,
            ["fc1"]= function() print("save3, fc1") end,
            ["fc2"]= function() print("save3, fc2") end,
            ["navigation"]={4,2,4,3},
            ["hasFile"]=scene.save3,
        }

    elseif (widgetIndex == 1) then
        array = {x=-100,y=-100,
            ["fc1"]= nil,
            ["fc2"]= nil,
            ["navigation"]=nil,
        }
    else
        return
    end

    local object = scene.widgetsTable[5].pointer
    library.printTable(object)
    scene.widgetsTable[5].navigation = array.navigation
    object.x, object.y = array.x, array.y
    -- If file doesnt exist
    if array.hasFile then
        object:setLabel("Delete")
        scene.widgetsTable[5]["function"] = array.fc2
    else
        object:setLabel("New")
        scene.widgetsTable[5]["function"] = array.fc1
    end
end

function scene:hoverObj()
    local widgetIndex = scene.widgetIndex
    for i,widget in pairs(scene.widgetsTable) do
        local params = {}
        if (i == widgetIndex) then
            params = {time = 200, transition = easing.outQuint, xScale = 1.5, yScale = 1.5, alpha = 1} 
            scene:checkSaveFiles()
            scene:extend()
        else
            params = {time = 200, transition = easing.outQuint, xScale = 1, yScale = 1, alpha = 0.7}
        end
        transition.to(widget.pointer, params)
    end
end

local function refreshUI()
    -- Check if any savefiles are found -------------------------------------------------
    local save1 = doesFileExist( "save1.json", system.DocumentsDirectory)
    local save2 = doesFileExist( "save2.json", system.DocumentsDirectory)
    local save3 = doesFileExist( "save3.json", system.DocumentsDirectory)

    if (save1 == false) then
        buttonSaveSlot1:setEnabled( false )
        buttonSaveSlot1:setLabel( "" )

        -- Disable delete button, because there is nothing to delete
        deleteSaveSlot1:setEnabled( false )
        deleteSaveSlot1:setLabel( "" )

        -- enable new button, because there is nothing to load
        newSaveSlot1:setEnabled( true )
        newSaveSlot1:setLabel( "new" )
    else
        buttonSaveSlot1:setEnabled( true )
        buttonSaveSlot1:setLabel( "Save 1" )
        
        deleteSaveSlot1:setEnabled( true )
        deleteSaveSlot1:setLabel( "delete" )
        
        newSaveSlot1:setEnabled( false )
        newSaveSlot1:setLabel( "" )
    end
    
    if (save2 == false) then
        buttonSaveSlot2:setEnabled( false )
        buttonSaveSlot2:setLabel( "" )

        -- Disable delete button, because there is nothing to delete
        deleteSaveSlot2:setEnabled( false )
        deleteSaveSlot2:setLabel( "" )

        -- enable new button, because there is nothing to load
        newSaveSlot2:setEnabled( true )
        newSaveSlot2:setLabel( "new" )
    else
        buttonSaveSlot2:setEnabled( true )
        buttonSaveSlot2:setLabel( "Save 2" )
        
        deleteSaveSlot2:setEnabled( true )
        deleteSaveSlot2:setLabel( "delete" )
        
        newSaveSlot2:setEnabled( false )
        newSaveSlot2:setLabel( "" )
    end

    if (save3 == false) then
        buttonSaveSlot3:setEnabled( false )
        buttonSaveSlot3:setLabel( "" )

        -- Disable delete button, because there is nothing to delete
        deleteSaveSlot3:setEnabled( false )
        deleteSaveSlot3:setLabel( "" )

        -- enable new button, because there is nothing to load
        newSaveSlot3:setEnabled( true )
        newSaveSlot3:setLabel( "new" )
    else
        buttonSaveSlot3:setEnabled( true )
        buttonSaveSlot3:setLabel( "Save 3" )
        
        deleteSaveSlot3:setEnabled( true )
        deleteSaveSlot3:setLabel( "delete" )
        
        newSaveSlot3:setEnabled( false )
        newSaveSlot3:setLabel( "" )
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


local function loadUI_OLD() 
    -- Check if any savefiles are found -------------------------------------------------
    save1 = doesFileExist( "save1.json", system.DocumentsDirectory)
    save2 = doesFileExist( "save2.json", system.DocumentsDirectory)
    save3 = doesFileExist( "save3.json", system.DocumentsDirectory)

    -- Skip the savemenu-Interface
    if (save1==false) and (save2==false) and (save3==false) then
        print("no savefiles found")
        -- Set var to nil if no savefiles are available
        currentSaveFile = nil
        local options = {effect = "fade", time = 500,}
        composer.gotoScene("resources.scene.game.game", options)
        return
    end

    -- Setup the buttons ----------------------------------------------------------------
    local sceneGroup = scene.view

    -- button for loading save1.json
    buttonSaveSlot1 = widget.newButton({
        x = display.contentCenterX*1.8,
        y = display.contentCenterY*0.6,
        id = "buttonSaveSlot1",
        label = "Save 1",
        onEvent = handleButtonEvent,
        font = "fonts/BULKYPIX.TTF",
        fontSize = 25,
        labelColor = { default={ 255, 255, 255, 1}}
    })

    -- button for loading save2.json
    buttonSaveSlot2 = widget.newButton({
        x = display.contentCenterX*1.8,
        y = display.contentCenterY*1,
        id = "buttonSaveSlot2",
        label = "Save 2",
        onEvent = handleButtonEvent,
        font = "fonts/BULKYPIX.TTF",
        fontSize = 25,
        labelColor = { default={ 255, 255, 255, 1 }},
        })
       

    -- button for loading save3.json
    buttonSaveSlot3 = widget.newButton({
        x = display.contentCenterX*1.8,
        y = display.contentCenterY*1.4,
        id = "buttonSaveSlot3",
        label = "Save 3",
        onEvent = handleButtonEvent,
        font = "fonts/BULKYPIX.TTF",
        fontSize = 25,
        labelColor = { default={ 255, 255, 255, 1 }},
    })

    newSaveSlot1 = widget.newButton({
        x = display.contentCenterX*1.4,
        y = display.contentCenterY*0.6,
        id = "newSaveSlot1",
        label = "new",
        onEvent = handleButtonEvent,
        font = "fonts/BULKYPIX.TTF",
        fontSize = 25,
        labelColor = { default={ 255, 255, 255, 1 }},
    })

    newSaveSlot2 = widget.newButton({
        x = display.contentCenterX*1.4,
        y = display.contentCenterY*1,
        id = "newSaveSlot2",
        label = "new",
        onEvent = handleButtonEvent,
        font = "fonts/BULKYPIX.TTF",
        fontSize = 25,
        labelColor = { default={ 255, 255, 255, 1 }},
    })

    newSaveSlot3 = widget.newButton({
        x = display.contentCenterX*1.4,
        y = display.contentCenterY*1.4,
        id = "newSaveSlot3",
        label = "new",
        onEvent = handleButtonEvent,
        font = "fonts/BULKYPIX.TTF",
        fontSize = 25,
        labelColor = { default={ 255, 255, 255, 1 }},
    })

    deleteSaveSlot1 = widget.newButton({
        x = display.contentCenterX*1,
        y = display.contentCenterY*0.6,
        id = "deleteSaveSlot1",
        label = "delete",
        onEvent = handleButtonEvent,
        font = "fonts/BULKYPIX.TTF",
        fontSize = 25,
        labelColor = { default={ 255, 255, 255, 1 }},
    })

    deleteSaveSlot2 = widget.newButton({
        x = display.contentCenterX*1,
        y = display.contentCenterY*1,
        id = "deleteSaveSlot2",
        label = "delete",
        onEvent = handleButtonEvent,
        font = "fonts/BULKYPIX.TTF",
        fontSize = 25,
        labelColor = { default={ 255, 255, 255, 1 }},
    })


    deleteSaveSlot3 = widget.newButton({
        x = display.contentCenterX*1,
        y = display.contentCenterY*1.4,
        id = "deleteSaveSlot3",
        label = "delete",
        onEvent = handleButtonEvent,
        font = "fonts/BULKYPIX.TTF",
        fontSize = 25,
        labelColor = { default={ 255, 255, 255, 1 }},
    })

    -- Back button
    buttonBack = widget.newButton({
        x = display.contentCenterX*0.1,
        y = display.contentCenterY*0.2,
        id = "buttonBack",
        label = "Back",
        onEvent = handleButtonEvent,
        font = "fonts/BULKYPIX.TTF",
        fontSize = 30,
        labelColor = { default={ 255, 255, 255, 1 }},
    })

    sceneGroup:insert( buttonSaveSlot1 )
    sceneGroup:insert( buttonSaveSlot2 )
    sceneGroup:insert( buttonSaveSlot3 )
    sceneGroup:insert( deleteSaveSlot1 )
    sceneGroup:insert( deleteSaveSlot2 )
    sceneGroup:insert( deleteSaveSlot3 )
    sceneGroup:insert( newSaveSlot1 )
    sceneGroup:insert( newSaveSlot2 )
    sceneGroup:insert( newSaveSlot3 )
    sceneGroup:insert( buttonBack )
end


-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
 
-- create()
function scene:create( event )
    -- Code here runs when the scene is first created but has not yet appeared on screen
    
    scene.widgetIndex = 2
end
 
 
-- show()
function scene:show( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)
        
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

        scene:checkSaveFiles()
        scene:loadUI()
        scene:extend()

 
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