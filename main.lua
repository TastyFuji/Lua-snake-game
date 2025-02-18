-- Snake Game in Lua (LÖVE 2D)
---@diagnostic disable: undefined-global


local gridSize = 40
local snake = {{x = 5, y = 5}}
local direction = {x = 1, y = 0}
local food = {x = 10, y = 10}
local gameOver = false
local won = false
local score = 0
local speed = 0.19
local speedlevel = 1
local level = 1

function love.load()
    love.window.setTitle("Lua Snake Game")
    love.window.setMode(800, 600)
end

function love.update(dt)

    if gameOver or won then return end

    if love.keyboard.isDown("up") and direction.y == 0 then
        direction = {x = 0, y = -1}
    elseif love.keyboard.isDown("down") and direction.y == 0 then
        direction = {x = 0, y = 1}
    elseif love.keyboard.isDown("left") and direction.x == 0 then
        direction = {x = -1, y = 0}
    elseif love.keyboard.isDown("right") and direction.x == 0 then
        direction = {x = 1, y = 0}
    end
    if love.timer.getTime() % speed < dt then
        moveSnake()
    end
end

function moveSnake()
    local head = {x = snake[1].x + direction.x, y = snake[1].y + direction.y}

    -- Check collisions
    if head.x < 0 or head.y < 0 or head.x >= 20 or head.y >= 15 then
        gameOver = true
    end

    for _, segment in ipairs(snake) do
        if head.x == segment.x and head.y == segment.y then
            gameOver = true
        end
    end

    if gameOver then return end

    table.insert(snake, 1, head)

    if head.x == food.x and head.y == food.y then
        addScore()
        food.x = love.math.random(0, 19)
        food.y = love.math.random(0, 14)
    else
        table.remove(snake)
    end
end

function love.draw()
    love.graphics.setColor(0, 1, 0)
    for _, segment in ipairs(snake) do
        love.graphics.rectangle("fill", segment.x * gridSize, segment.y * gridSize, gridSize, gridSize)
    end

    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle("fill", food.x * gridSize, food.y * gridSize, gridSize, gridSize)

    love.graphics.setColor(1,1,1)
    love.graphics.print("Score : " .. score ,10,10)
    love.graphics.print("Level : " .. level ,80,10)
    love.graphics.print("Speed : " .. speedlevel ,140,10)
    love.graphics.print("Update Time : " .. speed ,650,10)

    if won then
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("You Won! Press R to Restart", 300, 280)
        love.graphics.print("Take a screenshot and send it to the most handsome guy you know (Yes, that’s me!)", 120, 300)
        return  -- ไม่ต้องวาด Game Over ถ้าชนะแล้ว
    end

    if won then return end

    if gameOver then
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("Game Over! Press R to Restart", 300, 280)
    end
end

function love.keypressed(key)
    if key == "r" then
        snake = {{x = 5, y = 5}}
        direction = {x = 1, y = 0}
        food = {x = 10, y = 10}
        level = 1
        speed = 0.19
        speedlevel = 1
        score = 0
        gameOver = false
        won = false
    end
end
function addScore()

    score = score + 1

    if score >= 60 then  -- เมื่อคะแนนถึง 5 ให้เกมหยุด
        won = true
        return
    end

    if score % 5 == 0 then
        level = level + 1
        if speed <= 0.12 then
            speed = 0.12
        else
            speed = speed - 0.01
            speedlevel = speedlevel + 1
        end
        
        
    end
end

 