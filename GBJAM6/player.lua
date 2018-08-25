local player = {}

-- I fucking HATE that the position is stored three times

player.position = vec3(0, 0, 0)
player.velocity = vec3(0, 0, 0)

player.transform = kaun.newTransform()
player.cameraTransform = kaun.newTransform()

setmetatable(player, {__index = function(tbl, key)
    if player.transform[key] then
        return function(...)
            return player.transform[key](player.transform, ...)
        end
    end
end})

-- http://flafla2.github.io/2015/02/14/bunnyhop.html
function player.accelerate(dt, dir, acceleration, maxVelocity)
    local projVel = player.velocity:dot(dir)
    local accelVel = acceleration * dt
    if projVel + accelVel > maxVelocity then
        accelVel = math.max(0, maxVelocity - projVel)
    end
    player.velocity = player.velocity + dir * accelVel
end

function player.moveGround(dt, dir)
    local friction = 4.0
    local groundAcceleration = 20.0
    local groundMaxVelocity = 5.0
    player.velocity = player.velocity * math.max(0, 1.0 - friction * dt)
    player.accelerate(dt, dir, groundAcceleration, groundMaxVelocity)
end

function player.moveAir(dt, dir)
    local airAcceleration = 7.0
    local airMaxVelocity = 5.0
    player.accelerate(dt, dir, airAcceleration, airMaxVelocity)
end

function player.update(dt)
    local lk = love.keyboard

    -- jumping
    local jumpHeight = 1.0 -- S
    local jumpDuration = 0.4 -- T, just the time to get to the apex
    -- v(t) = v0 - g*t => s(t) = v0*t - 0.5*g*t^2
    -- v(T) = 0 <=> v0 = T/2*g
    -- S = s(T) = 0.5 * v0^2 / g <=> g = 0.5 * v0^2 / S
    -- => v0 = T * 0.5 * v0^2 / S <=> v0 = 2S/T
    -- => g = 2S/T^2
    local jumpVel = 2 * jumpHeight / jumpDuration
    local gravity = jumpVel / jumpDuration
    if lk.isDown("space") and player.onGround then
        player.velocity.y = jumpVel
        player.onGround = false
    end

    -- moving
    local move = vec3(0, 0, 0) -- in player space
    move.x = (lk.isDown("d") and 1 or 0) - (lk.isDown("a") and 1 or 0)
    move.z = (lk.isDown("s") and 1 or 0) - (lk.isDown("w") and 1 or 0)

    move = vec3(player.localDirToWorld(move.x, move.y, move.z))
    move.y = 0
    move = move:normalize()

    if player.onGround then
        player.moveGround(dt, move)
    else
        player.moveAir(dt, move)
    end
    local vx, vz = player.velocity.x, player.velocity.z

    -- gravity
    player.velocity.y = player.velocity.y - gravity * dt

    -- integration
    player.position = player.position + player.velocity * dt
    if player.position.y < 0 then
        player.velocity.y = 0
        player.position.y = 0
        player.onGround = true
    end
end

function player.look(dx, dy)
    local sensitity = 2.0
    player.rotateWorld(sensitity * dx, 0, 1, 0)
    player.rotate(sensitity * dy, 1, 0, 0)
end

function player.getCameraTransform()
    player.setPosition(player.position:unpack())

    player.cameraTransform:set(player.transform)
    local x, y, z = player.cameraTransform:getPosition()
    player.cameraTransform:setPosition(x, y + 1.0, z)
    return player.cameraTransform
end

return player
