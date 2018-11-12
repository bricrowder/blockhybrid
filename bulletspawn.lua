local bulletspawn = {}
bulletspawn.__index = bulletspawn

-- create a new bullet spawn
function bulletspawn.new(x, y)
    local b = {}
    setmetatable(b, bulletspawn)

    -- current position on the board
    b.x = x
    b.y = y

    -- holds the list of bullets
    b.bullets = {}

    -- index to the bullet type
    b.index = math.random(1, #config.bullets)

    -- spawn counter
    b.spawncounter = 0

    -- base angle tracker
    b.baseangle = 0

    return b
end

function bulletspawn:update(dt)
    -- holds any bullets that should go away
    local toremove = {}

    -- update all bullets
    for i, v in ipairs(self.bullets) do
        v:update(dt)
        if v.remove then
            table.insert(toremove, i)
        end
    end

    -- remove any flagged ones
    for i=#toremove, 1, -1 do
        table.remove(self.bullets, toremove[i])
    end

    -- create new bullets if you have hit the bullets firing rate
    self.spawncounter = self.spawncounter + dt
    if self.spawncounter >= config.bullets[self.index].rate then
        self.spawncounter = self.spawncounter - config.bullets[self.index].rate
        for i=1, #config.bullets[self.index].angles, 1 do
            -- calculate real work x, y
            local x = self.x * config.board.size - config.board.size/2
            local y = self.y * config.board.size - config.board.size/2
            -- create sending bullet angle, position, bullet index
            table.insert(self.bullets, bulletobj.new(config.bullets[self.index].angles[i] + self.baseangle, x, y, self.index))
        end
    end

    -- rotation the base angle if necessary... 
    if config.bullets[self.index].rotation > 0 then
        self.baseangle = self.baseangle + (dt * config.bullets[self.index].rotation)
        -- just keep it set back to math.pi range to keep my mind straight
        if self.baseangle > math.pi*2 then
            self.baseangle = self.baseangle - math.pi*2
        elseif self.baseangle < 0 then
            self.baseangle = math.pi*2 + self.baseangle
        end
    end
end

function bulletspawn:draw()
    -- draw all bullets
    for i, v in ipairs(self.bullets) do
        v:draw()
    end
end

function bulletspawn:setPosition(x, y)
    self.x = x
    self.y = y
end

return bulletspawn