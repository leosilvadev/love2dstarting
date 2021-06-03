function love.load()
    target = {
        x = 300,
        y = 300,
        radius = 50
    }

    game = {
        score = 0,
        timer = 0,
        state = 1,
        font = love.graphics.newFont(40)
    }

    sprites = {
        sky = love.graphics.newImage("sprites/sky.png"),
        crosshairs = love.graphics.newImage("sprites/crosshairs.png"),
        target = love.graphics.newImage("sprites/target.png")
    }

    sounds = {
        shoot = love.audio.newSource("sounds/shoot.wav", "static"),
        strongShoot = love.audio.newSource("sounds/strong_shoot.wav", "static"),
        targetHit = love.audio.newSource("sounds/target_hit.wav", "static")
    }

    love.mouse.setVisible(false)
end

function love.update(dt)
    if playing() then
        if game.timer > 0 then
            game.timer = game.timer - dt
        end
        if game.timer < 0 then 
            game.timer = 0
            game.state = 1
            game.score = 0
        end 
    end
end

function love.draw()
    love.graphics.draw(sprites.sky, 0, 0)

    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(game.font)
    love.graphics.print("Score: " .. game.score, 0, 0)
    love.graphics.print("Timer: " .. math.ceil(game.timer), 300, 0)

    if not playing() then
        love.graphics.printf("Click anywhere to begin!", 0, 250, love.graphics.getWidth(), "center")
    end

    if playing() then
        love.graphics.draw(sprites.target, target.x - target.radius, target.y - target.radius + 10)
    end

    love.graphics.draw(sprites.crosshairs, love.mouse.getX() - 20, love.mouse.getY() - 20) 
end

function love.mousepressed(x, y, button, istouch, presses)
    if playing() and (button == 1 or button == 2) then
        local mouseToTarget = distanceBetween(x, y, target.x, target.y)
        local plusScore = 1
        local failedSound = sounds.shoot

        if button == 2 then
            plusScore = 2
            failedSound = sounds.strongShoot
        end

        if mouseToTarget < target.radius then
            game.score = game.score + plusScore
            target.x = math.random(target.radius, love.graphics.getWidth() - target.radius)
            target.y = math.random(target.radius, love.graphics.getHeight() - target.radius)
            
            sounds.targetHit:play()
        else
            game.score = game.score > 0 and game.score -1 or 0
            failedSound:play()
        end
    elseif not playing() and button == 1 then
        game.state = 2
        game.timer = 10
        game.score = 0
    end
end

function playing() return game.state == 2 end

function distanceBetween(x1, y1, x2, y2)
    return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end