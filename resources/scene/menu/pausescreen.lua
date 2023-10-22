local lib = require( "resources.lib.lib" )
local widget = require( "widget" )
local composer = require( "composer" )
local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Scene variables
-- -----------------------------------------------------------------------------------

scene.type = 'menu'

-- -----------------------------------------------------------------------------------
-- Scene functions
-- -----------------------------------------------------------------------------------

function scene:hoverObj()
    local widgetIndex = scene.widgetIndex
    for i,widget in pairs(scene.widgetsTable) do
        local params = {}
        if (i == widgetIndex) then 
            params = {time = 200, transition = easing.outQuint, xScale = 1.2, yScale = 1.2, alpha=1}     
        else
            params = {time = 200, transition = easing.outQuint, xScale = 1, yScale = 1, alpha=0.7}
        end
        transition.to(widget.pointer, params)
    end
end

function scene:updateUI()
    if (lib.control.mode == "key") then
        scene:hoverObj()
    end
end

local function handleInteraction( event )
    if event.phase == 'ended' then
        local id = event.target.id
        local parent = composer.getScene( composer.getSceneName( 'current' ) )
        
        if (id == 'buttonBack') then
            scene:removeEventListener( 'interaction', handleInteraction )
            parent:resume()
        
        elseif (id == 'buttonExit') then
            scene:removeEventListener( 'interaction', handleInteraction )
            local parent = composer.getSceneName( 'current' )
            composer.removeScene( parent )
            lib.scene.show('resources.scene.menu.mainmenu', {'fade', 1500})
        end
    end
end

function scene:loadUI()
    local sceneGroup = scene.view
    local leftBorder = -(display.actualContentWidth - 600)*0.5

    -- Make background scene darker
    local darkenedBackground = display.newRect( sceneGroup, 300, 200, 1000, 500 )
    darkenedBackground:setFillColor(0,0,0,0.5)

    -- Create background
    local background = display.newRect( sceneGroup, 0, 200, 500, 400 )
    background:setFillColor(0,0,0)

    -- Create widgetsTable
    scene.widgetsTable = {
        [1] = {
            ["creation"] = {
                id = 'buttonBack',
                x = leftBorder+180,
                y = 200,
                width = 160,
                height = 60,
                defaultFile = 'resources/graphics/ui/buttonShort.png',
                overFile = 'resources/graphics/ui/buttonShortPressed.png',
                label = "Resume",
                onRelease = handleInteraction,
                font = "fonts/BULKYPIX.TTF",
                fontSize = 25,
                labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } }
            },
            ["function"] = function() scene:dispatchEvent({ name="interaction", target={id="buttonBack"}, phase="ended"}) end,
            ["navigation"] = {nil,2,nil,2},
            ["pointer"] = {},
            ["type"] = "button"
        },
        [2] = {
            ["creation"] = {
                id = 'buttonExit',
                x = leftBorder+180,
                y = 300,
                width = 160,
                height = 60,
                defaultFile = 'resources/graphics/ui/buttonShort.png',
                overFile = 'resources/graphics/ui/buttonShortPressed.png',
                label = "Exit",
                onRelease = handleInteraction,
                font = "fonts/BULKYPIX.TTF",
                fontSize = 25,
                labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } }
            },
            ["function"] = function() scene:dispatchEvent({ name="interaction", target={id="buttonExit"}, phase="ended"}) end,
            ["navigation"] = {nil,1,nil,1},
            ["pointer"] = {},
            ["type"] = "button"
        },
        [3] = {
            ["creation"] = {
                x = leftBorder+180, 
                y = 100,
                id = "text",
                text = "Paused",
                font = "fonts/BULKYPIX.TTF",
                fontSize = 30,
            },
            ["pointer"] = {},
            ["type"] = "text",
            ["color"] = {1,1,1}
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
    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen

    scene.widgetIndex = 1
    scene:loadUI()
    scene:updateUI()
end
 
 
-- show()
function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)

        --sceneGroup:toFront()

    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen

        scene:addEventListener( 'interaction', handleInteraction )
    end
end
 
 
-- hide()
function scene:hide( event )
    local sceneGroup = self.view
    local phase = event.phase
    local parent = event.parent  --reference to the parent scene object
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is on screen (but is about to go off screen)

        scene:removeEventListener( 'interaction', handleInteraction )

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