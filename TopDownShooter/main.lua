require('functions')

local Zombie = require('zombie')
local Player = require('player')
local Bullet = require('bullet')
local game = {
    zombiesKilled = 0,
    headerFontTitle = love.graphics.newFont(34)
}

function love.conf(t)
    t.console = true
end

function love.load()
    game.images = {
        background = love.graphics.newImage('images/background.png'),
        bullet = Bullet:loadImage(),
        player = Player:loadPlayerImage(),
        rip = Player:loadRIPImage(),
        zombie = Zombie:loadImage()
    }

    game.sounds = {
        shoot = Player:loadShootSound(),
        manScream = Player:loadScreamSound(),
        manSteps = Player:loadStepsSound()
    }
end

function love.update(dt)
    if Player:isDying() then
        Player:die()
    end

    if Player:isDead() then
        Bullet:removeAll()
        return
    end

    if isMovingRight() or
        isMovingLeft() or
        isMovingDown() or
        isMovingTop() then
        game.sounds.manSteps:play()
    else
        game.sounds.manSteps:stop()
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

    Bullet:moveAll(dt)

    for zombieKey, aZombie in ipairs(Zombie:all()) do
        local die, bulletIndex = Zombie:mustDie(aZombie, Bullet:all())
        if die then
            Bullet:remove(bulletIndex)
            Zombie:die(zombieKey)
            game.zombiesKilled = game.zombiesKilled + 1
            Zombie:loadDieSound():play()
        end
    end
end

function love.draw()
    love.graphics.draw(game.images.background, 0, 0)

    love.graphics.setFont(game.headerFontTitle)
    love.graphics.print("Killed", 20, 10)
    
    if game.zombiesKilled < 10 then
        love.graphics.print(game.zombiesKilled, 55, 50)
    elseif game.zombiesKilled < 100 then
        love.graphics.print(game.zombiesKilled, 45, 50)
    end

    if Player:isDying() then
        game.sounds.manSteps:stop()
        game.sounds.manScream:play()
        return
    end

    if Player:isDead() then
        love.graphics.setColor(255, 255, 255, 128)
        love.graphics.draw(
            game.images.rip, 
            (love.graphics.getWidth() - game.images.rip:getWidth() / 2) / 2, 
            (love.graphics.getHeight() - game.images.rip:getHeight() / 2) / 2, 
            nil, 0.5, 0.5
        )
        return
    else
        love.graphics.draw(
            game.images.player, 
            Player:get().x, 
            Player:get().y, 
            playMouseAngle(), 
            nil, nil, 
            halfWidthSizeOf(game.images.player), 
            halfHeightSizeOf(game.images.player)
        )
    end

    for _, aZombie in ipairs(Zombie:all()) do
        love.graphics.draw(
            game.images.zombie,
            aZombie.x,
            aZombie.y,
            zombieAngle(aZombie),
            nil, nil,
            halfWidthSizeOf(game.images.zombie), 
            halfHeightSizeOf(game.images.zombie)
        )
    end

    for index, bullet in ipairs(Bullet:all()) do
        love.graphics.draw(
            game.images.bullet,
            bullet.x,
            bullet.y,
            nil, 0.5, 0.5,
            halfWidthSizeOf(game.images.bullet), 
            halfHeightSizeOf(game.images.bullet)
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
        Player:shoot(500)
        game.sounds.shoot:play()
    end
end

function isMovingRight() return love.keyboard.isDown('d') end

function isMovingDown() return love.keyboard.isDown('s') end

function isMovingLeft() return love.keyboard.isDown('a') end

function isMovingTop() return love.keyboard.isDown('w') end

function zombieAngle(aZombie)
    return math.atan2(Player:get().y - aZombie.y, Player:get().x - aZombie.x)
end

function distanceBetween(objectOne, objectTwo)
    return math.sqrt((objectTwo.x - objectOne.x) ^ 2 + (objectTwo.y - objectOne.y) ^ 2)
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