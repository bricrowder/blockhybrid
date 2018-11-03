local piece = {}
piece.__index = piece

function piece.new()
    local p = {}
    setmetatable(p, piece)

    return p
end

-- resets the piece
function piece:reset()
    -- randomly select a piece to create
    self.index = math.random(1, #piecedata)

    -- randomly select a rotation
    self.rotation = math.random(1, #piecedata[self.index].data)
    
    -- set a position
    self.x = math.random(1, config.board.width - #piecedata[self.index].data[self.rotation][1])
    self.y = 0

    -- general move flag
    self.atbottom = false
    self.bottomcounter = 0

    -- detect when you are at the bottom... when you are at the bottom, start a timer - at the end of the timer it sets it to the board.  timer gets reset if you move/rotate



    -- downward movement stuff
    self.counter = 0
    self.downflag = false

    -- sideways movement stuff
    self.sidecounter = 0
    self.canmove = true

    -- rotation stuff
    self.rotatecounter = 0
    self.canrotate = true

    -- reset flag
    self.resetflag = false
    self.resetcounter = 0
end

-- updates the position and checks for collision with board...
function piece:update(dt)
    if self.resetflag then
        self.resetcounter = self.resetcounter + dt
        if self.resetcounter >= config.pieces.spawn then
            self:reset()
        end
    else
        -- SIDEWAYS MOVEMENT
        local m = 0

        if not(self.canmove) then
            -- timer until you can move
            self.sidecounter = self.sidecounter + dt
            if self.sidecounter >= config.pieces.sidespeed then
                self.canmove = true
                self.sidecounter = 0
            end
        else
            -- get input (only if you aren't already on an edge)
            if love.keyboard.isDown("left") and self.x > 0 then
                m = -1
                self.canmove = false
            elseif love.keyboard.isDown("right") and self.x < config.board.width - #piecedata[self.index].data[self.rotation][1] then
                m = 1
                self.canmove = false
            end
        end

        -- get piece to check
        local p = piecedata[self.index].data[self.rotation]

        -- loop through the piece if it can move side to side
        for j=1, #p, 1 do
            for i=1, #p[j], 1 do
                if p[j][i] then
                    -- see if we are trying to move sideways or not.. if so then check for a collision
                    local x = i + self.x + m
                    local y = j + self.y
                    if board.board[x][y].used then
                        -- there is something already there, negate the movement
                        m = 0
                    end
                end
            end
        end

        -- reset the bottom counter if you have moved
        if not(m == 0) then
            self.bottomcounter = 0
        end

        -- move the peice left/right
        self.x = self.x + m

        -- DOWNWARD MOVEMENT
        local y = 1

        -- loop through the piece and see if anything is below it
        self.atbottom = false
        for j=1, #p, 1 do
            for i=1, #p[j], 1 do
                if p[j][i] then
                    -- position to check on board
                    local x = i+self.x
                    local y = j+self.y+1
                    if board.board[x][y].used then      -- ERROR HERE WHEN YOU ROTATE THE CRAP OUT OF IT??
                        self.atbottom = true
                        y = 0
                    end
                end
            end
        end

        if not(self.atbottom) then
            local downmulti = 1
            if love.keyboard.isDown("down") then
                downmulti = config.pieces.downmulti
            end
    
            -- move the piece down
            self.counter = self.counter + dt * downmulti
            if self.counter >= config.pieces.speed then
                self.counter = self.counter - config.pieces.speed
                self.y = self.y + y
            end            
        else
            self.bottomcounter = self.bottomcounter + dt
            if self.bottomcounter >= config.pieces.bottomspeed then
                -- found a hit, flag for removal
                self.remove = true
                -- add piece to board
                board:add(self.x, self.y, p, piecedata[self.index].colour)
                -- flag piece to be reset
                self.resetflag = true
                if self.y == config.board.loseline then
                    lost = true
                end
            end
        end

        -- ROTATIONAL MOVEMENT
        local r = 0

        -- check for rotation
        if not(self.canrotate) then
            self.rotatecounter = self.rotatecounter + dt
            if self.rotatecounter >= config.pieces.rotationspeed then
                self.canrotate = true
                self.rotatecounter = 0
            end
        else
            -- get input
            if love.keyboard.isDown("space") then
                r = 1
                self.canrotate = false
            end
        end        

        -- check if we can rotate it by looking at next piece
        local temprotation = self.rotation + r
        if temprotation > #piecedata[self.index].data then
            temprotation = 1
        end

        p = piecedata[self.index].data[temprotation]
        local tx = self.x
        local ty = self.y

        -- need to test if the piece is bigger than available board... if so then push it up/back 1
        if tx + #p[1] > config.board.width then
            tx = tx - (#p[1] - (config.board.width - tx))
        end
        if ty + #p > config.board.height then
            ty = ty - (#p - (config.board.height - ty))
        end

        -- see if any of the piece overlaps with the board
        for j=1, #p, 1 do
            local brk = false
            for i=1, #p[j], 1 do
                if p[j][i] then
                    local x = i+tx
                    local y = j+ty
                    if board.board[x][y].used then
                        -- found an overlap - exit
                        brk = true
                        r = 0
                        break
                    end
                end
            end
            if brk then
                break
            end
        end

        -- reset the bottom counter if you have moved
        if not(r == 0) then
            self.bottomcounter = 0
            self.x = tx
            self.y = ty
        end

        -- rotate
        self.rotation = self.rotation + r
        if self.rotation > #piecedata[self.index].data then
            self.rotation = 1
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