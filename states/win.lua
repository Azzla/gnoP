local Win = {}

function Win:enter(prev)
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
end

function Win:update(dt)
	Typo:update(dt)
	self.prompt_timer:update(dt)
end

function Win:draw()
	self.effect(function()
		self.bg()
		local alpha = 1
		if self.prompt_blink then alpha = self.prompt_alpha end
		Typo:draw(0,200,alpha)
	end)
end

function Win:initPromptChain()
	Sounds.win_music:play()
	self.prompt_timer:after(2, function()
		self.prompt_blink = true
		Typo:new("YOU WIN!", 8, 0.25, Options.width/2, 'center', 2, Font, { 255, 255, 255 }, {Sounds.type_1})
	end)

	self.prompt_timer:after(12, function()
		self.prompt_blink = false
		Typo:new("Thanks for playing!", 6, 0.12, Options.width/2, 'center', 2, Font, { 255, 255, 255 }, {Sounds.type_1})
	end)

	self.prompt_timer:after(18, function()
		Typo:new("Please rate on itch.io if\nyou enjoyed your experience.\n\n:)", 10, 0.08, Options.width/2, 'center', 2, Font, { 255, 255, 255 }, {Sounds.type_1})
	end)

	self.prompt_timer:after(26, function()
		Typo:new("(press 'END' or 'ESC' to quit............................................................................................................................).", 15, 0.05, Options.width, 'right', 1, Font, { 255, 255, 255 }, {})
	end)

	self.prompt_timer:after(50, function() love.event.quit() end)
end

function Win:keypressed(key)
	if key == 'escape' then
		love.event.quit()
	end
end

return Win