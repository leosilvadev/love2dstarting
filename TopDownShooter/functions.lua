

function distanceBetween(objectOne, objectTwo)
    return math.sqrt((objectTwo.x - objectOne.x) ^ 2 + (objectTwo.y - objectOne.y) ^ 2)
end

function halfWidthSizeOf(image)
    return image:getWidth() / 2
end

function halfHeightSizeOf(image)
    return image:getHeight() / 2
end

function moveTo(object, objectImage, coordinates)
    if coordinates.x >= halfWidthSizeOf(objectImage) and
        coordinates.y >= halfHeightSizeOf(objectImage) + 100 and
        coordinates.x < love.graphics.getWidth() - halfWidthSizeOf(objectImage) and
        coordinates.y < love.graphics.getHeight() - halfHeightSizeOf(objectImage) then
            object.x = coordinates.x
            object.y = coordinates.y
    end
end

function playMouseAngle()
    return math.atan2(love.mouse.getY() - Player:get().y, love.mouse.getX() - Player:get().x)
end

return {
    distanceBetween = distanceBetween,
    halfWidthSizeOf = halfWidthSizeOf,
    halfHeightSizeOf = halfHeightSizeOf,
    moveTo = moveTo,
    playMouseAngle = playMouseAngle
}