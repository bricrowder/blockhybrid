local board = {}
board.__index = board


-- create a new board
function board.new()
    local b = {}
    setmetatable(b, board)

    -- initialize the boardm(all unused, colour = black)
    b.board = {}
    for i=1, config.board.width, 1 do
        b.board[i] = {}
        for j=1, config.board.height, 1 do
            b.board[i][j] = {used = false, colour = {0,0,0,1}}
            if j == config.board.height then
                b.board[i][j].used = true
                b.board[i][j].colour = {1,1,1,1}
            end
        end
    end

    -- create the background
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

-- loops through the board and draws the used spots
function board:drawBoard()
    for i=1, config.board.width, 1 do
        for j=1, config.board.height, 1 do
            if self.board[i][j].used then
                love.graphics.setColor(self.board[i][j].colour)
                local x = (i-1) * config.board.size
                local y = (j-1) * config.board.size
                love.graphics.rectangle("fill", x, y, config.board.size, config.board.size)
                love.graphics.setColor(1,1,1,1)
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
end

-- loops and identifies completed lines
-- NEEDS TO BE TESTED!
function board:checkForLines()
    local li = {}
    -- -1 because we dont want to check last line of board...
    for j=1, config.board.height-1, 1 do
        -- local completedline = true
        for i=1, config.board.width, 1 do
            -- if we have reached the end of the line and didn't find any blanks, add to line table!
            if i == config.board.width and self.board[i][j].used then
                table.insert(li, j)
            end
            -- empty spot found, flag and move to end
            if not(self.board[i][j].used) then
                -- completedline = false
                i = config.board.width+1
            end
        end
    end
end

return board