local Pause = {}

function Pause:enter(gamestate)
	Sounds.menu_music:stop()
	Sounds.game_music:stop()
	Sounds.game_music_1:stop()
	Sounds.game_music_2:stop()

	Sounds.white_noise:play()
	self.gamestate = gamestate
	self.timer = Timer.new()
	if self.gamestate.do_pause_prompts then
		--scripts--
		self.timer:after(2, function()
			Sounds.white_noise:stop()
			local rand_string = getRandomAlienString(20)
			Typo:new(rand_string, 6, 0.10, Options.width/12.1, 'center', 12, Alien_Font, { 1, 0, 0 })
			Typo:new(rand_string, 6, 0.10, Options.width/12, 'center', 12, Alien_Font, { 0, 0, 0 }, {Sounds.type_alien, Sounds.type_alien_2, Sounds.type_alien_3})
		end)

		self.timer:after(10, function()
			local rand_string = getRandomAlienString(10)
			Typo:new(rand_string, 7, 0.10, Options.width/12.1, 'center', 12, Alien_Font, { 1, 0, 0 })
			Typo:new(rand_string, 7, 0.10, Options.width/12, 'center', 12, Alien_Font, { 0, 0, 0 }, {Sounds.type_alien, Sounds.type_alien_2, Sounds.type_alien_3})
		end)

		self.timer:after(14, function() StateManager:enter(States.menu) end)
	else
		self.timer:after(3, function()
			Sounds.white_noise:stop()
			StateManager:enter(self.gamestate.next_state)
		end)
	end
end

function Pause:draw()
	love.graphics.setShader(Shaders.vhs_pause)
	Shaders.vhs_pause:send('iResolution', {Options.width,Options.height})
	Shaders.vhs_pause:send('iTime', love.timer.getTime())

	self.gamestate:draw()
	love.graphics.setShader()
	if self.gamestate.do_pause_prompts then Typo:draw(0,400,1) end
end

function Pause:update(dt)
	self.timer:update(dt)
	if self.gamestate.do_pause_prompts then Typo:update(dt) end
end

return Pause