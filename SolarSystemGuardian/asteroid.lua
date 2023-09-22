require('functions')

local asteroids = {}
local sounds = {
}

local images = {
    asteroid = love.graphics.newImage('images/asteroid.png'),
    explosions = love.graphics.newImage('images/explosion3.png'),
}

local sounds = {
    explosion = love.audio.newSource("sounds/explosion.wav", "static"),
}

function spawn()
    local asteroid = {
        x = math.random(1, love.graphics.getWidth()),
        y = 0,
        speed = 50
    }
    table.insert(asteroids, asteroid)
end

function initialImage()
    return images.asteroid
end

function all()
    return asteroids
end

function mustDestroy(asteroid, shots)
    local destroy = false
    local shotIndexToDestroy = nil
    for index=#shots, 1, -1 do
        local shot = shots[index]

        if distanceBetween(asteroid, shot) < 40 then
            destroy = true
            shotIndexToDestroy = index
            break
        end
    end
    return destroy, shotIndexToDestroy
end

function anyMustDestroy(player)
    for _, asteroid in ipairs(asteroids) do
        if distanceBetween(asteroid, player) < 30 then
            return true
        end
    end
    return false
end

function destroy(asteroidKey)
    table.remove(asteroids, asteroidKey)
    sounds.explosion:play()
end

function moveAllInDirectionOf(player, dt)
    for _, asteroid in ipairs(asteroids) do
        asteroid.x, asteroid.y = move(asteroid, player, dt)
    end
end

function moveAllAt(speed)
    for _, asteroid in ipairs(asteroids) do
        asteroid.y = asteroid.y + speed
    end 
end

function move(asteroid, player, dt)
    local newX = asteroid.x + (math.cos(asteroidAngleFrom(asteroid, player)) * asteroid.speed * dt)
    local newY = asteroid.y + (math.sin(asteroidAngleFrom(asteroid, player)) * asteroid.speed * dt)
    return newX, newY
end

function asteroidAngleFrom(asteroid, player)
    return math.atan2(player.y - asteroid.y, player.x - asteroid.x)
end

return {
    initialImage = initialImage,
    spawn = spawn,
    all = all,
    mustDestroy = mustDestroy,
    destroy = destroy,
    anyMustDestroy = anyMustDestroy,
    moveAllInDirectionOf = moveAllInDirectionOf,
    moveAllAt = moveAllAt,
    anyMustKill = anyMustKill
}