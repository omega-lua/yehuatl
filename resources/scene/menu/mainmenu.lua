-- Template from Solar2D-Guide: https://docs.coronalabs.com/guide/system/composer/index.html#template

local lib = require( "resources.lib.lib" )
local widget = require( "widget" )
local composer = require( "composer" )
local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Scene variables
-- -----------------------------------------------------------------------------------

scene.type = "menu"

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

function scene:hoverObj()
    local widgetIndex = scene.widgetIndex
    for i,widget in pairs(scene.widgetsTable) do
        local params = {}
        if (i == widgetIndex) then
            params = {time = 200, transition = easing.outQuint, xScale = 1.5, yScale = 1.5,alpha=1}     
        else
            params = {time = 200, transition = easing.outQuint, xScale = 1, yScale = 1,alpha=0.5}
        end
        transition.to(widget.pointer, params)
    end
end

function scene:updateUI()
    scene:hoverObj()
end

local function handleInteraction(event)
    if (event.phase == "ended") then
        local id = event.target.id
        local options = {effect = "fade", time = 400}
        if (id == 'buttonPlay') then
            lib.scene.show( "resources.scene.menu.savemenu", options )
        elseif (id == 'buttonSettings') then
            lib.scene.show( "resources.scene.menu.settingsmenu", options )
        elseif (id == 'buttonCredits') then
            lib.scene.show( "resources.scene.menu.creditsmenu", options )
        end
    end
end
 
function scene:loadUI()
    local sceneGroup = scene.view

    -- Create widgets
    for i, object in pairs(scene.widgetsTable) do
        local type = object.type
        if (type == "text") then
            scene.widgetsTable[i].pointer = display.newText (object.creation )
            sceneGroup:insert(scene.widgetsTable[i].pointer)
        elseif (type == "button") then
            scene.widgetsTable[i].pointer = widget.newButton( object.creation )
            sceneGroup:insert(scene.widgetsTable[i].pointer)
        end
    end
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
 
-- create()
function scene:create( event )
 
    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen

    scene.widgetsTable = {
        [1] = {
            ["creation"] = {
                x = 420, 
                y = 180,
                id = "buttonPlay",
                label = "Play",
                onEvent = handleInteraction,
                font = "fonts/BULKYPIX.TTF",
                fontSize = 30,
                labelColor = { default={ 1, 1, 1 }, over={ 1, 1, 1, 0.5 } }
            },
            ["function"] = function() scene:dispatchEvent({ name="interaction", target={id="buttonPlay"}, phase="ended"}) end,
            ["navigation"] = {2,3,2,3},
            ["pointer"] = {},
            ["type"] = "button",
            ["isInteractable"] = true
        },
        [2] = {
            ["creation"] = {
                x = 180,
                y = 180, 
                id = "buttonSettings",
                label = "Settings",
                onEvent = handleInteraction,
                font = "fonts/BULKYPIX.TTF",
                fontSize = 30,
                labelColor = { default={ 1, 1, 1 }, over={ 1, 1, 1, 0.5 } }
            },
            ["function"] = function() scene:dispatchEvent({ name="interaction", target={id="buttonSettings"}, phase="ended"}) end,
            ["navigation"] = {1,3,1,3},
            ["pointer"] = {},
            ["type"] = "button",
            ["isInteractable"] = true
        },
        [3] = {
            ["creation"] = {
                x = 300,
                y = 260, 
                id = "buttonCredits",
                label = "Credits",
                onEvent = handleInteraction,
                font = "fonts/BULKYPIX.TTF",
                fontSize = 30,
                labelColor = { default={ 1, 1, 1 }, over={ 1, 1, 1, 0.5 } }
            },
            ["function"] = function() scene:dispatchEvent({ name="interaction", target={id="buttonCredits"}, phase="ended"}) end,
            ["navigation"] = {1,1,2,1},
            ["pointer"] = {},
            ["type"] = "button",
            ["isInteractable"] = true
        },
    }

    scene:loadUI()
    scene.widgetIndex = 1
end
 
 
-- show()
function scene:show( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)

        -- Refresh
        scene:hoverObj()

        -- animation
        local buttonPlay = scene.widgetsTable[1].pointer
        local buttonSettings = scene.widgetsTable[2].pointer
        local buttonCredits = scene.widgetsTable[3].pointer
        transition.from( buttonPlay, {time=1000,delay=500,transition=easing.outCubic,x=900} )
        transition.from( buttonSettings, {time=1000,delay=250,transition=easing.outCubic,y=-500} )
        transition.from( buttonCredits, {time=1000,transition=easing.outCubic,y=500} )

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