local GameFour = {}
local Ball = require('ball')
local Paddle = require('paddle')

function GameFour:enter(prev)
	Typo:clearAll()
	self.next_state = States.game_5
	self.player_paddle = Paddle({x=200,y=Options.height/2}, 50, 210, false)
	self.player_paddle.s = 800
	self.player_score = 0
	self.enemy_paddle = Paddle({x=Options.width-200-50,y=Options.height/2 - 305}, 50, 610, true)
	self.enemy_paddle.s = 2000
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

	--
	self.prompt_timer = Timer.new()
	self.prompt_collider = Collider.rectangle(Options.width/2 - 520, 220, 990, 50)
	self.can_collide_prompt = false
	self.ball_collided_prompt = true
	self.prompt_health = 10000
	self.prompt_health_visible = false
	self.music_playing = false
	self.prompt_timer:after(2, function()
		Typo:new("......", 5, 0.25, Options.width/2, 'center', 2, Font, { 255, 255, 255 }, {Sounds.type_1})
		self:ball_init()
	end)
	self.game_started = false
end

function GameFour:update(dt)
	if self.ball then
		self.ball:update(dt)
		self:collisionHandler(self.player_paddle.coll)
		self:collisionHandler(self.enemy_paddle.coll)
		self:collisionPrompt(self.prompt_collider)
		if self.ball then
			if self.ball.pos.x <= 0 then
				Sounds.btn_click:play()	
				self.enemy_score = self.enemy_score - 1
				Collider.remove(self.ball.coll)
				self.ball = nil
				self.coll_timer:after(3, function() self:ball_init() end)

				--start game--
				if not self.game_started then
					self.game_started = true
					self:initPromptChain()
				end
			elseif self.ball.pos.x + self.ball.w >= love.graphics.getWidth() then
				Sounds.btn_click:play()
				self.player_score = self.player_score - 1
				Collider.remove(self.ball.coll)
				self.ball = nil
				self.coll_timer:after(3, function() self:ball_init() end)
			end
		end
	end
	self.player_paddle:update(dt)
	self.enemy_paddle:automatic_movement(dt, self.ball)
	self.coll_timer:update(dt)
	
	--
	Typo:update(dt)
	FloatingText:update(dt)
	self.prompt_timer:update(dt)
	if self.music_playing and not Sounds.game_music_1:isPlaying() then Sounds.game_music_1:play() end
end

function GameFour:draw()
	self.effect(function()
		self.bg()
		self.player_paddle:draw()
		self.enemy_paddle:draw()
		if self.ball then self.ball:draw() end
		love.graphics.setFont(Font)
		
		love.graphics.setColor(Colors.white)
		love.graphics.printf(tostring(self.player_score), 400, 100, Options.width/2, 'left', nil,2, 2, -2, -2)
		love.graphics.printf(tostring(self.enemy_score), -400, 100, Options.width/2, 'right', nil, 2, 2, -2, -2)
		love.graphics.setColor(0,0,0,1)
		love.graphics.printf(tostring(self.player_score), 400, 100, Options.width/2, 'left', nil,2, 2)
		love.graphics.printf(tostring(self.enemy_score), -400, 100, Options.width/2, 'right', nil, 2, 2)

		if self.prompt_health_visible then
			love.graphics.setColor(Colors.white)
			love.graphics.printf(tostring(self.prompt_health), 0, 50, Options.width/1.1, 'center', nil,1.1, 1.1)
			love.graphics.setColor(0,0,0,1)
			love.graphics.printf(tostring(self.prompt_health), 0, 50, Options.width/1, 'center', nil,1, 1)
		end

		--
		Typo:draw(0,200,1)
		FloatingText:draw()
	end)
end

local function separateEntityByDelta(entity, delta)
	entity.coll:move(delta.x, delta.y)
	entity.pos.x = entity.pos.x + delta.x
	entity.pos.y = entity.pos.y + delta.y
end

function GameFour:collisionHandler(paddle)
	local collisions = Collider.collisions(paddle)
	for ball, delta in pairs(collisions) do
		local collides, dx, dy = paddle:collidesWith(ball)
		if collides and (delta.x > 0 or delta.x < 0) and self.ball.can_collide then
			separateEntityByDelta(self.ball, delta)
			self.ball.vx = -self.ball.vx
			self.ball.v = self.ball.v + 100
			self.ball.can_collide = false

			self.coll_timer:after(self.coll_pad, function()
				if self.ball then self.ball.can_collide = true end
			end)

			Sounds.ball_collide:stop()
			Sounds.ball_collide:play()

		elseif collides and (delta.y > 0 or delta.y < 0) and self.ball.can_collide then
			separateEntityByDelta(self.ball, delta)
			self.ball.vy = -self.ball.vy
			self.ball.v = self.ball.v + 100
			self.ball.can_collide = false

			self.coll_timer:after(self.coll_pad, function()
				if self.ball then self.ball.can_collide = true end
			end)

			Sounds.ball_collide:stop()
			Sounds.ball_collide:play()
		end
	end
end

function GameFour:collisionPrompt(prompt_collider)
	local collisions = Collider.collisions(prompt_collider)

	for ball, delta in pairs(collisions) do
		local collides, dx, dy = prompt_collider:collidesWith(ball)
		if collides and self.can_collide_prompt and self.ball_collided_prompt then
			separateEntityByDelta(self.ball, delta)
			self.ball.vy = -self.ball.vy
			self.ball_collided_prompt = false
			self.coll_timer:after(self.coll_pad, function() self.ball_collided_prompt = true end)

			--damage
			local damage = 1
			if self.ball.v >= 1200 then
				Sounds.white_noise:play()
				self.prompt_timer:after(0.25, function() Sounds.white_noise:stop() end)
				damage = 1000
			end
			FloatingText:genericPopup(Options.width/2, 100, tostring(damage), {1,0,0,1}, 1)
			self.prompt_health = self.prompt_health - damage
			if not self.prompt_health_visible then
				Sounds.angry:play()
				self.prompt_health_visible = true
			end

			Sounds.ball_collide:stop()
			Sounds.ball_collide:play()
			self.ball.v = self.ball.v + 100

			--text
			local rand_string = getRandomAlienString(6)
			local color = {1,0,0}
			local side = 'left'
			local random = love.math.random(1,2)
			if random == 2 then side = 'right' end
			Typo:new(rand_string, 2, 0.06, Options.width/6.1, side, 6.1, Alien_Font, color)
			Typo:new(rand_string, 2, 0.06, Options.width/6, side, 6, Alien_Font, { 0, 0, 0 }, {Sounds.error_type})

			if self.prompt_health <= 0 then
				self.music_playing = false
				Sounds.game_music_1:stop()
				Sounds.white_noise:stop()
				Collider.remove(self.ball.coll)
				self.ball = nil
				self.prompt_timer:clear()
				self.prompt_timer:after(3, function()
					Collider.remove(self.player_paddle.coll)
					Collider.remove(self.enemy_paddle.coll)
					StateManager:enter(States.pause)
				end)
			end
		end
	end
end

function GameFour:initPromptChain()
	self.prompt_timer:after(1, function()
		self.music_playing = true
		local rand_string = getRandomAlienString(10)
		Typo:new(rand_string, 6, 0.10, Options.width/12.1, 'center', 12, Alien_Font, {1,1,1})
		Typo:new(rand_string, 6, 0.10, Options.width/12, 'center', 12, Alien_Font, { 0, 0, 0 }, {Sounds.type_alien, Sounds.type_alien_2, Sounds.type_alien_3})

		self.prompt_timer:every(7, function()
			local rand_string = getRandomAlienString(10)
			local color = {1,1,1}
			Typo:new(rand_string, 6, 0.10, Options.width/12.1, 'center', 12, Alien_Font, color)
			Typo:new(rand_string, 6, 0.10, Options.width/12, 'center', 12, Alien_Font, { 0, 0, 0 }, {Sounds.type_alien, Sounds.type_alien_2, Sounds.type_alien_3})
			self.can_collide_prompt = true
			self.prompt_timer:after(5.7, function() self.can_collide_prompt = false end)
		end)
	end)
end

function GameFour:ball_init()
	local start_position = {x = Options.width/2, y = Options.height/2}
	local start_velocity = 400
	local vx,vy = 1,1
	self.ball = Ball(start_position, 25, 25, start_velocity)
	self.ball.vx,self.ball.vy = vx,vy
end

return GameFour