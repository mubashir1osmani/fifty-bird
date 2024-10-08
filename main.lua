-- virtual resolution handling library
push = require 'push'

-- classic OOP class library
Class = require 'class'

-- bird class we've written
require 'Bird'

-- pipe class we've written
require 'Pipe'

-- class representing pair of pipes together
require 'PipePairs'

-- all code related to game state and state machines
require 'StateMachine'
require 'states/BaseState'
require 'states/CountdownState'
require 'states/PlayState'
require 'states/ScoreState'
require 'states/TitleScreenState'


-- physical screen dimensions
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

-- virtual resolution dimensions
VIRTUAL_WIDTH = 512
VIRTUAL_HEIGHT = 288

-- background image and starting scroll location (X axis)
background = love.graphics.newImage('background.png')
backgroundScroll = 0

-- ground image and starting scroll location (X axis)
 ground = love.graphics.newImage('ground.png')
groundScroll = 0

-- speed at which we should scroll our images, scaled by dt
 BACKGROUND_SCROLL_SPEED = 30
 GROUND_SCROLL_SPEED = 60

-- point at which we should loop our background back to X 0
 BACKGROUND_LOOPING_POINT = 413

-- point at which we should loop our ground back to X 0
 GROUND_LOOPING_POINT = 514

-- scrolling variable to pause the game when we collide with a pipe
scrolling = true

function love.load()
    -- initialize our nearest-neighbor filter
    love.graphics.setDefaultFilter('nearest', 'nearest')

    -- app window title
    love.window.setTitle('Fifty Bird')

    -- initialize our nice-looking retro text fonts
    smallFont = love.graphics.newFont('font.ttf', 8)
    mediumFont = love.graphics.newFont('flappy.ttf', 14)
    flappyFont = love.graphics.newFont('flappy.ttf', 28)
    hugeFont = love.graphics.newFont('flappy.ttf', 56)
    love.graphics.setFont(flappyFont)

    -- initialize our virtual resolution
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        vsync = true,
        fullscreen = false,
        resizable = true
    })

    -- initialize state machine with all state-returning functions
    gStateMachine = StateMachine {
        ['title'] = function() return TitleScreenState() end,
        ['countdown'] = function() return CountdownState() end,
        ['play'] = function() return PlayState() end,

        ['score'] = function() return ScoreState() end
    }
    gStateMachine:change('title')

    trophies = {
        ['gold'] = love.graphics.newImage('gold.png'),
        ['silver'] = love.graphics.newImage('silver.png'),
        ['bronze'] = love.graphics.newImage('bronze.png')
    }

    sounds = {
        ['jump'] = love.audio.newSource("jump.wav", 'static'),
        ['score'] = love.audio.newSource('Scoreeeee.wav', 'static'),
        ['hurt'] = love.audio.newSource('hurt.wav', 'static'),
        ['explosion'] = love.audio.newSource('explosion.wav', 'static'),
        ['highscore'] = love.audio.newSource('bravo.mp3', 'static'),
        ['music'] = love.audio.newSource('marios_way.mp3', 'static'),
        ['pause'] = love.audio.newSource('pause.wav', 'static')

    }

    sounds['music']:setLooping(true)
    sounds['music']:play()

    -- initialize input table
    love.keyboard.keysPressed = {}
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.keypressed(key)
    -- add to our table of keys pressed this frame
    love.keyboard.keysPressed[key] = true

    if key == 'escape' then
        love.event.quit()
    end
end

--[[
    New function used to check our global input table for keys we activated during
    this frame, looked up by their string value.
]]
function love.keyboard.wasPressed(key)
    if love.keyboard.keysPressed[key] then
        return true
    else
        return false
    end
end

function love.update(dt)
    -- update background and ground scroll offsets
    if scrolling == true then
    backgroundScroll = (backgroundScroll + BACKGROUND_SCROLL_SPEED * dt) %
        BACKGROUND_LOOPING_POINT
    groundScroll = (groundScroll + GROUND_SCROLL_SPEED * dt) % GROUND_LOOPING_POINT
    end
    -- now, we just update the state machine, which defers to the right state
    gStateMachine:update(dt)

    -- reset input table
    love.keyboard.keysPressed = {}
end

function love.draw()
    push:start()

    -- draw state machine between the background and ground, which defers
    -- render logic to the currently active state
    love.graphics.draw(background, -backgroundScroll, 0)
    gStateMachine:render()
    love.graphics.draw(ground, -groundScroll, VIRTUAL_HEIGHT - 16)

    push:finish()
end
