-- Template from Solar2D-Guide: https://docs.coronalabs.com/guide/system/composer/index.html#template

local library = require("library")
local widget = require( "widget" )
local composer = require( "composer" )
local scene = composer.newScene()
 
-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

-- Nicht so schön...
local function reloadScene()
    local currScene = composer.getSceneName( "current" )
    composer.removeScene(currScene)
    composer.gotoScene( currScene )
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
            reloadScene()
        elseif (event.target.id == 'newSaveSlot2') then
            library.newSaveFile('save2.json')
            reloadScene()
        elseif (event.target.id == 'newSaveSlot3') then
            library.newSaveFile('save3.json')
            reloadScene()
        elseif (event.target.id == 'deleteSaveSlot1') then
            library.deleteFile('save1.json')
            reloadScene()
        elseif (event.target.id == 'deleteSaveSlot2') then
            library.deleteFile('save2.json')
            reloadScene()
        elseif (event.target.id == 'deleteSaveSlot3') then
            library.deleteFile('save3.json')
            reloadScene()
        end
    end
end


-- Verbesserungspotential hinsichtlich Optimierung
local function LoadUI() 
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
        left = ((display.viewableContentWidth+display.screenOriginX)/2)+300,
        top = (display.actualContentHeight / 2) - 100,
        id = "buttonSaveSlot1",
        label = "Save 1",
        onEvent = handleButtonEvent,
        fontSize = 25,
        labelColor = { default={ 255, 255, 255, 1}}
    })

    -- button for loading save2.json
    buttonSaveSlot2 = widget.newButton({
        left = ((display.viewableContentWidth+display.screenOriginX)/2)+300,
        top = (display.actualContentHeight / 2),
        id = "buttonSaveSlot2",
        label = "Save 2",
        onEvent = handleButtonEvent,
        fontSize = 25,
        labelColor = { default={ 255, 255, 255, 1 }},
        })
       

    -- button for loading save3.json
    buttonSaveSlot3 = widget.newButton({
        left = ((display.viewableContentWidth+display.screenOriginX)/2)+300,
        top = (display.actualContentHeight / 2) + 100,
        id = "buttonSaveSlot3",
        label = "Save 3",
        onEvent = handleButtonEvent,
        fontSize = 25,
        labelColor = { default={ 255, 255, 255, 1 }},
    })

    if (save1 == false) then
        buttonSaveSlot1:setEnabled( false )  -- The button will no longer receive touch events.
        buttonSaveSlot1:setLabel( "-" )
        newSaveSlot1 = widget.newButton({
            left = ((display.viewableContentWidth+display.screenOriginX)/2)+180,
            top = (display.actualContentHeight / 2) - 100,
            id = "newSaveSlot1",
            label = "new",
            onEvent = handleButtonEvent,
            fontSize = 25,
            labelColor = { default={ 255, 255, 255, 1 }},
        })
        sceneGroup:insert(newSaveSlot1)
    elseif (save1 == true) then
        deleteSaveSlot1 = widget.newButton({
            left = ((display.viewableContentWidth+display.screenOriginX)/2)+180,
            top = (display.actualContentHeight / 2) - 100,
            id = "deleteSaveSlot1",
            label = "delete",
            onEvent = handleButtonEvent,
            fontSize = 25,
            labelColor = { default={ 255, 255, 255, 1 }},
        })
        sceneGroup:insert(deleteSaveSlot1)
    end

    if (save2 == false) then
        buttonSaveSlot2:setEnabled( false )  -- The button will no longer receive touch events.
        buttonSaveSlot2:setLabel( "-" )
        newSaveSlot2 = widget.newButton({
            left = ((display.viewableContentWidth+display.screenOriginX)/2)+180,
            top = (display.actualContentHeight / 2),
            id = "newSaveSlot2",
            label = "new",
            onEvent = handleButtonEvent,
            fontSize = 25,
            labelColor = { default={ 255, 255, 255, 1 }},
        })
        sceneGroup:insert(newSaveSlot2)
    elseif (save2 == true) then
        deleteSaveSlot2 = widget.newButton({
            left = ((display.viewableContentWidth+display.screenOriginX)/2)+180,
            top = (display.actualContentHeight / 2),
            id = "deleteSaveSlot2",
            label = "delete",
            onEvent = handleButtonEvent,
            fontSize = 25,
            labelColor = { default={ 255, 255, 255, 1 }},
        })
        sceneGroup:insert(deleteSaveSlot2)
    end

    if (save3 == false) then
        print("3: false")
        buttonSaveSlot3:setEnabled( false )  -- The button will no longer receive touch events.
        buttonSaveSlot3:setLabel( "-" )
        newSaveSlot3 = widget.newButton({
            left = ((display.viewableContentWidth+display.screenOriginX)/2)+180,
            top = (display.actualContentHeight / 2)+100,
            id = "newSaveSlot3",
            label = "new",
            onEvent = handleButtonEvent,
            fontSize = 25,
            labelColor = { default={ 255, 255, 255, 1 }},
        })
        sceneGroup:insert(newSaveSlot3)
    elseif (save3 == true) then
        print("3: true")
        deleteSaveSlot3 = widget.newButton({
            left = ((display.viewableContentWidth+display.screenOriginX)/2)+180,
            top = (display.actualContentHeight / 2)+100,
            id = "deleteSaveSlot3",
            label = "delete",
            onEvent = handleButtonEvent,
            fontSize = 25,
            labelColor = { default={ 255, 255, 255, 1 }},
        })
        sceneGroup:insert(deleteSaveSlot3)
    end

    -- Back button
    buttonBack = widget.newButton({
        left = 100,
        top = 200,
        id = "buttonBack",
        label = "Back",
        onEvent = handleButtonEvent,
        fontSize = 30,
        labelColor = { default={ 255, 255, 255, 1 }},
    })


    sceneGroup:insert( buttonSaveSlot1 )
    sceneGroup:insert( buttonSaveSlot2 )
    sceneGroup:insert( buttonSaveSlot3 )
    sceneGroup:insert( buttonBack )
end


-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
 
-- create()
function scene:create( event )
    -- Code here runs when the scene is first created but has not yet appeared on screen
    
    --local sceneGroup = self.view -- mit scene.view geht anscheinend auch ausserhalb dieser Funktion.
    
end
 
 
-- show()
function scene:show( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)
        LoadUI()
 
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