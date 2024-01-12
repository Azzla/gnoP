local Menu = {}

function Menu:enter(prev)
	self.timer = Timer.new()
	self.second_loop = false
	self.random_text = getRandomAlienString(7)
	self.random_text_2 = getRandomAlienString(4)
	self.random_text_3 = getRandomAlienString(12)
	if prev == States.pause then
		self.second_loop = true
		Sounds.creepy_music:play()
		self.timer:every(.12, function()
			self.random_text = getRandomAlienString(7)
			self.random_text_2 = getRandomAlienString(4)
			self.random_text_3 = getRandomAlienString(12)
		end)
	else
		Sounds.menu_music:play()
	end

	self.ui = Suit.new()
	self.bg = function()
		love.graphics.setColor(Colors.lightest)
		love.graphics.rectangle('fill',0,0,Options.width,Options.height)
	end
	self.new_random_string = getRandomAlienString(32)
	self.hovering_play = false
	self.hovering_quit = false
	self.play_alien = 'gde'
	self.quit_alien = 'kcd'

	self.effect = Moonshine(Moonshine.effects.crt)
					--.chain()
					--.chain(Effects.crt_filter)
					.chain(Moonshine.effects.chromasep)
					.chain(Moonshine.effects.filmgrain)
					.chain(Moonshine.effects.vignette)
	self.effect.filmgrain.size		= 2
	self.effect.filmgrain.opacity	= 1.0
	self.effect.vignette.radius		= 1.2
	self.effect.vignette.opacity	= .8
	self.effect.chromasep.radius	= 3
end

function Menu:leave(next)
	Sounds.menu_music:stop()
	Sounds.creepy_music:stop()
end

function Menu:draw()
	local mx,my = love.mouse.getPosition()

	self.effect(function()
		self.bg()

		love.graphics.setColor(Colors.white)
		self.ui:draw()
		self:dynamicFonts()

		love.graphics.setColor(1,1,1,1)
		love.graphics.draw(Reticle, mx, my, nil, 2, 2)
	end)
end

function Menu:update(dt)
	self.timer:update(dt)
	self.ui.layout:reset(425, Options.height - 425)
	self.ui.layout:padding(0)
	local play_btn = self.ui:Button("", {id=1}, self.ui.layout:row(210, 100))
	local quit_btn = self.ui:Button("", {id=2}, self.ui.layout:row())

	--entered
	if play_btn.entered then
		Sounds.btn_hover:stop()
		Sounds.btn_hover:play()
	end	
	if quit_btn.entered then
		Sounds.btn_hover:stop()
		Sounds.btn_hover:play()
	end

	--hovering
	if play_btn.hovered then self.hovering_play = true else self.hovering_play = false end
	if quit_btn.hovered then self.hovering_quit = true else self.hovering_quit = false end

	--hit
	if play_btn.hit then
		Sounds.btn_click:stop()
		Sounds.btn_click:play()
		if not self.second_loop then
			StateManager:enter(States.game)
		else
			StateManager:enter(States.game_2)
		end
	end
	if quit_btn.hit then
		if not self.second_loop then
			Sounds.btn_click:stop()
			Sounds.btn_click:play()
			love.event.quit()
		else
			Sounds.type_alien:stop()
			Sounds.type_alien:play()
		end
	end
	if quit_btn.entered and self.second_loop then Sounds.white_noise:play() end
	if quit_btn.left and self.second_loop then Sounds.white_noise:stop() end
end

function Menu:dynamicFonts()
	if not self.hovering_play and self.second_loop then
		love.graphics.setFont(Alien_Font)
		love.graphics.print(self.play_alien, 445, Options.height - 405, nil, 8, 8)
	else
		love.graphics.setFont(Font)
		love.graphics.print('PLAY', 450, Options.height - 400)
	end
	if not self.hovering_quit and self.second_loop then
		love.graphics.setFont(Alien_Font)
		love.graphics.print(self.quit_alien, 445, Options.height - 305, nil, 8, 8)
	else
		love.graphics.setFont(Font)
		love.graphics.print('QUIT', 450, Options.height - 300)
	end

	love.graphics.setColor(Colors.white)
	love.graphics.setFont(Font)
	love.graphics.printf("gnoP", 0, 200, Options.width/3, "center", nil,3,3)
	love.graphics.setColor(Colors.darkest)
	love.graphics.printf("gnoP", 0, 200, Options.width/3, "center", nil,3,3,2,2)

	if self.second_loop then
		love.graphics.setFont(Alien_Font)
		love.graphics.setColor(Colors.white)
		love.graphics.printf(self.random_text, 100, 200, Options.width/3, "center", nil,3,3)
		love.graphics.setColor(Colors.darkest)
		love.graphics.printf(self.random_text, 100, 200, Options.width/3, "center", nil,3,3,.5,.5)

		love.graphics.setColor(Colors.white)
		love.graphics.printf(self.random_text_2, -150, 250, Options.width/3, "center", nil,3,3)
		love.graphics.setColor(Colors.darkest)
		love.graphics.printf(self.random_text_2, -150, 250, Options.width/3, "center", nil,3,3,.5,.5)

		love.graphics.setColor(Colors.white)
		love.graphics.printf(self.random_text_3, 70, 350, Options.width/4, "center", nil,4,4)
		love.graphics.setColor(Colors.darkest)
		love.graphics.printf(self.random_text_3, 70, 350, Options.width/4, "center", nil,4,4,.5,.5)
	end
end

return Menu