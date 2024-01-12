local GameThree = {}
local Ball = require('ball')
local Paddle = require('paddle')

function GameThree:enter(prev)
	self.next_state = States.game_4
	self.music_playing = false
	self.player_paddle = Paddle({x=200,y=Options.height/2}, 50, 210, false)
	self.enemy_paddle = Paddle({x=Options.width-200-50,y=Options.height/2}, 50, 210, true)
	self.player_score = 0
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
	self:initPromptChain()
	self.random_text = getRandomAlienString(7)
	self.random_text_2 = getRandomAlienString(4)
	self.random_text_3 = getRandomAlienString(12)
	self.prompt_timer:every(.12, function()
		self.random_text = getRandomAlienString(7)
		self.random_text_2 = getRandomAlienString(4)
		self.random_text_3 = getRandomAlienString(12)
	end)
	self.first_dmg = false
	self.second_dmg = false
	self.third_dmg = false
	self.first_dmg_num = 600
	self.second_dmg_num = 800
	self.third_dmg_num = 1000
	self.last_hit = false
	self.final_kill = false
end

function GameThree:update(dt)
	if self.ball then
		self.ball:update(dt)
		self:collisionHandler(self.player_paddle.coll)
		self:collisionHandler(self.enemy_paddle.coll)
		if self.ball and self.ball.pos.x <= 0 then
			Sounds.btn_click:play()	
			self.enemy_score = self.enemy_score + 1
			Collider.remove(self.ball.coll)
			self.ball = nil
			self.coll_timer:after(3, function() self:ball_init() end)

			local rand_string = getRandomAlienString(5)
			Typo:new(rand_string, 4, 0.10, Options.width/12.1, 'center', 12, Alien_Font, { 1, 1, 1 })
			Typo:new(rand_string, 4, 0.10, Options.width/12, 'center', 12, Alien_Font, { 0, 0, 0 }, {Sounds.type_alien, Sounds.type_alien_2, Sounds.type_alien_3})

		elseif self.ball and self.ball.pos.x + self.ball.w >= love.graphics.getWidth() then
			Sounds.btn_click:play()
			Collider.remove(self.ball.coll)
			self.ball = nil

			local rand_string = getRandomAlienString(9)
			local color = {1,0,0}
			Typo:new(rand_string, 4, 0.10, Options.width/12.1, 'center', 12, Alien_Font, color)
			Typo:new(rand_string, 4, 0.10, Options.width/12, 'center', 12, Alien_Font, { 0, 0, 0 }, {Sounds.type_alien, Sounds.type_alien_2, Sounds.type_alien_3})
		end
	end
	self.player_paddle:update(dt)
	self.enemy_paddle:automatic_movement(dt, self.ball)
	self.coll_timer:update(dt)
	
	--
	Typo:update(dt)
	self.prompt_timer:update(dt)
	if self.music_playing and not Sounds.game_music_2:isPlaying() then Sounds.game_music_2:play() end
end

function GameThree:draw()
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

		self:glitchy_text()

		--
		Typo:draw(0,200,1)
	end)
end

local function separateEntityByDelta(entity, delta)
	entity.coll:move(delta.x, delta.y)
	entity.pos.x = entity.pos.x + delta.x
	entity.pos.y = entity.pos.y + delta.y
end

function GameThree:collisionHandler(paddle)
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

			--game three gimmick
			if paddle.parent == self.enemy_paddle then
				if self.ball.v == self.first_dmg_num or self.ball.v == self.first_dmg_num+100 then self.first_dmg = true end
				if self.ball.v == self.second_dmg_num or self.ball.v == self.second_dmg_num+100 then self.second_dmg = true end
				if self.ball.v == self.third_dmg_num or self.ball.v == self.third_dmg_num+100 then self.third_dmg = true end

				if self.third_dmg and self.last_hit then
					self.last_hit = false
					self.first_dmg = false
					self.second_dmg = false
					self.third_dmg = false
					self.first_dmg_num = 800
					self.second_dmg_num = 1100
					self.third_dmg_num = 1500
					--
					Sounds.type_alien:play()
					self.player_score = self.player_score + 1.5
					Collider.remove(self.ball.coll)
					self.ball = nil

					--reset paddle--
					Collider.remove(self.enemy_paddle.coll)
					self.enemy_paddle = Paddle({x=Options.width-200-50,y=Options.height/2}, 50, 210, true)
					Sounds.white_noise:play()
					self.prompt_timer:after(0.15, function() Sounds.white_noise:stop() end)

					--
					self.prompt_timer:after(0.5, function()
						local rand_string = getRandomAlienString(17)
						Typo:new(rand_string, 4, 0.07, Options.width/12.1, 'center', 12, Alien_Font, { 1, 0, 0 })
						Typo:new(rand_string, 4, 0.07, Options.width/12, 'center', 12, Alien_Font, { 0, 0, 0 }, {Sounds.type_alien, Sounds.type_alien_2, Sounds.type_alien_3})
					end)

					if self.final_kill then
						self.music_playing = false
						Sounds.game_music_2:stop()
						self.prompt_timer:after(3, function()
							Collider.remove(self.player_paddle.coll)
							Collider.remove(self.enemy_paddle.coll)
							StateManager:enter(States.pause)
						end)
					else
						self.prompt_timer:after(5, function()
							self.final_kill = true
							self.player_paddle.s = 1000
							self.enemy_paddle.h = 3000
							self.enemy_paddle.w = 400
							self.enemy_paddle.pos.y = -500
							Collider.remove(self.enemy_paddle.coll)
							self.enemy_paddle.coll = Collider.rectangle(self.enemy_paddle.pos.x, self.enemy_paddle.pos.y, self.enemy_paddle.w, self.enemy_paddle.h)
							self.enemy_paddle.coll:moveTo(self.enemy_paddle.pos.x + self.enemy_paddle.w/2,self.enemy_paddle.pos.y + self.enemy_paddle.h/2)
							self.enemy_paddle.coll.parent = self.enemy_paddle
							Sounds.white_noise:play()
							Sounds.angry:play()
							self.prompt_timer:after(0.15, function() Sounds.white_noise:stop() end)
							self.prompt_timer:after(1.0, function() self:ball_init() end)
						end)
					end
				elseif self.third_dmg then
					self.last_hit = true
				end
			end

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

function GameThree:initPromptChain()
	self.prompt_timer:after(3, function()
		self.prompt_timer:after(5, function()
			self:ball_init()
			self.enemy_paddle.h = 3000
			self.enemy_paddle.pos.y = -500
			Collider.remove(self.enemy_paddle.coll)
			self.enemy_paddle.coll = Collider.rectangle(self.enemy_paddle.pos.x, self.enemy_paddle.pos.y, self.enemy_paddle.w, self.enemy_paddle.h)
			self.enemy_paddle.coll:moveTo(self.enemy_paddle.pos.x + self.enemy_paddle.w/2,self.enemy_paddle.pos.y + self.enemy_paddle.h/2)
			self.enemy_paddle.coll.parent = self.enemy_paddle
			Sounds.white_noise:play()
			Sounds.btn_click:play()
			self.prompt_timer:after(0.15, function() Sounds.white_noise:stop() end)
		end)
		self.music_playing = true
		Typo:new("YOU CCCCCCCAN'TCAN'TCAN'TCAN'T", 1, 0.12, Options.width/2, 'center', 2, Font, { 255, 255, 255 }, {Sounds.type_1})
	end)
	self.prompt_timer:after(6.5, function()
		local rand_string = getRandomAlienString(13)
		Typo:new(rand_string, 4, 0.07, Options.width/12.1, 'center', 12, Alien_Font, { 1, 0, 0 })
		Typo:new(rand_string, 4, 0.07, Options.width/12, 'center', 12, Alien_Font, { 0, 0, 0 }, {Sounds.type_alien, Sounds.type_alien_2, Sounds.type_alien_3})
	end)
end

function GameThree:ball_init()
	local start_position = {x = Options.width/2, y = Options.height/2}
	local vx,vy = getRandomDirection()
	self.ball = Ball(start_position, 25, 25, 400)
	self.ball.vx,self.ball.vy = vx,vy
end

function GameThree:glitchy_text()
	if self.first_dmg then
		love.graphics.setFont(Alien_Font)
		love.graphics.setColor(Colors.white)
		love.graphics.print(self.random_text, Options.width-300, Options.height/2 -100, 0.1, 3,3)
		love.graphics.setColor(Colors.darkest)
		love.graphics.print(self.random_text, Options.width-300, Options.height/2 -100, 0.1, 3,3, .5,.5)

		love.graphics.setColor(Colors.white)
		love.graphics.print(self.random_text, Options.width-300, Options.height/2, -0.1, 2,2)
		love.graphics.setColor(Colors.darkest)
		love.graphics.print(self.random_text, Options.width-300, Options.height/2, -0.1, 2,2, .5,.5)
	end
	if self.second_dmg then
		love.graphics.setFont(Alien_Font)
		love.graphics.setColor(Colors.white)
		love.graphics.print(self.random_text, Options.width-300, Options.height/2 +600, 0.1, 3,3)
		love.graphics.setColor(Colors.darkest)
		love.graphics.print(self.random_text, Options.width-300, Options.height/2 +600, 0.1, 3,3, .5,.5)

		love.graphics.setColor(Colors.white)
		love.graphics.print(self.random_text, Options.width-300, Options.height/2 +400, -0.1, 2,2)
		love.graphics.setColor(Colors.darkest)
		love.graphics.print(self.random_text, Options.width-300, Options.height/2 +400, -0.1, 2,2, .5,.5)
	end
	if self.third_dmg then
		love.graphics.setFont(Alien_Font)
		love.graphics.setColor(1,0,0,1)
		love.graphics.print(self.random_text, Options.width-300, Options.height/2 -500, 0.1, 3,3)
		love.graphics.setColor(Colors.darkest)
		love.graphics.print(self.random_text, Options.width-300, Options.height/2 -500, 0.1, 3,3, .5,.5)

		love.graphics.setColor(1,0,0,1)
		love.graphics.print(self.random_text, Options.width-300, Options.height/2 -450, -0.1, 2,2)
		love.graphics.setColor(Colors.darkest)
		love.graphics.print(self.random_text, Options.width-300, Options.height/2 -450, -0.1, 2,2, .5,.5)
	end
end

return GameThree