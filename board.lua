
local board = {}
board.__index = board


-- create a new board
function board.new()
    local b = {}
    setmetatable(b, board)

    -- initialize the board (all unused, colour = black)
    b.board = {}
    for i=1, config.board.width, 1 do
        b.board[i] = {}
        for j=1, config.board.height, 1 do
            b.board[i][j] = {used = false, colour = {0,0,0,1}}
            if j == config.board.height then
                b.board[i][j].used = true
                b.board[i][j].colour = {1,1,1,1}
                b.board[i][j].bulletspawn = nil
            end
        end
    end

    -- line removal stuff
    b.removelines = false
    b.removalcounter = 0
    b.lines = {}

    -- line addition stuff
    b.addcounter = 0


    -- create the grid background
    b.background = love.graphics.newCanvas(config.board.width * config.board.size, config.board.height * config.board.size)
    love.graphics.setCanvas(b.background)
    love.graphics.setColor(config.board.colour)
    -- draw board lines
    for i=1, config.board.width+1, 1 do
        local x1 = (i-1) * config.board.size
        local y1 = 0
        local x2 = x1
        local y2 = (config.board.height-1) * config.board.size
        love.graphics.line(x1, y1, x2, y2)
    end
    for i=1, config.board.height, 1 do
        local x1 = 0
        local y1 = (i-1) * config.board.size
        local x2 = (config.board.width) * config.board.size
        local y2 = y1
        love.graphics.line(x1, y1, x2, y2)
    end
    love.graphics.setColor(1,1,1,1)
    love.graphics.setCanvas()

    return b
end

function board:update(dt)
    -- are we removing lines?
    if not(self.removelines) then 
        self:checkForLines()
    else
        self.removalcounter = self.removalcounter + dt
        if self.removalcounter >= config.board.removalspeed then
            self.removalcounter = 0
            self.removelines = false
            self:remove()
            print("remove counter done")
            print("lines left: " .. #self.lines)
        end
    end

    -- loop through the board and update any active bulletspawns
    for j=1, config.board.height-1, 1 do
        for i=1, config.board.width, 1 do
            if self.board[i][j].bulletspawn then
                self.board[i][j].bulletspawn:update(dt)
            end
        end
    end

    -- are we adding lines?
    self.addcounter = self.addcounter + dt
    if self.addcounter >= config.board.addspeed then
        self.addcounter = self.addcounter - config.board.addspeed
        
        -- shift all lines up
        for j=2, config.board.height-1, 1 do
            for i=1, config.board.width, 1 do
                -- copy it up!
                self.board[i][j-1].used = self.board[i][j].used
                self.board[i][j-1].colour = self.board[i][j].colour
                self.board[i][j-1].bulletspawn = self.board[i][j].bulletspawn
                if self.board[i][j-1].bulletspawn then
                    self.board[i][j-1].bulletspawn:setPosition(i, j-1)
                end
            end
        end

        -- randomly create a new line
        local j = config.board.height-1
        for i=1, config.board.width, 1 do
            local used = false
            if math.random() >= config.board.usedchance then
                used = true
            end
            local colour = math.random(1,#piecedata)
            self.board[i][j].used = used
            self.board[i][j].colour = piecedata[colour].colour
            if config.board.bulletspawnchance >= math.random() then
                self.board[i][j].bulletspawn = bulletspawnobj.new(i, j)
            else
                self.board[i][j].bulletspawn = nil
            end
        end
    end

end

-- loops through the board and draws the used spots
function board:drawBoard()
    for i=1, config.board.width, 1 do
        for j=1, config.board.height, 1 do
            if self.board[i][j].used then
                love.graphics.setColor(self.board[i][j].colour)
                for m, n in ipairs(self.lines) do
                    if j == n then
                        love.graphics.setColor(1,1,1,1)
                        break
                    end
                end
                local x = (i-1) * config.board.size
                local y = (j-1) * config.board.size
                love.graphics.rectangle("fill", x, y, config.board.size, config.board.size)
                love.graphics.setColor(1,1,1,1)

                -- kick off bullet spawn draw from here...
                if self.board[i][j].bulletspawn then
                    self.board[i][j].bulletspawn:draw()
                end
            end
        end
    end
end

-- draw the background image
function board:drawBackground() 
    love.graphics.draw(self.background, 0, 0)
end

-- adds a piece to the board at the stated position
function board:add(px, py, p, colour)
    -- add piece
    for j=1, #p, 1 do
        for i=1, #p[j], 1 do
            if p[j][i] then
                local x = i+px
                local y = j+py
                self.board[x][y].used = true
                self.board[x][y].colour = colour
            end
        end
    end
    -- -- check for highest point - adjust player as required
    -- local highest = config.board.height
    -- for j=config.board.height-1, 1, -1 do
    --     local found = false
    --     for i=1, config.board.width, 1 do
    --         if self.board[i][j].used then
    --             highest = j
    --             found = true
    --             break
    --         end
    --     end
    --     -- break if one wasn't found on the line... we have the highest point
    --     if not(found) then
    --         break
    --     end
    -- end
end

-- loops and identifies completed lines
-- NEEDS TO BE TESTED!
function board:checkForLines()
    -- -1 because we dont want to check last line of board...
    for j=1, config.board.height-1, 1 do
        -- local completedline = true
        for i=1, config.board.width, 1 do
            -- if we have reached the end of the line and didn't find any blanks, add to line table!
            if i == config.board.width and self.board[i][j].used then
                table.insert(self.lines, j)
            end
            -- empty spot found, break out!
            if not(self.board[i][j].used) then
                break
            end
        end
    end
    if #self.lines > 0 then
        self.removelines = true
        print("found: " .. #self.lines)
    end
end

-- go through this and see what is going on...
-- something is up with the j loop not working as I expect it to... i need to map this out
-- removes lines
function board:remove()
    -- loop throught the lines to remove (backwards) and move the ones above them down...
    for l=#self.lines, 1, -1 do
        -- loop from position of removed line to top of board and move them all down...
        for j=self.lines[l], 1, -1 do
            for i=1, config.board.width, 1 do
                -- copy it down
                if not(j==1) then
                    -- move rows down
                    self.board[i][j].used = self.board[i][j-1].used 
                    self.board[i][j].colour = self.board[i][j-1].colour
                    self.board[i][j].bulletspawn = self.board[i][j-1].bulletspawn
                else
                    -- on first row.. just blank it out
                    self.board[i][j].used = false 
                    self.board[i][j].colour = {0,0,0,1}
                    self.board[i][j].bulletspawn = nil
                end
            end
        end
        if not(l==1) then
            for i, v in ipairs(self.lines) do
                v = v + 1
            end
        end
    print("removed: " .. self.lines[l])
    end

    self.lines = {}
end

return board