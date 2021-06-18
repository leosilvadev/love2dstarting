require('functions')

local player = {
    x = halfWidthSizeOf(love.graphics),
    y = halfHeightSizeOf(love.graphics),
    rotation = 0,
    speed = 180,
    status = "alive",
    screamed = false
}

function get()
    return player
end

function isDead()
    return player.status == "dead"
end

function isDying()
    return player.status == "dying"
end

function die()
    player.status = "dead"
end

function startToDie()
    player.status = "dying"
end

function loadImage()
    return love.graphics.newImage('images/player.png')
end

function moveRight(dt)
    local newPosition = player.x + player.speed * dt
    moveTo(player, images.player, {x = newPosition, y = player.y})
end

function moveLeft(dt)
    local newPosition = player.x - player.speed * dt
    moveTo(player, images.player, {x = newPosition, y = player.y})
end

function moveDown(dt)
    local newPosition = player.y + player.speed * dt
    moveTo(player, images.player, {x = player.x, y = newPosition})
end

function moveTop(dt)
    local newPosition = player.y - player.speed * dt
    moveTo(player, images.player, {x = player.x, y = newPosition})
end

return {
    get = get,
    isDead = isDead,
    isDying = isDying,
    die = die,
    startToDie = startToDie,
    loadImage = loadImage,
    moveRight = moveRight,
    moveLeft = moveLeft,
    moveDown = moveDown,
    moveTop = moveTop
}