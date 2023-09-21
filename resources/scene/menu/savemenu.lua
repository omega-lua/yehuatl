-- Template from Solar2D-Guide: https://docs.coronalabs.com/guide/system/composer/index.html#template

local lib = require( "resources.lib.lib" )
local widget = require( "widget" )
local composer = require( "composer" )
local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Scene variables
-- -----------------------------------------------------------------------------------

scene.type = "menu"
scene.widgetIndex = nil
scene.animation = {}
scene.save1 = nil
scene.save2 = nil
scene.save3 = nil

-- -----------------------------------------------------------------------------------
-- Scene functions
-- -----------------------------------------------------------------------------------

function scene:back()
    lib.scene.show("resources.scene.menu.mainmenu", { effect = "fade", time = 400,})
end

function scene:checkSaveFiles()
    -- Check if any savefiles are found -------------------------------------------------
    local doesExist = lib.file.doesExist
    scene.save1 = doesExist( "save1.json", system.DocumentsDirectory)
    scene.save2 = doesExist( "save2.json", system.DocumentsDirectory)
    scene.save3 = doesExist( "save3.json", system.DocumentsDirectory)
end

function scene:hoverObj()
    local widgetIndex = scene.widgetIndex
    for i,widget in pairs(scene.widgetsTable) do
        local params = {}
        if (i == widgetIndex) then
            params = {time = 200, transition = easing.outQuint, xScale = 1.5, yScale = 1.5, alpha = 1} 
        else
            if (i == 5) then
                params = {time = 200, transition = easing.outQuint, xScale = 1, yScale = 1}
            else
                params = {time = 200, transition = easing.outQuint, xScale = 1, yScale = 1, alpha = 0.7}
            end
        end
        transition.to(widget.pointer, params)
    end
end

function scene:updateSaveSlots()
    -- Disable/Enable saveslot-buttons
    local object = scene.widgetsTable[2].pointer
    if scene.save1 then
        object:setEnabled(true)
        object:setLabel("Save 1")
    else
        object:setEnabled(false)
        object:setLabel("-")
    end
    
    local object = scene.widgetsTable[3].pointer
    if scene.save2 then
        object:setEnabled(true)
        object:setLabel("Save 2")
    else
        object:setEnabled(false)
        object:setLabel("-")
    end

    local object = scene.widgetsTable[4].pointer
    if scene.save3 then
        object:setEnabled(true)
        object:setLabel("Save 3")
    else
        object:setEnabled(false)
        object:setLabel("-")
    end
end

function scene:manageButtonFunction(filename, label)
    print(filename,label)
    -- Gets opened when manageButton gets pressed
    if (label == 'Create') then
        lib.savefile.new(filename)

    elseif (label == 'Delete') then
        lib.file.delete(filename)
    else
        return
    end
    -- Switch to saveslot-button after press
    scene.widgetIndex = scene.widgetsTable[5].navigation[3]
    scene:checkSaveFiles()
    scene:updateSaveSlots()
    scene:updateUI()
end

function scene:updateManageButton()
    -- Localize
    local index = scene.widgetIndex
    local widget = scene.widgetsTable[5]
    local button = widget.pointer
    local filename, label = nil, button:getLabel() or nil
    local navigation = widget.navigation or {}
    
    if (index == 2) then
        -- set navigation array
        navigation = {2,3,2,4}
        -- set filename and label
        filename = 'save1.json'
        print("scene.save1:", scene.save1)
        if scene.save1 then label = 'Delete' else label = 'Create' end
        -- move button to correct position
        button.x, button.y, button.alpha = 550, 130, 0
    
    elseif (index == 3) then
        -- set navigation array
        navigation = {3,4,3,2}
        -- set filename and label
        filename = 'save2.json'
        if scene.save2 then label = 'Delete' else label = 'Create' end
        -- move button to correct position
        button.x, button.y, button.alpha = 550, 200, 0
    
    elseif (index == 4) then
        -- set navigation array
        navigation = {4,2,4,3}
        -- set filename and label
        filename = 'save3.json'
        if scene.save3 then label = 'Delete' else label = 'Create' end
        -- move button to correct position
        button.x, button.y, button.alpha = 550, 270, 0
    elseif (index == 5) then
        return
    else
        button.x, button.y = -1000, -1000
        return
    end
    
    widget["navigation"] = navigation
    widget["function"] = function() scene:manageButtonFunction(filename, label) end
    button:setLabel(label)

    -- animation
    scene.animation.tranisitionFromX = transition.from( button,{ time=600, transition=easing.outCubic, x=button.x-100})
    scene.animation.transitionAlpha = transition.to( button,{ time=250, transition=easing.inCirc, alpha=0.7} )
end

function scene:updateUI()
    scene:updateManageButton()
    scene:hoverObj()
end

local function handleInteraction(event)
    if (event.phase == 'ended') then
        local id = event.target.id
        if (id == 'buttonBack') then
            lib.scene.show("resources.scene.menu.mainmenu", {effect = "fade", time = 400})
            return false

        elseif (id == 'buttonSave1') then
            if scene.save1 then
                lib.savefile.current = 'save1.json'
                lib.scene.show("resources.scene.game.game", {effect = "fade", time = 1200})
            end
        elseif (id == 'buttonSave2') then
            if scene.save2 then
                lib.savefile.current = 'save2.json'
                lib.scene.show("resources.scene.game.game", {effect = "fade", time = 1200})
            end
        elseif (id == 'buttonSave3') then
            if scene.save3 then
                lib.savefile.current = 'save3.json'
                lib.scene.show("resources.scene.game.game", { effect = "fade", time = 1200})
            end
        elseif (id == 'buttonManage') then
            --
        end
    end
end

function scene:loadUI()
    local sceneGroup = scene.view

    scene.widgetsTable = {
        [1] = {
            ["creation"] = {
                x = 50,
                y = 50,
                id = "buttonBack",
                label = "back",
                onEvent = handleInteraction,
                font = "fonts/BULKYPIX.TTF",
                fontSize = 25,
                labelColor = { default={ 1, 1, 1 }, over={ 1, 1, 1, 0.5 } }
            },
            ["function"] = function() scene:dispatchEvent({ name="interaction", target={id="buttonBack"}, phase="ended"}) end,
            ["navigation"] = {2,2,2,4},
            ["pointer"] = {},
            ["type"] = "button",
        },
        [2] = {
            ["creation"] = {
                x = 400,
                y = 130,
                id = "buttonSave1",
                label = "Save 1",
                onEvent = handleInteraction,
                font = "fonts/BULKYPIX.TTF",
                fontSize = 20,
                labelColor = { default={ 1, 1, 1 }, over={ 1, 1, 1, 0.5 } }
            },
            ["function"] = function() scene:dispatchEvent({ name="interaction", target={id="buttonSave1"}, phase="ended"}) end,
            ["navigation"] = {5,3,1,1},
            ["pointer"] = {},
            ["type"] = "button",
        },
        [3] = {
            ["creation"] = {
                x = 400,
                y = 200,
                id = "buttonSave2",
                label = "Save 2",
                onEvent = handleInteraction,
                font = "fonts/BULKYPIX.TTF",
                fontSize = 20,
                labelColor = { default={ 1, 1, 1 }, over={ 1, 1, 1, 0.5 } }
            },
            ["function"] = function() scene:dispatchEvent({ name="interaction", target={id="buttonSave2"}, phase="ended"}) end,
            ["navigation"] = {5,4,1,2},
            ["pointer"] = {},
            ["type"] = "button",
        },
        [4] = {
            ["creation"] = {
                x = 400,
                y = 270,
                id = "buttonSave3",
                label = "Save 3",
                onEvent = handleInteraction,
                font = "fonts/BULKYPIX.TTF",
                fontSize = 20,
                labelColor = { default={ 1, 1, 1 }, over={ 1, 1, 1, 0.5 } }
            },
            ["function"] = function() scene:dispatchEvent({ name="interaction", target={id="buttonSave3"}, phase="ended"}) end,
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

    scene.widgetIndex = 2
    scene:loadUI()
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
            lib.savefile.current = nil
            local options = {effect = "fade", time = 500,}
            composer.gotoScene("resources.scene.game.game", options)
            return
        end

        scene.widgetIndex = 2

        scene:checkSaveFiles()
        scene:updateSaveSlots()
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