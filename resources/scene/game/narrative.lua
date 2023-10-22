local lib = require('resources.lib.lib')
local widget = require( 'widget' )
local composer = require( "composer" )

local scene = composer.newScene()
 
-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------
-- Scene variables
-- -----------------------------------------------------------------------------------

scene.name = 'narrative'
scene.type = 'game'
scene.params = {}
scene.parent = nil
scene.currentPage = 1
scene.pages = {}
scene.textBox = {}

-- -----------------------------------------------------------------------------------
-- Scene functions
-- -----------------------------------------------------------------------------------

local function onButtonPress(event)
    local phase = event.phase
    if phase == 'up' then
        -- only the interact-keybind works while in key-control
        if event.keyName and event.keyName ~= lib.keybind.interact then
            return false
        end
        -- Localize
        local currentPage = scene.currentPage
        local pages = scene.pages
        local string = pages[currentPage + 1]
        local params = scene.params
    
        if string then
            -- change text
            local textBox = scene.textBox
            local function changeText()
                textBox.text = string
                transition.to(textBox, {time=200, transition=easing.inQuad, alpha=1})
            end
            transition.to(textBox, {time=200, transition=easing.inQuad, alpha=0, onComplete=changeText})

            -- update current page variable
            scene.currentPage = currentPage + 1
        else
            -- close overlay
            composer.hideOverlay('fade', 500)       
            -- open last overlay again (hud)
            local parent = composer.getScene( composer.getSceneName( 'current' ) )
            parent.lastOverlay = 'resources.scene.game.hud'
            parent:_showLastOverlay()
            -- Remove key-EventListener for key-control
            if lib.control.mode == 'key' then
                Runtime:removeEventListener('key', onButtonPress)
            end
            -- execute function
            params.fc()
        end
    end
end

function scene:build(params)
    -- Localize
    local rectangle, textBox, button
    local sceneGroup = scene.view
    local params = scene.params
    
    -- Create background
    if params.fullscreen then
        rectangle = display.newRect( sceneGroup, 300, 325, 500, 100 )
    else
        rectangle = display.newImage( sceneGroup, 'resources/graphics/narrative/textBox.png', 300, 300 )
        rectangle:scale(5,5)
    end

    -- Prepare string(s)
    local text = params.text
    local pages = {}
    if (type(text) == 'string') then
        local len = text:len()
        local n = math.ceil(len/100)
        for i=1, n do
            local l = (i-1)*100
            local string = text:sub(l, l+100)
            if i ~= n then
                string = string.."..."
            end
            pages[i] = string
        end
    else -- if text is a table
        for k,v in pairs(text) do
            pages[k] = v
        end
    end
    scene.pages = pages

    -- Create textBox
    local options = {
        parent=sceneGroup,
        text = pages[1],
        x = 300,
        y = 300,
        width = 400,
        font = "fonts/BULKYPIX.TTF",
        fontSize = 20,
    }
    local textBox = display.newText( options )
    scene.textBox = textBox

    -- Create button
    local fc = function() onButtonPress({name="touch", target=onButtonPress, phase='up'}) end
    local button = widget.newButton({
        x = 485,
        y = 350,
        width = 84,
        height = 36,
        defaultFile = 'resources/graphics/ui/buttonShort.png',
        overFile = 'resources/graphics/ui/buttonShortPressed.png',
        label = "Next",
        onRelease = fc,
        font = "fonts/BULKYPIX.TTF",
        fontSize = 15,
        labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } }
    })
    sceneGroup:insert(button)


    -- get player table
    local parent = composer.getScene( composer.getSceneName( 'current' ) )
    local map = parent.map
    local player = map.layer['entities'].object['player']
        
    -- Reset movement variables of player
    player.pressingForward = false
    player.pressingBackward = false
    player:handleMovement()
    
    -- add EventListener so player can click throuh pages.
    if lib.control.mode == 'key' then
        Runtime:addEventListener('key', onButtonPress)
    end
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )
 
    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen

    scene.params = event.params
    scene:build()
end
 
 
-- show()
function scene:show( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)
 
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