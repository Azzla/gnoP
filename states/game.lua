local Game = {}
local Ball = require('ball')
local Paddle = require('paddle')

function Game:enter(prev)
	self.do_pause_prompts = true
	if prev ~= States.pause then
		self.player_paddle = Paddle({x=200,y=Options.height/2}, 50, 210, false)
		self.player_score = 0
		self.enemy_paddle = Paddle({x=Options.width-200-50,y=Options.height/2}, 50, 210, true)
		self.enemy_score = 0
		self.coll_timer = Timer.new()
		self.coll_pad = 0.25 --time between allowed ball collisions

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

		--
		self.prompt_timer = Timer.new()
		self.prompt_alpha = 1.0
		self.prompt_swap = false
		self.prompt_blink = false
		self.prompt_timer:every(0.10, function()
			if self.prompt_swap then
				self.prompt_alpha = self.prompt_alpha + 0.1
				if self.prompt_alpha >= 1.0 then self.prompt_swap = false end
			else
				self.prompt_alpha = self.prompt_alpha - 0.1
			end
			
			if self.prompt_alpha <= 0.1 then self.prompt_swap = true end
		end)
		self:initPromptChain()
		self.print_instructions = false
	end
end

function Game:update(dt)
	if self.ball then
		self.ball:update(dt)
		self:collisionHandler(self.player_paddle.coll)
		self:collisionHandler(self.enemy_paddle.coll)
		if self.ball.pos.x <= 0 then
			Sounds.btn_click:play()	
			self.enemy_score = self.enemy_score + 1
			Collider.remove(self.ball.coll)
			self.ball = nil
			self:ball_init()
		elseif self.ball.pos.x + self.ball.w >= love.graphics.getWidth() then
			Sounds.btn_click:play()	
			self.player_score = self.player_score + 1
			Collider.remove(self.ball.coll)
			self.ball = nil
			self:ball_init()
		end
	end
	self.player_paddle:update(dt)
	self.enemy_paddle:automatic_movement(dt, self.ball)
	self.coll_timer:update(dt)
	
	--
	Typo:update(dt)
	self.prompt_timer:update(dt)
end

function Game:draw()
	self.effect(function()
		self.bg()
		self.player_paddle:draw()
		self.enemy_paddle:draw()
		if self.ball then self.ball:draw() end
		--

		local alpha = 1
		if self.prompt_blink then alpha = self.prompt_alpha end
		Typo:draw(0,200,alpha)
		if self.print_instructions then
			love.graphics.setColor(1,1,1,alpha)
			love.graphics.print("W/S or\nUP/DOWN", 150, Options.height - 200)
		end
	end)
end

local function separateEntityByDelta(entity, delta)
	entity.coll:move(delta.x, delta.y)
	entity.pos.x = entity.pos.x + delta.x
	entity.pos.y = entity.pos.y + delta.y
end

function Game:collisionHandler(paddle)
	local collisions = Collider.collisions(paddle)
	for ball, delta in pairs(collisions) do
		local collides, dx, dy = paddle:collidesWith(ball)

		if collides and (delta.x > 0 or delta.x < 0) and self.ball.can_collide then
			separateEntityByDelta(self.ball, delta)
			self.ball.vx = -self.ball.vx
			self.ball.v = self.ball.v + 50
			self.ball.can_collide = false

			self.coll_timer:after(self.coll_pad, function()
				self.ball.can_collide = true
			end)

			Sounds.ball_collide:stop()
			Sounds.ball_collide:play()

		elseif collides and (delta.y > 0 or delta.y < 0) and self.ball.can_collide then
			separateEntityByDelta(self.ball, delta)
			self.ball.vy = -self.ball.vy
			self.ball.v = self.ball.v + 50
			self.ball.can_collide = false

			self.coll_timer:after(self.coll_pad, function()
				self.ball.can_collide = true
			end)

			Sounds.ball_collide:stop()
			Sounds.ball_collide:play()
		end
	end
end

function Game:initPromptChain()
	self.prompt_timer:after(2, function()
		self.prompt_blink = true
		self.print_instructions = true
		Typo:new("PLAYER 1 START", 8, 0.17, Options.width/2, 'center', 2, Font, { 255, 255, 255 }, {Sounds.type_1})
	end)

	self.prompt_timer:after(10, function()
		self:ball_init()
		self.prompt_blink = false
		self.print_instructions = false
		Typo:new("WELCOME!       \nSCORE 3 POINTS TO WIN!", 8, 0.17, Options.width/2, 'center', 2, Font, { 255, 255, 255 }, {Sounds.type_1})
	end)
	
	self.prompt_timer:after(20, function()
		Typo:clearAll()
		Typo:new("SCORE 33333 POINTS \nT000.0..0.O wi1n!l!!^*$(%Y!K)C!!!.!.!!", 3, 0.12, Options.width/2, 'center', 2, Font, { 255, 255, 255 }, {Sounds.type_1})
	end)

	self.prompt_timer:after(26, function()
		local rand_string = getRandomAlienString(19)
		Typo:new(rand_string, 8, 0.08, Options.width/12.1, 'center', 12, Alien_Font, { 1, 1, 1 })
		Typo:new(rand_string, 8, 0.08, Options.width/12, 'center', 12, Alien_Font, { 0, 0, 0 }, {Sounds.type_alien, Sounds.type_alien_2, Sounds.type_alien_3})
	end)

	self.prompt_timer:after(32, function() self.ball.glitch_out = true end)
	self.prompt_timer:after(33, function()
		Typo:clearAll()
		self.coll_timer:clear()
		Collider.remove(self.ball.coll)
		self.ball = nil
		Collider.remove(self.player_paddle.coll)
		Collider.remove(self.enemy_paddle.coll)
		StateManager:enter(States.pause)
	end)
end

function Game:ball_init()
	local start_position = {x = Options.width/2, y = Options.height/2}
	local vx,vy = getRandomDirection()
	self.ball = Ball(start_position, 25, 25, 400)
	self.ball.vx,self.ball.vy = vx,vy
end

return Game