-- load objects
local json = require "dkjson"       -- see dkjson.lua for author and licence
local pieceobj = require "piece"
local boardobj = require "board"
bulletspawnobj = require "bulletspawn"
bulletobj = require "bullet"

function love.load()
    -- Setup the randomizer
    math.randomseed(os.time())
    -- need to pop a few... wierd thing
    math.random()
    math.random()
    math.random()

    -- load config
    config = json.opendecode("assets/config.json")

    -- load piece data!
    piecedata = json.opendecode("assets/pieces.json").pieces

    -- create a new game
    newgame()
end

-- update everything!
function love.update(dt)
    if gamestate == "game" then
        -- update game positions
        if not(lost) then            

            -- update piece
            piece:update(dt)

            -- update board!
            board:update(dt)


            -- update bullet stuff

            -- update player -> change to bullets!
            -- player:update(dt)

        end
    end
end

function love.draw()
    if gamestate == "game" then
        -- draw background
        board:drawBackground()

        -- draw piece
        if not(piece.resetflag) then
            piece:drawShadow()
            piece:draw()
        end

        -- draw landed board peices
        board:drawBoard()

        -- bullets
        -- player:draw()
    end
end

-- gets input from the player!
function love.keypressed(k)
    -- key pressed based moving... i don't like it as much as the timer based one
    -- if k == "left" and piece.x > 0 then
    --     piece:move(-1)
    -- elseif k == "right" and piece.x < config.board.width - #piecedata[piece.index].data[piece.rotation][1]then
    --     piece:move(1)
    -- elseif k == "space" then
    if k == "space" then
        piece:rotate()
    elseif k == "down" then
    
    end
end

-- inits everything for a new game
function newgame()
    -- set starting game state
    gamestate = "game"
    -- lost status
    lost = false
    -- create the player
    -- player = playerobj.new()

    -- create a new level
    newlevel()
end

function newlevel()
    -- create board
    board = boardobj.new()

    -- init piece!
    piece = pieceobj.new()
    piece:reset()
end