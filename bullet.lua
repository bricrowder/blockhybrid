local bullet = {}
bullet.__index = bullet

-- create a new bullet spawn
function bullet.new(angle, x, y, index)
    local b = {}
    setmetatable(b, bullet)
    -- set everything
    b.index = index
    b.angle = angle
    b.x = x
    b.y = y
    -- init removal flag
    b.remove = false

    return b
end

function bullet:update(dt)
    -- update position
    self.x = self.x + math.cos(self.angle) * config.bullets[self.index].speed * dt
    self.y = self.y + math.sin(self.angle) * config.bullets[self.index].speed * dt

    -- check for bounds removal

    -- check for piece collision

end

function bullet:draw()
    love.graphics.circle("fill", self.x, self.y, config.bullets[self.index].size)
end

return bullet