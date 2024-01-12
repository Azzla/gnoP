local Warning = {}

function Warning:enter(prev)
	self.timer = Timer.new()
	self.effect = Moonshine(Moonshine.effects.crt)
				.chain(Moonshine.effects.chromasep)
				.chain(Moonshine.effects.filmgrain)
				.chain(Moonshine.effects.vignette)
	self.effect.filmgrain.size		= 2
	self.effect.filmgrain.opacity	= 1.0
	self.effect.vignette.radius		= 1.2
	self.effect.vignette.opacity	= .8
	self.effect.chromasep.radius	= 3

	local warning = "EPILEPSY WARNING:  \n\nThis game contains\nflashing effects."
	Typo:new(warning, 7.5, 0.08, Options.width/2, 'center', 2, Font, { 0, 0, 0 }, {Sounds.type_1})
	self.timer:after(7.5, function() StateManager:enter(States.menu) end)
end

function Warning:draw()
	self.effect(function()
		love.graphics.setColor(Colors.lightest)
		love.graphics.rectangle('fill',0,0,Options.width,Options.height)
		Typo:draw(0,Options.height/2-300,1)
	end)
end

function Warning:update(dt)
	self.timer:update(dt)
	Typo:update(dt)
end

return Warning