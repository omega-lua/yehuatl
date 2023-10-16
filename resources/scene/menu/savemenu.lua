-- -----------------------------------------------------------------------------------
-- Localize
-- -----------------------------------------------------------------------------------

local lib = require( "resources.lib.lib" )
local widget = require( "widget" )
local composer = require( "composer" )
local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Scene variables
-- -----------------------------------------------------------------------------------

scene.type = "menu"
scene.widgetIndex = nil
scene.save = {}

scene._selected = nil
scene._indexOfSelected = nil

-- -----------------------------------------------------------------------------------
-- Scene functions
-- -----------------------------------------------------------------------------------

function scene:back()
    lib.scene.show("resources.scene.menu.mainmenu", { effect = "fade", time = 400,})
end

function scene:checkSaveFiles()
    -- Check if any savefiles are present --------------------------------------------
    local doesExist = lib.file.doesExist
    local t = {}
    scene.save[1] = doesExist( "savefile1.json", system.DocumentsDirectory)
    scene.save[2] = doesExist( "savefile2.json", system.DocumentsDirectory)
    scene.save[3] = doesExist( "savefile3.json", system.DocumentsDirectory)
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
    local object = scene.widgetsTable[2].pointer
    local a = 0.4
    if scene.save[1] then a = 1 end
    transition.to(object, {time = 600, transition = easing.outQuint, alpha = a})
    
    local object = scene.widgetsTable[3].pointer
    local a = 0.4
    if scene.save[2] then a = 1 end
    transition.to(object, {time = 600, transition = easing.outQuint, alpha = a})

    local object = scene.widgetsTable[4].pointer
    local a = 0.4
    if scene.save[3] then a = 1 end
    transition.to(object, {time = 600, transition = easing.outQuint, alpha = a})
end

function scene:redirect()
    if (scene.save1==false) and (scene.save2==false) and (scene.save3==false) then
        lib.savefile.new()
        lib.savefile.current.name = "savefile1.json"
        lib.level.load()
    end
end

function scene:fcButton(t)
    local selected = t.selected -- currently selected savefile/-slot (1,2 or 3)
    local update = t.update -- when updateUI() gets called while using key-control
    local index = scene.widgetIndex

    local function manageSaveSlot(i, filename)
        local label = nil
        local button = scene.widgetsTable[5].pointer 

        if scene.save[i] then
            lib.file.delete(filename)
            label = 'Create'
        else
            lib.savefile.new(filename)
            label = 'Delete'
        end

        scene:checkSaveFiles()
        scene:updateSaveSlots()
        button:setLabel(label)

        -- Only important for key-control
        if lib.control.mode == 'key' then
            scene.widgetIndex = i+1
            scene:hoverObj()
        end
    end

    local function showButton(selected)
        local x, y, fc, label = nil, nil, nil, 'Create'
        local nav = nil -- nav(igation)
        local filename = nil
        local widget = scene.widgetsTable[5]
        local button = widget.pointer
        local control = lib.control

        if selected == 1 then
            if control.mode == 'key' then nav = {2,3,2,4} end
            if scene.save[1] then label = 'Delete' end
            filename = 'savefile1.json'
            button.x, button.y = 570, 130

        elseif selected == 2 then
            if control.mode == 'key' then nav = {3,4,3,2} end
            if scene.save[2] then label = 'Delete' end
            filename = 'savefile2.json'
            button.x, button.y = 570, 200

        elseif selected == 3 then
            if control.mode == 'key' then nav = {4,2,4,3} end
            if scene.save[3] then label = 'Delete' end
            filename = 'savefile3.json'
            button.x, button.y = 570, 270

        else
            if control.mode == 'key' then
                button.x, button.y = -1500, -1500
            end
        end

        -- Change button label and alpha
        button:setLabel(label)
        button.alpha = 0

        -- Change only when control.mode is "key"
        if control.mode == 'key' then
            -- Change navigation of manage button
            widget["navigation"] = nav
        end

        -- Change button function
        widget['function'] = function() manageSaveSlot(selected, filename) end

        -- Animation
        local tranisitionFromX = transition.from( button,{time=600, transition=easing.outCubic, x=button.x-100})
        local transitionAlpha = transition.to( button,{time=250, transition=easing.inCirc, alpha=0.5} )
    end

    -- Runs when updateUI() gets called
    if update then
        if (index ~= scene._indexOfSelected) and (index ~= 5) then
            -- reset variables
            scene._selected = nil
            scene._indexOfSelected = nil
            
            local selected = scene.widgetIndex-1
            showButton(selected)
            return
        end
    
    end

    -- Runs when a saveslot is selected
    if selected then
        if selected == scene._selected or (lib.control.mode == 'key') then
            if scene.save[selected] then

                lib.savefile.current.name = 'savefile'..selected..'.json'
                print(">> RUN THE GAME <<")
                Runtime:removeEventListener()
                lib.level.load()
            end
        else 
            scene._selected = selected
            scene._indexOfSelected = index
            
            if lib.control.mode == 'touch' then
                scene.widgetIndex = selected+1
                local params = {time = 200, transition = easing.outQuint, xScale = 1.5, yScale = 1.5} 
                transition.to( widget.pointer, params )
            end
            
            -- Show manage button
            showButton(selected)
        end
    end
end

function scene:updateUI()
    if (lib.control.mode == "key") then
        scene:fcButton({update=true})
        scene:hoverObj()
    end
end

local function handleInteraction(event)
    if (event.phase == 'ended') then
        local id = event.target.id
        
        scene:removeEventListener("interaction", handleInteraction )
        if (id == 'buttonBack') then
            lib.scene.show("resources.scene.menu.mainmenu", {effect = "fade", time = 400})

        elseif (id == 'buttonSave1') then
            scene:fcButton({selected=1})

        elseif (id == 'buttonSave2') then
            scene:fcButton({selected=2})

        elseif (id == 'buttonSave3') then
            scene:fcButton({selected=3})

        elseif (id == 'buttonInteract') then

            scene.widgetsTable[5]["function"]()
        end
    end
end

function scene:loadUI()
    local sceneGroup = scene.view

    scene.widgetsTable = {
        [1] = {
            ["creation"] = {
                x = 0,
                y = 50,
                id = "buttonBack",
                label = "back",
                onEvent = handleInteraction,
                font = "fonts/BULKYPIX.TTF",
                fontSize = 25,
                labelColor = { default={ 1, 1, 1 }, over={ 1, 1, 1, 0.5 } },
                width = 120,
                height = 40,
                defaultFile = 'resources/graphics/ui/buttonShort.png',
                overFile = 'resources/graphics/ui/buttonShortPressed.png',
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
                labelColor = { default={ 1, 1, 1 }, over={ 1, 1, 1, 0.5 } },
                width = 120,
                height = 40,
                defaultFile = 'resources/graphics/ui/buttonShort.png',
                overFile = 'resources/graphics/ui/buttonShortPressed.png',
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
                labelColor = { default={ 1, 1, 1 }, over={ 1, 1, 1, 0.5 } },
                width = 120,
                height = 40,
                defaultFile = 'resources/graphics/ui/buttonShort.png',
                overFile = 'resources/graphics/ui/buttonShortPressed.png',
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
                labelColor = { default={ 1, 1, 1 }, over={ 1, 1, 1, 0.5 } },
                width = 120,
                height = 40,
                defaultFile = 'resources/graphics/ui/buttonShort.png',
                overFile = 'resources/graphics/ui/buttonShortPressed.png',
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
                label = "",
                onEvent = handleInteraction,
                font = "fonts/BULKYPIX.TTF",
                fontSize = 20,
                labelColor = { default={ 1, 1, 1 }, over={ 1, 1, 1, 0.5 } },
                width = 120,
                height = 40,
                defaultFile = 'resources/graphics/ui/buttonShort.png',
                overFile = 'resources/graphics/ui/buttonShortPressed.png',
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
        
        scene:redirect()

        scene.widgetIndex = 2

        scene:checkSaveFiles()
        scene:updateSaveSlots()
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
 
        -- reset variables
        scene._selected = nil
        scene._indexOfSelected = nil
        local button = scene.widgetsTable[5].pointer
        button.x, button.y = -1500, -1500
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