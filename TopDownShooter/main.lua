local Zombie = require('zombie')

function love.conf(t)
    t.console = true
end

function love.load()
    images = {
        background = love.graphics.newImage('images/background.png'),
        bullet = love.graphics.newImage('images/bullet.png'),
        player = love.graphics.newImage('images/player.png'),
        zombie = Zombie.loadImage(),
        rip = love.graphics.newImage('images/rip.png')
    }

    sounds = {
        shoot = love.audio.newSource("sounds/shoot.wav", "static"),
        manScream = love.audio.newSource("sounds/scream.mp3", "static"),
        manSteps = love.audio.newSource("sounds/man_steps.mp3", "static")
    }

    sounds.manSteps:setVolume(0.2)

    player = {
        x = halfWidthSizeOf(love.graphics),
        y = halfHeightSizeOf(love.graphics),
        rotation = 0,
        speed = 180,
        dead = false,
        screamed = false
    }

    bullets = {}
end

function love.update(dt)
    if player.dead then
        for index, bullet in ipairs(bullets) do
            table.remove(bullets, index)
        end
        return
    end

    if love.keyboard.isDown('d') or
        love.keyboard.isDown('a') or
        love.keyboard.isDown('s') or
        love.keyboard.isDown('w') then
        sounds.manSteps:play()
    else
        sounds.manSteps:stop()
    end

    if love.keyboard.isDown('d') then
        local newPosition = player.x + player.speed * dt
        moveTo(player, images.player, {x = newPosition, y = player.y})

        if love.keyboard.isDown('s') then
            player.rotation = player.rotation + 0.05
        end
        if love.keyboard.isDown('w') then
            player.rotation = player.rotation - 0.05
        end
    end
        
    if love.keyboard.isDown('a') then
        local newPosition = player.x - player.speed * dt
        moveTo(player, images.player, {x = newPosition, y = player.y})

        if love.keyboard.isDown('s') then
            player.rotation = player.rotation + 0.05
        end
        if love.keyboard.isDown('w') then
            player.rotation = player.rotation - 0.05
        end
    end

    if love.keyboard.isDown('s') then
        local newPosition = player.y + player.speed * dt
        moveTo(player, images.player, {x = player.x, y = newPosition})
    end

    if love.keyboard.isDown('w') then
        local newPosition = player.y - player.speed * dt
        moveTo(player, images.player, {x = player.x, y = newPosition})
    end

    Zombie.moveAllInDirectionOf(player, dt)
    if Zombie.anyMustKill(player) then
        player.dead = true
    end

    for index, bullet in ipairs(bullets) do
        bullet.x = bullet.x + (math.cos(bullet.direction) * bullet.speed * dt)
        bullet.y = bullet.y + (math.sin(bullet.direction) * bullet.speed * dt)
    end

    for zombieKey, aZombie in ipairs(Zombie.all()) do
        local die, bulletIndex = Zombie.mustDie(aZombie, bullets)
        if die then
            table.remove(bullets, bulletIndex)
            Zombie.die(zombieKey)
        end
    end
end

function love.draw()
    love.graphics.draw(images.background, 0, 0)

    if player.dead then
        if player.screamed == false then
            player.screamed = true
            sounds.manSteps:stop()
            sounds.manScream:play()
        end
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
            player.x, 
            player.y, 
            playMouseAngle(), 
            nil, nil, 
            halfWidthSizeOf(images.player), 
            halfHeightSizeOf(images.player)
        )
    end

    for _, aZombie in ipairs(Zombie.all()) do
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
    if player.dead then
        return
    end

    if key == 'space' then
        Zombie.spawn()
    end
end

function love.mousepressed(x, y, button, isTouched)
    if player.dead then
        return
    end

    if button == 1 then
        spawnBullet()
        sounds.shoot:play()
    end
end

function moveTo(object, objectImage, coordinates)
    if coordinates.x >= halfWidthSizeOf(objectImage) and
        coordinates.y >= halfHeightSizeOf(objectImage) and
        coordinates.x < love.graphics.getWidth() - halfWidthSizeOf(objectImage) and
        coordinates.y < love.graphics.getHeight() - halfHeightSizeOf(objectImage) then
            object.x = coordinates.x
            object.y = coordinates.y
    end
end

function zombieAngle(aZombie)
    return math.atan2(player.y - aZombie.y, player.x - aZombie.x)
end

function playMouseAngle()
    return math.atan2(love.mouse.getY() - player.y, love.mouse.getX() - player.x)
end

function distanceBetween(objectOne, objectTwo)
    return math.sqrt((objectTwo.x - objectOne.x) ^ 2 + (objectTwo.y - objectOne.y) ^ 2)
end

function spawnBullet()
    local bullet = {
        x = player.x,
        y = player.y,
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
