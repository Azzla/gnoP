local GameTwo = {}
local Ball = require('ball')
local Paddle = require('paddle')

function GameTwo:enter(prev)
	Typo:clearAll()
	self.next_state = States.game_3
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

	--
	self.prompt_timer = Timer.new()
	self:initPromptChain()
	self.music_playing = false
end

function GameTwo:update(dt)
	if self.ball then
		self.ball:update(dt)
		self:collisionHandler(self.player_paddle.coll)
		self:collisionHandler(self.enemy_paddle.coll)
		if self.ball.pos.x <= 0 then
			Sounds.btn_click:play()	
			self.enemy_score = self.enemy_score + 1
			Collider.remove(self.ball.coll)
			self.ball = nil
			self.coll_timer:after(3, function() self:ball_init() end)

			local rand_string = getRandomAlienString(5)
			Typo:new(rand_string, 4, 0.10, Options.width/12.1, 'center', 12, Alien_Font, { 1, 1, 1 })
			Typo:new(rand_string, 4, 0.10, Options.width/12, 'center', 12, Alien_Font, { 0, 0, 0 }, {Sounds.type_alien, Sounds.type_alien_2, Sounds.type_alien_3})

		elseif self.ball.pos.x + self.ball.w >= love.graphics.getWidth() then
			Sounds.btn_click:play()
			self.player_score = self.player_score + 1
			Collider.remove(self.ball.coll)
			self.ball = nil
			self.coll_timer:after(3, function()
				if self.player_score == 3 then
					Typo:clearAll()
					self.coll_timer:clear()
					self.music_playing = false
					Sounds.game_music:stop()
					self.prompt_timer:after(0.5, function()
						Collider.remove(self.player_paddle.coll)
						Collider.remove(self.enemy_paddle.coll)
						StateManager:enter(States.pause)
					end)
				else
					if self.player_score == 1 then
						self:ball_init()
						self.enemy_paddle.s = 900
					end
					if self.player_score == 2 then
						self:ball_init()
						self.player_paddle.s = 1000
						self.enemy_paddle.s = 1400
					end
				end
			end)

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
	if self.music_playing and not Sounds.game_music:isPlaying() then Sounds.game_music:play() end
end

function GameTwo:draw()
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

		--
		Typo:draw(0,200,1)
	end)
end

local function separateEntityByDelta(entity, delta)
	entity.coll:move(delta.x, delta.y)
	entity.pos.x = entity.pos.x + delta.x
	entity.pos.y = entity.pos.y + delta.y
end

function GameTwo:collisionHandler(paddle)
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

function GameTwo:initPromptChain()
	self.prompt_timer:after(2, function()
		self:ball_init()
		self.music_playing = true
		Typo:new("S  C  O  R  E  3  P.....", 5, 0.17, Options.width/2, 'center', 2, Font, { 255, 255, 255 }, {Sounds.type_1})
	end)
	self.prompt_timer:after(6.2, function()
		Typo:new("01110111 01101001 01101110", 4, 0.05, Options.width/2, 'center', 2, Font, { 255, 255, 255 }, {Sounds.type_1})
		Typo:new("01110111 01101001 01101110", 4, 0.05, Options.width/2.05, 'center', 2.05, Font, { 0, 0, 0 }, {Sounds.type_1})
	end)
	self.prompt_timer:after(9, function()
		Sounds.white_noise:play()
		self.prompt_timer:after(.5, function()
			Sounds.white_noise:stop()
		end)
	end)
end

function GameTwo:ball_init()
	local start_position = {x = Options.width/2, y = Options.height/2}
	local start_velocity = 400
	local vx,vy = getRandomDirection()
	self.ball = Ball(start_position, 25, 25, start_velocity)
	self.ball.vx,self.ball.vy = vx,vy
end

return GameTwo