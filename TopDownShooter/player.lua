require('functions')

Player = {
    x = halfWidthSizeOf(love.graphics),
    y = halfHeightSizeOf(love.graphics),
    rotation = 0,
    speed = 180,
    status = "alive",
    screamed = false
}

function Player:get()
    return self
end

function Player:isDead()
    return self.status == "dead"
end

function Player:isDying()
    return self.status == "dying"
end

function Player:die()
    self.status = "dead"
end

function Player:startToDie()
    self.status = "dying"
end

function Player:loadPlayerImage()
    return love.graphics.newImage('images/player.png')
end

function Player:loadRIPImage()
    return love.graphics.newImage('images/rip.png')
end

function Player:loadStepsSound()
    local sound = love.audio.newSource("sounds/man_steps.mp3", "static")
    sound:setVolume(0.2)
    return sound
end

function Player:loadScreamSound()
    return love.audio.newSource("sounds/scream.mp3", "static")
end

function Player:loadShootSound()
    return love.audio.newSource("sounds/shoot.wav", "static")
end

function Player:moveRight(dt)
    local newPosition = self.x + self.speed * dt
    moveTo(self, images.player, {x = newPosition, y = self.y})
end

function Player:moveLeft(dt)
    local newPosition = self.x - self.speed * dt
    moveTo(self, images.player, {x = newPosition, y = self.y})
end

function Player:moveDown(dt)
    local newPosition = self.y + self.speed * dt
    moveTo(self, images.player, {x = self.x, y = newPosition})
end

function Player:moveTop(dt)
    local newPosition = self.y - self.speed * dt
    moveTo(self, images.player, {x = self.x, y = newPosition})
end

return Player