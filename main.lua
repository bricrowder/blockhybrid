-- load objects
local json = require "dkjson"       -- see dkjson.lua for author and licence
local pieceobj = require "piece"
local boardobj = require "board"

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
        -- check for lines!
        board:checkForLines()        

        -- list of pieces to be removed
        local toremove = {}
        -- update piece positions
        if not(lost) then
            for i, v in ipairs(pieces) do
                v:update(dt)
                -- see if it has been flagged for removal
                if v.remove then
                    table.insert(toremove, i)
                end
            end

            -- remove any that are flagged
            for i=#toremove, 1, -1 do
                table.remove(pieces, toremove[i])
            end

            -- spawn new pieces
            spawncounter = spawncounter + dt
            if spawncounter >= config.pieces.spawn then
                -- reset accounting for any time that it went over
                spawncounter = spawncounter - config.pieces.spawn
                -- create a new piece!
                table.insert(pieces, pieceobj.new())
            end
        end
    end
end

function love.draw()
    if gamestate == "game" then
        -- draw background
        board:drawBackground()
        -- draw pieces
        for i, v in ipairs(pieces) do
            v:drawShadow()
            v:draw()
        end
        -- draw landed board peices
        board:drawBoard()
    end
end

-- inits everything for a new game
function newgame()
    -- set starting game state
    gamestate = "game"
    -- lost status
    lost = false
    -- create a new level
    newlevel()
end

function newlevel()
    -- create board
    board = boardobj.new()
    -- init piece list
    pieces = {}
    -- spawn counter
    spawncounter = 0
end