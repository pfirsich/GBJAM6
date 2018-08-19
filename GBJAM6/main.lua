-- 4 colors
-- 160x144 colors

kaun = require("kaun")

-- import these globally too
cpml = require("libs.cpml")
vec3 = cpml.vec3
mat4 = cpml.mat4

local shaders = require("shaders")
local player = require("player")

local gbaResW, gbaResH = 160, 144

local groundSize = 60
local groundMesh = kaun.newPlaneMesh(groundSize, groundSize, 1, 1)
local groundShader = kaun.newShader(shaders.defaultVertex, shaders.groundFrag)
local groundTrafo = kaun.newTransform()

local shader = kaun.newShader(shaders.defaultVertex, shaders.defaultColor)

local texture = kaun.newCheckerTexture(512, 512, 64)

local fsQuadFormat = kaun.newVertexFormat({"POSITION", 2, "F32"})
local fsQuad = kaun.newMesh("triangle_strip", fsQuadFormat,
                                    {{-1, -1}, { 1, -1}, {-1,  1}, { 1,  1}})
local fsQuadShader = kaun.newShader(shaders.fsQuadVert, shaders.fsQuadFrag)
local fsQuadState = kaun.newRenderState()
fsQuadState:setDepthTest("disabled")

local msaa = select(3, love.window.getMode()).msaa
colorTarget = kaun.newRenderTexture("rgba8", gbaResW, gbaResH)
colorTarget:setFilter("nearest", "nearest")
depthTarget = kaun.newRenderTexture("depth24", gbaResW, gbaResH)
colorTargetMS = kaun.newRenderTexture("rgba8", gbaResW, gbaResH, msaa)
depthTargetMS = kaun.newRenderTexture("depth24", gbaResW, gbaResH, msaa)

function love.resize(w, h)
    kaun.setProjection(45, w/h, 0.1, 100.0)
    kaun.setWindowDimensions(w, h)
end

function love.update(dt)
    player.update(dt)
end

function love.keypressed(key)
    if key == "escape" then
        love.mouse.setRelativeMode(false)
    end
end

function love.mousepressed(x, y, button)
    if button == 1 then
        love.mouse.setRelativeMode(true)
    end
end

function love.mousemoved(x, y, dx, dy)
    local winW, winH = love.graphics.getDimensions()
    if love.mouse.getRelativeMode() then
        player.look(dx / winW, dy / winH)
    end
end

function love.draw()
    kaun.setRenderTarget(colorTargetMS, depthTargetMS)
    kaun.clear()
    kaun.clearDepth()

    kaun.setViewTransform(player.getCameraTransform())

    kaun.setModelTransform(groundTrafo)
    kaun.draw(groundMesh, groundShader, {
        groundSize = groundSize,
        tileSize = 5.0,
        gapSize = 0.5,
    })

    -- resolve render target
    kaun.setRenderTarget(colorTarget, depthTarget, true)

    kaun.setRenderTarget()
    kaun.clear()
    local winW, winH = love.graphics.getDimensions()
    local scaleX = winW / gbaResW
    local scaleY = winH / gbaResH
    local scale = math.min(scaleX, scaleY)
    local vpOffset, vpScale
    if scaleX < scaleY then -- black bars on top/bottom
        vpScale = {1, scale * gbaResH / winH}
        vpOffset = {0, (1 - vpScale[2]) / 2.0}
    else -- black bars left/right
        vpScale = {scale * gbaResW / winW, 1}
        vpOffset = {(1 - vpScale[1]) / 2.0, 0}
    end
    kaun.draw(fsQuad, fsQuadShader, {
        tex = colorTarget,
        viewportScale = vpScale,
        viewportOffset = vpOffset,
    }, fsQuadState)

    kaun.beginLoveGraphics()
    local vx, vz = player.velocity.x, player.velocity.z
    love.graphics.print("velocity: " .. math.sqrt(vx*vx + vz*vz), 5, 5)
    love.graphics.print("onGround: " .. tostring(player.onGround), 5, 25)
    love.graphics.flushBatch()
    kaun.endLoveGraphics()
end
