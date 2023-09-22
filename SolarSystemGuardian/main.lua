local Asteroid = require('asteroid')

function love.conf(f)
    t.console = true
end

function love.load()
    images = {
        background = love.graphics.newImage('images/background_space.png'),
        ship = love.graphics.newImage('images/ship_green.PNG'),
        laserShot = love.graphics.newImage('images/laser.png')
    }

    backgroundYIndex = 0

    sounds = {
        game = love.audio.newSource("sounds/midnightexplosion.wav", "static"),
        laserShot = love.audio.newSource("sounds/laser.wav", "static"),
    }

    ship = {
        x = halfWidthSizeOf(love.graphics),
        y = halfHeightSizeOf(love.graphics),
        direction = 0,
        speed = 180
    }

    sounds.game:play()

    laserShots = {}

    lastAsteroidAt = os.time()

    isRunning = true
end

function love.update(dt)
    if backgroundYIndex > images.background:getHeight() then
        backgroundYIndex = 0
    else
        backgroundYIndex = backgroundYIndex + 2
    end

    if lastAsteroidAt < os.time() - 0.5 then
        lastAsteroidAt = os.time()
        Asteroid.spawn()
    end

    if love.keyboard.isDown('d') then
        local newPosition = ship.x + ship.speed * dt
        moveTo(ship, images.ship, {x = newPosition, y = ship.y})
    end
        
    if love.keyboard.isDown('a') then
        local newPosition = ship.x - ship.speed * dt
        moveTo(ship, images.ship, {x = newPosition, y = ship.y})

    end

    if love.keyboard.isDown('s') then
        local newPosition = ship.y + ship.speed * dt
        moveTo(ship, images.ship, {x = ship.x, y = newPosition})
    end

    if love.keyboard.isDown('w') then
        local newPosition = ship.y - ship.speed * dt
        moveTo(ship, images.ship, {x = ship.x, y = newPosition})
    end

    if love.keyboard.isDown('e') then
        ship.direction = ship.direction + 0.05
    end

    if love.keyboard.isDown('q') then
        ship.direction = ship.direction - 0.05
    end

    if Asteroid.anyMustDestroy(ship) then
        isRunning = false
    end

    Asteroid.moveAllAt(1)

    for asteroidIndex, anAsteroid in ipairs(Asteroid.all()) do
        local destroy, laserIndex = Asteroid.mustDestroy(anAsteroid, laserShots)
        if destroy then
            table.remove(laserShots, laserIndex)
            Asteroid.destroy(asteroidIndex)
        end
    end

    for index, laserShot in ipairs(laserShots) do
        laserShot.x = laserShot.x + (math.cos(laserShot.direction) * laserShot.speed * dt)
        laserShot.y = laserShot.y + (math.sin(laserShot.direction) * laserShot.speed * dt)
        if  laserShot.x > love.graphics.getWidth() or 
            laserShot.y > love.graphics.getHeight() or 
            laserShot.x < 0 or
            laserShot.y < 0 then
            table.remove(laserShots, index)
        end
    end
end

function love.draw()
    love.graphics.draw(images.background, 0, backgroundYIndex)

    if backgroundYIndex > 0 then
        love.graphics.draw(images.background, 0, (images.background:getHeight() - backgroundYIndex) * -1)
    end

    love.graphics.draw(
        images.ship, 
        ship.x, 
        ship.y, 
        ship.direction, 
        nil, nil, 
        halfWidthSizeOf(images.ship), 
        halfHeightSizeOf(images.ship)
    )

    for _, asteroid in ipairs(Asteroid.all()) do
        love.graphics.draw(
            Asteroid.initialImage(),
            asteroid.x,
            asteroid.y,
            asteroidAngle(asteroid),
            nil, nil,
            halfWidthSizeOf(Asteroid.initialImage()), 
            halfHeightSizeOf(Asteroid.initialImage())
        )
    end

    for index, laserShot in ipairs(laserShots) do
        love.graphics.draw(
            images.laserShot,
            laserShot.x,
            laserShot.y,
            laserShot.direction + 1.55, 
            0.5, 
            0.5,
            halfWidthSizeOf(images.laserShot), 
            halfHeightSizeOf(images.laserShot)
        )
    end
end

function asteroidAngle(asteroid)
    return math.atan2(ship.y - asteroid.y, ship.x - asteroid.x)
end

function love.keypressed(key)
    if key == 'space' then
        local laserShot = {
            x = ship.x,
            y = ship.y,
            direction = ship.direction - 1.55,
            speed = 180
        }
        table.insert(laserShots, laserShot)
        sounds.laserShot:play()
    end
end

function shoot()

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

function halfWidthSizeOf(image)
    return image:getWidth() / 2
end

function halfHeightSizeOf(image)
    return image:getHeight() / 2
end

function playMouseAngle()
    return math.atan2(love.mouse.getY() - ship.y, love.mouse.getX() - ship.x)
end