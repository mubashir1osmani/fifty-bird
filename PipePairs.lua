
PipePairs = Class{}

-- size of the gap between pipes
GAP_HEIGHT = math.random(math.random(60, 100), 120)

function PipePairs:init(y)
    -- initialize pipes past the end of the screen
    self.x = VIRTUAL_WIDTH + 32

    -- y value is for the topmost pipe; gap is a vertical shift of the second lower pipe
    self.y = y

    -- instantiate two pipes that belong to this pair
    self.pipes = {
        ['upper'] = Pipe('top', self.y),
        ['lower'] = Pipe('bottom', self.y + PIPE_HEIGHT + GAP_HEIGHT)
    }

    -- whether this pipe pair is ready to be removed from the scene
    self.remove = false
    self.scored = false
end

function PipePairs:update(dt)
    -- remove the pipe from the scene if it's beyond the left edge of the screen,
    -- else move it from right to left
    if self.x > -PIPE_WIDTH then
        self.x = self.x - PIPE_SPEED * dt
        self.pipes['lower'].x = self.x
        self.pipes['upper'].x = self.x
    else
        self.remove = true
    end
end

function PipePairs:render()
    for k, pipe in pairs(self.pipes) do
        pipe:render()
    end
end