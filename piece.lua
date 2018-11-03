local piece = {}
piece.__index = piece

function piece.new()
    local p = {}
    setmetatable(p, piece)

    -- randomly select a piece to create
    p.index = math.random(1, #piecedata)

    -- randomly select a rotation
    p.rotation = math.random(1, #piecedata[p.index].data)
    
    -- rotation stuff
    p.canrotate = true
    p.rotationcounter = 0

    -- set a position
    p.x = math.random(1, config.board.width - #piecedata[p.index].data[p.rotation][1])
    p.y = 0

    -- movement counter
    p.counter = 0

    -- removal flag
    p.remove = false

    return p
end

-- updates the position and checks for collision with board...
function piece:update(dt)
    -- check for board collision (y + 1)
    local p = piecedata[self.index].data[self.rotation]
    -- loop through the piece and see if anything is below it
    for j=1, #p, 1 do
        for i=1, #p[j], 1 do
            if p[j][i] then
                -- position to check on board
                local x = i+self.x
                local y = j+self.y+1
                if board.board[x][y].used then
                    -- found a hit, flag for removal
                    self.remove = true
                    -- add piece to board
                    board:add(self.x, self.y, p, piecedata[self.index].colour)
                    if self.y == config.board.loseline then
                        lost = true
                    end
                    return
                end
            end
        end
    end

    -- move the piece down
    self.counter = self.counter + dt
    if self.counter >= config.pieces.speed then
        self.counter = self.counter - config.pieces.speed
        self.y = self.y + 1
    end

    if not(self.canrotate) then
        self.rotationcounter = self.rotationcounter + dt
        if self.rotationcounter >= config.pieces.rotationspeed then
            self.canrotate = true
        end
    end
end

function piece:drawShadow()
    -- set piece data
    local p = piecedata[self.index].data[self.rotation]
    local s = piecedata[self.index].shadowoffset[self.rotation]    
    -- get and set colour
    local c = {piecedata[self.index].colour[1],piecedata[self.index].colour[2],piecedata[self.index].colour[3],piecedata[self.index].colour[4]}
    c[4] = 0.25
    love.graphics.setColor(c)
    -- calc rectangle
    local x = (self.x) * config.board.size
    local y = (self.y + s) * config.board.size
    local w = #p[1] * config.board.size
    local h = (config.board.height - self.y - s) * config.board.size
    love.graphics.rectangle("fill", x, y, w, h)
    love.graphics.setColor(1,1,1,1)
end

function piece:draw()
    -- draw the piece!
    local p = piecedata[self.index].data[self.rotation]
    for j=1, #p, 1 do
        for i=1, #p[j] do
            if p[j][i] then
                love.graphics.setColor(piecedata[self.index].colour)
                local x = (i-1+self.x) * config.board.size
                local y = (j-1+self.y) * config.board.size
                love.graphics.rectangle("fill", x, y, config.board.size, config.board.size)
            end
        end
    end
    love.graphics.setColor(1,1,1,1)
end

function piece:rotate()
    if self.canrotate then
        -- reset rotation stuff
        self.canrotate = false
        self.rotationcounter = 0
        -- inc rotation index
        self.rotation = self.rotation + 1
        if self.rotation > #piecedata[self.index].data then
            self.rotation = 1
        end
        -- check position
        if self.x + #piecedata[self.index].data[1] > config.board.width then
            self.x = self.x - 1
        end
    end
end

return piece