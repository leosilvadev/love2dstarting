require('functions')

local zombies = {}
local dieSound = love.audio.newSource("sounds/zombie_die.wav", "static")

function loadImage()
    return love.graphics.newImage('images/zombie.png')
end

function spawn()
    local zombie = {
        x = math.random(1, love.graphics.getWidth()),
        y = math.random(1, love.graphics.getHeight()),
        speed = 100
    }
    table.insert(zombies, zombie)
end

function all()
    return zombies
end

function mustDie(zombie, bullets)
    local die = false
    local bulletIdexToDestroy = nil
    for index=#bullets, 1, -1 do
        local bullet = bullets[index]

        if distanceBetween(zombie, bullet) < 20 then
            die = true
            bulletIdexToDestroy = index
            break
        end
    end
    return die, bulletIdexToDestroy
end

function anyMustKill(player)
    for _, zombie in ipairs(zombies) do
        if distanceBetween(zombie, player) < 30 then
            return true
        end
    end
    return false
end

function die(zombieKey)
    table.remove(zombies, zombieKey)
    dieSound:play()
end

function moveAllInDirectionOf(player, dt)
    for _, zombie in ipairs(zombies) do
        zombie.x, zombie.y = move(zombie, player, dt)
    end
end

function move(zombie, player, dt)
    local newX = zombie.x + (math.cos(zombieAngleFrom(zombie, player)) * zombie.speed * dt)
    local newY = zombie.y + (math.sin(zombieAngleFrom(zombie, player)) * zombie.speed * dt)
    return newX, newY
end

function zombieAngleFrom(aZombie, player)
    return math.atan2(player.y - aZombie.y, player.x - aZombie.x)
end

return {
    loadImage = loadImage,
    spawn = spawn,
    all = all,
    mustDie = mustDie,
    die = die,
    moveAllInDirectionOf = moveAllInDirectionOf,
    anyMustKill = anyMustKill
}