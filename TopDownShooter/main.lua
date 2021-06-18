local Zombie = require('zombie')
local Player = require('player')

function love.conf(t)
    t.console = true
end

function love.load()
    images = {
        background = love.graphics.newImage('images/background.png'),
        bullet = love.graphics.newImage('images/bullet.png'),
        player = Player:loadPlayerImage(),
        rip = Player:loadRIPImage(),
        zombie = Zombie:loadImage()
    }

    sounds = {
        shoot = Player:loadShootSound(),
        manScream = Player:loadScreamSound(),
        manSteps = Player:loadStepsSound()
    }

    bullets = {}
end

function love.update(dt)
    if Player:isDying() then
        Player:die()
    end

    if Player:isDead() then
        for index, bullet in ipairs(bullets) do
            table.remove(bullets, index)
        end
        return
    end

    if isMovingRight() or
        isMovingLeft() or
        isMovingDown() or
        isMovingTop() then
        sounds.manSteps:play()
    else
        sounds.manSteps:stop()
    end

    if isMovingRight() then
        Player:moveRight(dt)
    end
        
    if isMovingLeft() then
        Player:moveLeft(dt)
    end

    if isMovingDown() then
        Player:moveDown(dt)
    end

    if isMovingTop() then
        Player:moveTop(dt)
    end

    Zombie:moveAllInDirectionOf(Player:get(), dt)
    if Zombie:anyMustKill(Player:get()) then
        Player:startToDie()
    end

    for index, bullet in ipairs(bullets) do
        bullet.x = bullet.x + (math.cos(bullet.direction) * bullet.speed * dt)
        bullet.y = bullet.y + (math.sin(bullet.direction) * bullet.speed * dt)
    end

    for zombieKey, aZombie in ipairs(Zombie:all()) do
        local die, bulletIndex = Zombie:mustDie(aZombie, bullets)
        if die then
            table.remove(bullets, bulletIndex)
            Zombie:die(zombieKey)
            Zombie:loadDieSound():play()
        end
    end
end

function love.draw()
    love.graphics.draw(images.background, 0, 0)
    love.graphics.setColor(33, 209, 14)
    love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), 100)

    if Player:isDying() then
        sounds.manSteps:stop()
        sounds.manScream:play()
        return
    end

    if Player:isDead() then
        love.graphics.setColor(255, 255, 255, 128)
        love.graphics.draw(
            images.rip, 
            (love.graphics.getWidth() - images.rip:getWidth() / 2) / 2, 
            (love.graphics.getHeight() - images.rip:getHeight() / 2) / 2, 
            nil, 0.5, 0.5
        )
        return
    else
        love.graphics.draw(
            images.player, 
            Player:get().x, 
            Player:get().y, 
            playMouseAngle(), 
            nil, nil, 
            halfWidthSizeOf(images.player), 
            halfHeightSizeOf(images.player)
        )
    end

    for _, aZombie in ipairs(Zombie:all()) do
        love.graphics.draw(
            images.zombie,
            aZombie.x,
            aZombie.y,
            zombieAngle(aZombie),
            nil, nil,
            halfWidthSizeOf(images.zombie), 
            halfHeightSizeOf(images.zombie)
        )
    end

    for index, bullet in ipairs(bullets) do
        love.graphics.draw(
            images.bullet,
            bullet.x,
            bullet.y,
            nil, 0.5, 0.5,
            halfWidthSizeOf(images.bullet), 
            halfHeightSizeOf(images.bullet)
        )
    end
end

function love.keypressed(key)
    if Player:get().dead then
        return
    end

    if key == 'space' then
        Zombie:spawn()
    end
end

function love.mousepressed(x, y, button, isTouched)
    if Player:get().dead then
        return
    end

    if button == 1 then
        spawnBullet()
        sounds.shoot:play()
    end
end

function isMovingRight() return love.keyboard.isDown('d') end

function isMovingDown() return love.keyboard.isDown('s') end

function isMovingLeft() return love.keyboard.isDown('a') end

function isMovingTop() return love.keyboard.isDown('w') end

function zombieAngle(aZombie)
    return math.atan2(Player:get().y - aZombie.y, Player:get().x - aZombie.x)
end

function playMouseAngle()
    return math.atan2(love.mouse.getY() - Player:get().y, love.mouse.getX() - Player:get().x)
end

function distanceBetween(objectOne, objectTwo)
    return math.sqrt((objectTwo.x - objectOne.x) ^ 2 + (objectTwo.y - objectOne.y) ^ 2)
end

function spawnBullet()
    local bullet = {
        x = Player:get().x,
        y = Player:get().y,
        speed = 500,
        direction = playMouseAngle()
    }
    table.insert(bullets, bullet)
end

function isOutOfScene(object)
    return object.x < 0 or object.x > love.graphics.getWidth() or object.y < 0 or object.y > love.graphics.getHeight()
end

function halfWidthSizeOf(image)
    return image:getWidth() / 2
end

function halfHeightSizeOf(image)
    return image:getHeight() / 2
end