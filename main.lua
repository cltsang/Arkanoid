display.setStatusBar( display.HiddenStatusBar )

local physics = require("physics")
display.setDefault("background", 0, 0, 0)
display.setDefault("fillColor", 255, 255, 255)

local wall = {}
local wallThickness = 3
local paddle
local paddleHeight = 10
local paddleWidth = 100 --display.contentWidth
local paddleCornerRadius = 5
local ball
local ballRadius = 10
local ballSpeed = 500
local brick = {}
local brickHeight = 10
local brickWidth = 29
local stroke = 0
local numBalls = 0

local function onPaddleDrag(event)
    if event.phase == "began" then
        display.getCurrentStage():setFocus(event.target)
        event.target.isFocus = true
	elseif event.target.isFocus then
		if event.phase == "moved" then
			if event.x-paddleWidth/2 > 0 and event.x < display.contentWidth-paddleWidth/2 then
				paddle.x = event.x
			end
        elseif event.phase == "ended" or event.phase == "cancelled" then
			event.target.isFocus = null
			display.getCurrentStage():setFocus(nil)
		end
	end
	return true
end

local function ballHitsBrick(event)
	if(event.target) then
		event.target:removeSelf()
		event.target = nil
		numBalls = numBalls - 1
		if numBalls == 0 then
			physics.pause()
			timer.performWithDelay(50, restart)
		end
	end
end

local function createWalls()
	-- left wall
	wall[0] = display.newRect(0, 0, wallThickness, display.contentHeight)
	-- right wall
	wall[1] = display.newRect(display.contentWidth-wallThickness, 0, wallThickness, display.contentHeight)
	-- ceiling
	wall[2] = display.newRect(wallThickness, 0, display.contentWidth-2*wallThickness, wallThickness)
end

local function createBricks()
	for i = 0, 3 do
			local r = math.random(0, 255)
			local g = math.random(0, 255)
			local b = math.random(0, 255)
				
			local y = 50 + i * (brickHeight + 2)
			for j = 0, 9 do
				local x = 20 + j * (brickWidth + 2)
				brick[numBalls] = display.newRect(x, y, brickWidth, brickHeight)
				brick[numBalls]:setFillColor(r, g, b)
				brick[numBalls].strokeWidth = stroke
				brick[numBalls]:setStrokeColor(255, 255, 255)
				brick[numBalls].x = x
				brick[numBalls].y = y
				numBalls = numBalls + 1
			end
	end
end

local function createPaddle()
	paddle = display.newRoundedRect(display.contentWidth*0.5 - paddleWidth/2, display.contentHeight - 20, paddleWidth, paddleHeight, paddleCornerRadius)
end

local function createBall()
	ball = display.newCircle(paddle.x, paddle.y-ballRadius*2, ballRadius)
	ball:setFillColor(255, 0, 0)
end

local function initializePhysics()
	physics.addBody(paddle, "kinematic", {density=1.0, friction=0.5, bounce=0.3})
	paddle:addEventListener("touch", onPaddleDrag)
	
	physics.addBody(wall[0], "static", {})
	physics.addBody(wall[1], "static", {})
	physics.addBody(wall[2], "static", {})
	
	physics.addBody(ball, {bounce=1.0, radius=ballRadius})
	ball.isBullet = true
	math.randomseed(os.time())
	local angle = math.random(-89, 89)
	ball:setLinearVelocity(ballSpeed*math.sin(angle), ballSpeed*math.cos(angle))
	--ball:setLinearVelocity(100, 100)
	for i = 0, 39 do
		physics.addBody(brick[i], "kinematic", {})
		brick[i]:addEventListener("postCollision", ballHitsBrick)
	end
end

local function startGame()
	physics.start(true)
	physics.setGravity(0, 0)
	createBricks()
	createPaddle()
	createBall()
	initializePhysics()
end

function restart(event)
	if(ball) then
		ball:removeSelf()
		ball = nil
	end
	if(paddle) then
		paddle:removeSelf()
		paddle = nil
	end
	startGame()
end

createWalls()
startGame()