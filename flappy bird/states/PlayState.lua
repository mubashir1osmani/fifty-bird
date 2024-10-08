
PlayState = Class{__includes = BaseState}

PIPE_SPEED = 60
PIPE_WIDTH = 70
PIPE_HEIGHT = 288

BIRD_WIDTH = 38
BIRD_HEIGHT = 24

local audio = true
local pause = love.graphics.newImage('pause.png')
function PlayState:init()
    self.bird = Bird()
    self.pipePairs = {}
    self.timer = 0

    -- now keep track of our score
    self.score = 0

    -- initialize our last recorded Y value for a gap placement to base other gaps off of
    self.lastY = -PIPE_HEIGHT + math.random(80) + 20
end

function PlayState:update(dt)
    -- update timer for pipe spawning
    if self.paused then
        if love.keyboard.wasPressed('tab') then
            self.paused = false
            sounds['pause']:play()
            love.audio.play(sounds['music'])
            scrolling = true
        else
            return
        end
    elseif love.keyboard.wasPressed('tab') then
        self.paused = true
        sounds['pause']:play()
        love.audio.pause(sounds['music'])
        scrolling = false
        return

    end
    self.timer = self.timer + dt

    -- spawn a new pipe pair every second and a half
    if self.timer > math.random(3, 3.2) then
        -- modify the last Y coordinate we placed so pipe gaps aren't too far apart
        -- no higher than 10 pixels below the top edge of the screen,
        -- and no lower than a gap length (90 pixels) from the bottom
        local y = math.max(-PIPE_HEIGHT + 10, 
            math.min(self.lastY + math.random(-20, 20), VIRTUAL_HEIGHT - 90 - PIPE_HEIGHT))
        self.lastY = y

        -- add a new pipe pair at the end of the screen at our new Y
        table.insert(self.pipePairs, PipePairs(y))

        -- reset timer
        self.timer = 0
    end
    if audio == true then
        if self.score == 10 then
            sounds['highscore']:play()
            audio = false
        end

    end

    -- for every pair of pipes..
    for k, pair in pairs(self.pipePairs) do
        -- score a point if the pipe has gone past the bird to the left all the way
        -- be sure to ignore it if it's already been scored
        if not pair.scored then
            if pair.x + PIPE_WIDTH < self.bird.x then
                self.score = self.score + 1
                pair.scored = true
                sounds['score']:play()
            end
        end

        -- update position of pair
        pair:update(dt)
    end

    -- we need this second loop, rather than deleting in the previous loop, because
    -- modifying the table in-place without explicit keys will result in skipping the
    -- next pipe, since all implicit keys (numerical indices) are automatically shifted
    -- down after a table removal
    for k, pair in pairs(self.pipePairs) do
        if pair.remove then
            table.remove(self.pipePairs, k)
        end
    end

    -- update bird based on gravity and input
    self.bird:update(dt)

    -- simple collision between bird and all pipes in pairs
    for k, pair in pairs(self.pipePairs) do
        for l, pipe in pairs(pair.pipes) do
            if self.bird:collides(pipe) then
                sounds['explosion']:play()
                sounds['hurt']:play()
                love.system.vibrate(3)

                gStateMachine:change('score', {
                    score = self.score
                })
            end
        end
    end

    -- reset if we get to the ground
    if self.bird.y > VIRTUAL_HEIGHT - 15 then
        sounds['explosion']:play()
        sounds['hurt']:play()
        love.system.vibrate(3)
        gStateMachine:change('score', {
            score = self.score
        })
    end
end

function PlayState:render()
    for k, pair in pairs(self.pipePairs) do
        pair:render()
    end

    if self.paused then
        love.graphics.draw(pause, 195, 60)
    end

    love.graphics.setFont(flappyFont)
    love.graphics.print('Score: ' .. tostring(self.score), 8, 8)

    if self.score >= 3 then 
        love.graphics.draw(trophies['bronze'],0, 40)
    end

    if self.score >= 6 then
        love.graphics.draw(trophies['silver'], 35, 40)
    end

    if self.score >=10 then
        love.graphics.draw(trophies['gold'],70, 40)
    end
    self.bird:render()

end