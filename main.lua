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
local gridSize = 40
local gridWidth = 30  -- จำนวนกริดแนวนอน
local gridHeight = 20 -- จำนวนกริดแนวตั้ง
local specialFood = {x = -1, y = -1} -- ตำแหน่งเริ่มต้นของอาหารพิเศษ (-1 หมายถึงยังไม่ปรากฏ)
local specialFoodTimer = 0            -- ตัวจับเวลาอาหารพิเศษ
local specialFoodDuration = 5         -- เวลาที่อาหารพิเศษอยู่บนหน้าจอ (วินาที)
local lastLevelUpScore = 0 -- เก็บค่าคะแนนครั้งสุดท้ายที่เพิ่มระดับ
local wonScore = 200 -- คะแนนที่ต้องการเพื่อชนะเกม
local maxSpeed = 0.1 -- ความเร็วสูงสุดที่สามารถเพิ่มได้



function love.load()
    love.window.setTitle("Lua Snake Game")
    love.window.setMode(1200, 800)
end


function love.update(dt)
    if gameOver or won then return end

    -- ตรวจสอบว่ากดปุ่ม Spacebar หรือไม่ (เร่งความเร็วชั่วคราว)
    local currentSpeed = speed
    if love.keyboard.isDown("space") then
        currentSpeed = speed * 0.5 -- ลดค่า speed ลง ทำให้เร็วขึ้น
    end

    -- อัปเดตตัวจับเวลาอาหารพิเศษ
    specialFoodTimer = specialFoodTimer + dt
    if specialFood.x == -1 and specialFoodTimer >= 10 then
        specialFood.x = love.math.random(0, gridWidth - 1)
        specialFood.y = love.math.random(0, gridHeight - 1)
        specialFoodTimer = 0
    end

    -- อาหารพิเศษหายไปหลังจาก 5 วินาที
    if specialFood.x ~= -1 and specialFoodTimer >= specialFoodDuration then
        specialFood.x = -1
        specialFood.y = -1
    end

    -- ควบคุมการเคลื่อนที่ของงู (ห้ามกดย้อนศร)
    if (love.keyboard.isDown("up") or love.keyboard.isDown("w")) and direction.y == 0 then
        direction = {x = 0, y = -1} -- ขึ้น
    elseif (love.keyboard.isDown("down") or love.keyboard.isDown("s")) and direction.y == 0 then
        direction = {x = 0, y = 1} -- ลง
    elseif (love.keyboard.isDown("left") or love.keyboard.isDown("a")) and direction.x == 0 then
        direction = {x = -1, y = 0} -- ซ้าย
    elseif (love.keyboard.isDown("right") or love.keyboard.isDown("d")) and direction.x == 0 then
        direction = {x = 1, y = 0} -- ขวา
    end

    -- **ป้องกันการย้อนกลับ**
    if (love.keyboard.isDown("left") or love.keyboard.isDown("a")) and direction.x ~= 1 then
        direction = {x = -1, y = 0}
    elseif (love.keyboard.isDown("right") or love.keyboard.isDown("d")) and direction.x ~= -1 then
        direction = {x = 1, y = 0}
    elseif (love.keyboard.isDown("up") or love.keyboard.isDown("w")) and direction.y ~= 1 then
        direction = {x = 0, y = -1}
    elseif (love.keyboard.isDown("down") or love.keyboard.isDown("s")) and direction.y ~= -1 then
        direction = {x = 0, y = 1}
    end

    -- ใช้ speed ที่ถูกเร่งเมื่อกด Spacebar
    if love.timer.getTime() % currentSpeed < dt then
        moveSnake()
    end
end

function moveSnake()
    local head = {x = snake[1].x + direction.x, y = snake[1].y + direction.y}

    -- ทำให้งูทะลุขอบจอ
    if head.x < 0 then
        head.x = gridWidth - 1
    elseif head.x >= gridWidth then
        head.x = 0
    end

    if head.y < 0 then
        head.y = gridHeight - 1
    elseif head.y >= gridHeight then
        head.y = 0
    end

    -- ตรวจสอบว่าหัวชนตัวเองหรือไม่
    for _, segment in ipairs(snake) do
        if head.x == segment.x and head.y == segment.y then
            gameOver = true
            return
        end
    end

    table.insert(snake, 1, head)

    -- ตรวจสอบว่ากินอาหารปกติหรือไม่
    if head.x == food.x and head.y == food.y then
        addScore()
        food.x = love.math.random(0, gridWidth - 1)
        food.y = love.math.random(0, gridHeight - 1)
        if score >= wonScore then
            won = true
            return
        end

    -- ตรวจสอบว่ากินอาหารพิเศษหรือไม่
    elseif head.x == specialFood.x and head.y == specialFood.y then
        score = score + 2 -- เพิ่มคะแนนพิเศษ
        specialFood.x = -1 -- เอาอาหารพิเศษออกจากจอ
        specialFood.y = -1
        if score >= wonScore then  -- เมื่อคะแนนถึง 70 ให้เกมหยุด
            won = true
            return
        end
    else
        table.remove(snake) -- ถ้าไม่กินอะไร ให้ลบหางงูออก
    end
end
function love.draw()
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()

    local font = love.graphics.getFont()

    -- ข้อความเมื่อชนะ
    local textWon = "You Won! Press R to Restart"
    local textWon2 = "Take a screenshot and send it to the most handsome guy you know (Yes, that’s me!)"
    local textGameOver = "Game Over! Press R to Restart"

    -- คำนวณตำแหน่ง X และ Y สำหรับข้อความกลางจอ
    local textXWon = (screenWidth - font:getWidth(textWon)) / 2
    local textXWon2 = (screenWidth - font:getWidth(textWon2)) / 2
    local textXGameOver = (screenWidth - font:getWidth(textGameOver)) / 2
    local textY = (screenHeight - font:getHeight()) / 2

    -- วาดงู
    love.graphics.setColor(0, 1, 0)
    for _, segment in ipairs(snake) do
        love.graphics.rectangle("fill", segment.x * gridSize, segment.y * gridSize, gridSize, gridSize)
    end

    -- วาดอาหารปกติ
    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle("fill", food.x * gridSize, food.y * gridSize, gridSize, gridSize)

    -- วาดอาหารพิเศษ (เฉพาะเมื่อมีอยู่)
    if specialFood.x >= 0 and specialFood.y >= 0 then
        love.graphics.setColor(1, 1, 0) -- สีเหลืองสำหรับอาหารพิเศษ
        love.graphics.rectangle("fill", specialFood.x * gridSize, specialFood.y * gridSize, gridSize, gridSize)
    end

    -- วาดคะแนน
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Score : " .. score, 10, 10)
    love.graphics.print("Level : " .. level, 90, 10)
    love.graphics.print("Speed : " .. speedlevel, 170, 10)
    love.graphics.print("Update Time : " .. speed, 1060, 10)

    -- แสดงข้อความเมื่อชนะ
    if won then
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(textWon, textXWon, textY)
        love.graphics.print(textWon2, textXWon2, textY + 40)
        return
    end

    -- แสดงข้อความเมื่อ Game Over
    if gameOver then
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(textGameOver, textXGameOver, textY)
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
        specialFood.x = -1 -- รีเซ็ตอาหารพิเศษเมื่อรีสตาร์ทเกม
        specialFood.y = -1
        specialFoodTimer = 0
        lastLevelUpScore = 0 -- รีเซ็ตค่าคะแนนที่ใช้คำนวณ Level Up
    end
end



function addScore()

    score = score + 1

    if score >= wonScore then  -- เมื่อคะแนนถึง 70 ให้เกมหยุด
        won = true
        return
    end

    -- ตรวจสอบว่าคะแนนเพิ่มขึ้นจากค่าก่อนหน้า 5 คะแนนหรือไม่
    if score - lastLevelUpScore >= 5 then
        level = level + 1
        lastLevelUpScore = score -- อัปเดตค่าคะแนนล่าสุดที่เพิ่มระดับ

        if speed > maxSpeed then
            speed = speed - 0.01
            speedlevel = speedlevel + 1
        else
            speed = maxSpeed
        end
    end
end

 
