local player = {}
player.__index = player


-- create a new player
function player.new()
    local p = {}
    setmetatable(p, player)

    -- set starting position
    p.x = config.board.width * config.board.size / 2
    p.y = config.board.height * config.board.size - 4 * config.board.size

    -- shooting flag/counters
    p.canshoot = true
    p.shoottimer = 0

    -- bullets list
    p.bullets = {}

    -- current gun type...
    p.bullettype = "normal"

    return p
end

function player:update(dt)
    -- get movement input
    -- if love.keyboard.isDown("left") then
    --     self.x = self.x - config.player.speed * dt
    --     if self.x < 16 then
    --         self.x = 16
    --     end
    -- elseif love.keyboard.isDown("right") then
    --     self.x = self.x + config.player.speed * dt
    --     if self.x > config.board.width * config.board.size - 16 then
    --         self.x = config.board.width * config.board.size - 16
    --     end
    -- end

    -- get shooting input
    -- if love.keyboard.isDown("space") and self.canshoot then
    --     -- reset the shooting timer stuff
    --     self.canshoot = false
    --     self.shoottimer = 0

    --     -- create a bullet!
    --     table.insert(self.bullets, {x=self.x, y=self.y, type="normal"})
    -- end

    -- -- get shooting input
    -- if love.keyboard.isDown("x") and self.canshoot then
    --     -- reset the shooting timer stuff
    --     self.canshoot = false
    --     self.shoottimer = 0

    --     -- create a bullet!
    --     table.insert(self.bullets, {x=self.x, y=self.y, type="rotate"})
    -- end


    -- update shooting timer
    if not(self.canshoot) then
        self.shoottimer = self.shoottimer + dt
        if self.shoottimer >= config.bullet.spawn then
            self.canshoot = true
        end
    end

    -- for bullet removal
    local toremove = {}

    -- update bullets!
    for i, v in ipairs(self.bullets) do
        -- move it
        v.y = v.y - config.bullet.speed * dt

        -- check for out of bounds
        if v.y < -16 then
            table.insert(toremove, i)
        end

        -- calc the board position of the bullet
        local gx = math.floor(v.x / config.board.size) + 1
        local gy = math.floor(v.y / config.board.size) + 1
        -- check for piece collision
        for j, k in ipairs(pieces) do
            local p = piecedata[k.index].data[k.rotation]
            -- loop through the piece and see if the bullet is hitting it
            for m=1, #p, 1 do
                -- flag if we found something and are breaking out of the for loops
                local brk = false
                for n=1, #p[m], 1 do
                    if p[m][n] then
                        local px = k.x + n
                        local py = k.y + m 
                        -- bullet in cell - check 0 or -1 y to be a bit of a simple temporal collision check?
                        if px == gx and (py == gy or py-1 == gy) then
                            -- add to bullet removal table
                            table.insert(toremove, i)
                            -- action based on bullet type
                            if v.type == "normal" then
                                -- flag piece
                                k.remove = true
                                brk = true
                                break
                            elseif v.type == "rotate" then
                                k:rotate()
                            end
                        end
                    end
                end
                if brk then
                    break
                end
            end
        end
    end

    -- remove any!
    for i=#toremove, 1, -1 do
        table.remove(self.bullets, toremove[i])
    end
end

-- draw player and bullets
function player:draw()
    love.graphics.circle("fill", self.x, self.y, 16)
    for i, v in ipairs(self.bullets) do
        love.graphics.circle("fill", v.x, v.y, 4)    
    end
end

-- get the highest point on the board and adjust player y if necessary
function player:sendHighest(h)
    local gy = self.y / config.board.size + 1
    if h <= gy then
        self.y = (h-2) * config.board.size
    end
end

return player