function love.load()
    images = {
        background = love.graphics.newImage('images/background.png'),
        bullet = love.graphics.newImage('images/bullet.png'),
        player = love.graphics.newImage('images/player.png'),
        zombie = love.graphics.newImage('images/zombie.png')
    }

    sounds = {
        shoot = love.audio.newSource("sounds/shoot.wav", "static"),
        zombieDie = love.audio.newSource("sounds/zombie_die.wav", "static")
    }

    player = {
        x = love.graphics.getWidth() / 2,
        y = love.graphics.getHeight() / 2,
        rotation = 0,
        speed = 180
    }

    zombies = {}

    bullets = {}
end

function love.update(dt)
    if love.keyboard.isDown('d') then
        player.x = player.x + player.speed * dt
        if love.keyboard.isDown('s') then
            player.rotation = player.rotation + 0.05
        end
        if love.keyboard.isDown('w') then
            player.rotation = player.rotation - 0.05
        end
    end
        
    if love.keyboard.isDown('a') then
        player.x = player.x - player.speed * dt
        if love.keyboard.isDown('s') then
            player.rotation = player.rotation + 0.05
        end
        if love.keyboard.isDown('w') then
            player.rotation = player.rotation - 0.05
        end
    end

    if love.keyboard.isDown('s') then
        player.y = player.y + player.speed * dt
    end

    if love.keyboard.isDown('w') then
        player.y = player.y - player.speed * dt
    end

    for index, zombie in ipairs(zombies) do
        zombie.x = zombie.x + (math.cos(zombieAngle(zombie)) * zombie.speed * dt)
        zombie.y = zombie.y + (math.sin(zombieAngle(zombie)) * zombie.speed * dt)
    end

    for index, bullet in ipairs(bullets) do
        bullet.x = bullet.x + (math.cos(bullet.direction) * bullet.speed * dt)
        bullet.y = bullet.y + (math.sin(bullet.direction) * bullet.speed * dt)
    end

    for index=#bullets, 1, -1 do
        local bullet = bullets[index]
        if isOutOfScene(bullet) then
            table.remove(bullets, index)
        end

        for zombieKey, zombie in ipairs(zombies) do
            if distanceBetween(bullet, zombie) < 20 then
                table.remove(bullets, index)
                table.remove(zombies, zombieKey)
                sounds.zombieDie:play()
            end 
        end
    end
end

function love.draw()
    love.graphics.draw(images.background, 0, 0)
    love.graphics.draw(
        images.player, 
        player.x, 
        player.y, 
        playMouseAngle(), 
        nil, nil, 
        images.player:getWidth() / 2, 
        images.player:getHeight() / 2
    )

    for index, zombie in ipairs(zombies) do
        love.graphics.draw(
            images.zombie,
            zombie.x,
            zombie.y,
            zombieAngle(zombie),
            nil, nil,
            images.zombie:getWidth() / 2, 
            images.zombie:getHeight() / 2
        )
        if  distanceBetween(zombie, player) < 30 then
            for index, value in ipairs(zombies) do
                table.remove(zombies, index)
            end
        end
    end

    for index, bullet in ipairs(bullets) do
        if bullet.x > 0 and bullet.y > 0 then
            
        end
        love.graphics.draw(
            images.bullet,
            bullet.x,
            bullet.y,
            nil, 0.5, 0.5,
            images.bullet:getWidth() / 2, 
            images.bullet:getHeight() / 2
        )
    end
end

function love.keypressed(key)
    if key == 'space' then
        spawnZombie()
    end
end

function love.mousepressed(x, y, button, isTouched)
    if button == 1 then
        spawnBullet()
        sounds.shoot:play()
    end
end

function zombieAngle(zombie)
    return math.atan2(player.y - zombie.y, player.x - zombie.x)
end

function playMouseAngle()
    return math.atan2(love.mouse.getY() - player.y, love.mouse.getX() - player.x)
end

function spawnZombie()
    local zombie = {
        x = math.random(1, love.graphics.getWidth()),
        y = math.random(1, love.graphics.getHeight()),
        speed = 100
    }
    table.insert(zombies, zombie)
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