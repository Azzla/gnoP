local GameFive = {}
local Ball = require('ball')
local Paddle = require('paddle')

function GameFive:enter(prev)
	Typo:clearAll()
	self.next_state = States.win
	self.balls = {}
	self.player_paddle = Paddle({x=200,y=Options.height/2}, 50, 210, false)
	self.player_score = 0
	self.enemy_paddle = Paddle({x=Options.width-200-50,y=Options.height/2}, 50, 210, true)
	self.enemy_score = 0
	self.coll_timer = Timer.new()
	self.coll_pad = 0.12 --time between allowed ball collisions

	self.bg = function()
		love.graphics.setColor(Colors.lightest)
		love.graphics.rectangle('fill',0,0,Options.width,Options.height)
		love.graphics.setColor({0,0,0,1})
		love.graphics.setLineWidth(10)
		dashLine({x=Options.width/2-5,y=0}, {x=Options.width/2-5,y=Options.height}, 50, 50)
	end
	self.effect = Moonshine(Moonshine.effects.crt)
				.chain(Moonshine.effects.chromasep)
				.chain(Moonshine.effects.filmgrain)
				.chain(Moonshine.effects.vignette)
	self.effect.filmgrain.size		= 2
	self.effect.filmgrain.opacity	= 1.0
	self.effect.vignette.radius		= 1.2
	self.effect.vignette.opacity	= .8
	self.effect.chromasep.radius	= 3
	self.current_color = {0,0,0,1}

	--
	self.prompt_timer = Timer.new()
	self:initPromptChain()
	self.glitching_out = false
end

function GameFive:update(dt)
	self.player_paddle:update(dt)
	if self.glitching_out then
		self.enemy_paddle:sporadic_movement(dt)
	end
	self.coll_timer:update(dt)
	self:collisionHandler(self.player_paddle.coll)
	self:collisionHandler(self.enemy_paddle.coll)
	--
	Typo:update(dt)
	self.prompt_timer:update(dt)

	for i,ball in ipairs(self.balls) do
		ball:update(dt)

		if ball.pos.x <= 0 then
			Sounds.btn_click:stop()
			Sounds.btn_click:play()	
			Collider.remove(ball.coll)
			table.remove(self.balls, i)
		elseif ball.pos.x + ball.w >= love.graphics.getWidth() then
			Sounds.btn_click:stop()
			Sounds.btn_click:play()	
			Collider.remove(ball.coll)
			table.remove(self.balls, i)
		end
	end
end

function GameFive:draw()
	self.effect(function()
		self.bg()
		self.player_paddle:draw(self.current_color)
		self.enemy_paddle:draw(self.current_color)

		for i,ball in ipairs(self.balls) do ball:draw(self.current_color) end
		love.graphics.setFont(Font)
		
		self:drawScores()

		--
		Typo:draw(0,500,2)
	end)
end

local function separateEntityByDelta(entity, delta)
	entity.coll:move(delta.x, delta.y)
	entity.pos.x = entity.pos.x + delta.x
	entity.pos.y = entity.pos.y + delta.y
end

function GameFive:collisionHandler(paddle)
	local collisions = Collider.collisions(paddle)
	for ball, delta in pairs(collisions) do
		local collides, dx, dy = paddle:collidesWith(ball)
		local ball_object = ball.parent

		if collides and (dx > 0 or dx < 0) and ball_object.can_collide then
			separateEntityByDelta(ball_object, delta)
			ball_object.vx = -ball_object.vx
			ball_object.v = ball_object.v + 100
			ball_object.can_collide = false

			self.coll_timer:after(self.coll_pad, function()
				if ball_object then ball_object.can_collide = true end
			end)

			Sounds.ball_collide:stop()
			Sounds.ball_collide:play()

		elseif collides and (dy > 0 or dy < 0) and ball_object.can_collide then
			separateEntityByDelta(ball_object, delta)
			ball_object.vy = -ball_object.vy
			ball_object.v = ball_object.v + 100
			ball_object.can_collide = false

			self.coll_timer:after(self.coll_pad, function()
				if ball_object then ball_object.can_collide = true end
			end)

			Sounds.ball_collide:stop()
			Sounds.ball_collide:play()
		end
	end
end

function GameFive:initPromptChain()
	self.prompt_timer:after(3, function()
		self.prompt_timer:after(5, function()
			Sounds.white_noise:play()
			self.prompt_timer:after(0.5, function() Sounds.white_noise:stop() end)
			Typo:clearAll()
		end)
		local rand_string = getRandomAlienString(100)
		Typo:new(rand_string, 8, 0.12, Options.width/12.2, 'center', 12.2, Alien_Font, { 1, 1, 1 })
		Typo:new(rand_string, 8, 0.12, Options.width/12.1, 'center', 12.1, Alien_Font, { 1, 0, 0 })
		Typo:new(rand_string, 8, 0.12, Options.width/12, 'center', 12, Alien_Font, { 0, 0, 0 }, {Sounds.type_alien, Sounds.type_alien_2, Sounds.type_alien_3})
	end)

	self.prompt_timer:after(11, function()
		self.prompt_timer:after(2, function()
			Sounds.angry:play()
			self.glitching_out = true
			self:ball_init(20)
			local rand_string = getRandomAlienString(200)
			Typo:new(rand_string, 8, 0.03, Options.width/12.2, 'center', 12.2, Alien_Font, { 0, 0, 0 })
			Typo:new(rand_string, 8, 0.03, Options.width/12.1, 'center', 12.1, Alien_Font, { 1, 0, 0 })
			Typo:new(rand_string, 8, 0.03, Options.width/12, 'center', 12, Alien_Font, { 1, 1, 1 }, {Sounds.type_alien, Sounds.type_alien_2, Sounds.type_alien_3})
		end)
		self.prompt_timer:after(3, function()
			Sounds.angry:play()
			self:ball_init(20)
		end)
		self.prompt_timer:after(4, function()
			Sounds.angry:play()
			self:ball_init(20)
		end)
		self.prompt_timer:after(5, function()
			Sounds.angry:play()
			self:ball_init(20)
		end)
		self.prompt_timer:after(6, function()
			Sounds.angry:play()
			self:ball_init(20)
			Typo:clearAll()
		end)
		self.prompt_timer:after(8, function()
			StateManager:enter(States.pause)
		end)

		Sounds.power_off:play()
		self.current_color = {1,1,1,1}
		self.bg = function()
			love.graphics.setColor({0,0,0,1})
			love.graphics.rectangle('fill',0,0,Options.width,Options.height)
			love.graphics.setColor(Colors.white)
			love.graphics.setLineWidth(10)
			dashLine({x=Options.width/2-5,y=0}, {x=Options.width/2-5,y=Options.height}, 50, 50)
		end
		self.drawScores = function()
			local rand_int_1 = love.math.random(-10,10)
			local rand_int_2 = love.math.random(-10,10)
			love.graphics.setColor(0,0,0,1)
			love.graphics.printf(tostring(rand_int_1), 400, 100, Options.width/2, 'left', nil,2, 2, -2, -2)
			love.graphics.printf(tostring(rand_int_2), -400, 100, Options.width/2, 'right', nil, 2, 2, -2, -2)
			love.graphics.setColor(Colors.white)
			love.graphics.printf(tostring(rand_int_1), 400, 100, Options.width/2, 'left', nil,2, 2)
			love.graphics.printf(tostring(rand_int_2), -400, 100, Options.width/2, 'right', nil, 2, 2)
		end
	end)
end

function GameFive:ball_init(num_balls)
	for i=1,num_balls do
		local start_position = {x = Options.width/2, y = Options.height/2}
		local start_velocity = love.math.random(500,1500)
		local vx,vy = getRandomDirection()

		local ball = Ball(start_position, 25, 25, start_velocity)
		ball.vx,ball.vy = vx,vy
		table.insert(self.balls, ball)
	end
end

function GameFive:drawScores()
	if not self.glitching_out then
		love.graphics.setColor(Colors.white)
		love.graphics.printf(tostring(self.player_score), 400, 100, Options.width/2, 'left', nil,2, 2, -2, -2)
		love.graphics.printf(tostring(self.enemy_score), -400, 100, Options.width/2, 'right', nil, 2, 2, -2, -2)
		love.graphics.setColor(0,0,0,1)
		love.graphics.printf(tostring(self.player_score), 400, 100, Options.width/2, 'left', nil,2, 2)
		love.graphics.printf(tostring(self.enemy_score), -400, 100, Options.width/2, 'right', nil, 2, 2)
	else
		local rand_int_1 = love.math.random(-10,10)
		local rand_int_2 = love.math.random(-10,10)

		love.graphics.setColor(Colors.white)
		love.graphics.printf(tostring(rand_int_1), 400, 100, Options.width/2, 'left', nil,2, 2, -2, -2)
		love.graphics.printf(tostring(rand_int_2), -400, 100, Options.width/2, 'right', nil, 2, 2, -2, -2)
		love.graphics.setColor(0,0,0,1)
		love.graphics.printf(tostring(rand_int_1), 400, 100, Options.width/2, 'left', nil,2, 2)
		love.graphics.printf(tostring(rand_int_2), -400, 100, Options.width/2, 'right', nil, 2, 2)
	end
end

return GameFive