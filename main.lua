Collider		= require('lib/hardoncollider')
Moonshine		= require('lib/moonshine')
StateManager	= require('lib/roomy').new()
Class			= require('lib/class')
Timer			= require('lib/timer')
Suit			= require('lib/suit')
Typo			= require('lib/typo')
FloatingText	= require('TextManager')
Shaders			= require('shaders')
Options			= require('options')
Font			= nil
UI_Font			= nil
Alien_Font		= nil
Colors			= nil
States			= nil
Sounds			= nil
Reticle			= nil
Effects			= {}

function love.load()
	love.mouse.setVisible(false)
	love.window.setMode(Options.width, Options.height, Options.flags)
	love.graphics.setDefaultFilter('nearest', 'nearest')
	Alien_Font	= love.graphics.newImageFont('data/assets/sprites/alien_language.png', ' abcdefghijklmnop', 1)
	Font 		= love.graphics.setNewFont(Options.font_path, Options.default_font_size)
	UI_Font		= love.graphics.newFont(Options.font_path, Options.default_font_size/4)
	Reticle		= love.graphics.newImage(Options.reticle_path)
	Sounds		= Options.getSounds()
	Colors 		= Options.getColors()
	States 		= Options.getGameStates()
	FloatingText:init(Font)
	Options.width,Options.height = love.graphics.getDimensions()

	--load custom shaders--
	Effects.crt_filter = Shaders:loadShader(Moonshine, 'crt_filter')
	--set custom theme--
	Suit.theme.color = {
		normal  = {bg = Colors.dark, fg = Colors.white},
		hovered = {bg = Colors.light, fg = Colors.white},
		active  = {bg = Colors.white, fg = Colors.darkest}
	}
	Suit.theme.cornerRadius = 0

	StateManager:hook()
	StateManager:enter(States.warning)
end

function love.keypressed(key)
	if key == 'end' then love.event.quit() end
end

function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

function dashLine( p1, p2, dash, gap )
   local dy, dx = p2.y - p1.y, p2.x - p1.x
   local an, st = math.atan2( dy, dx ), dash + gap
   local len = math.sqrt( dx*dx + dy*dy )
   local nm = ( len - dash ) / st
   local gr = love.graphics
   gr.push()
      gr.translate( p1.x, p1.y )
      gr.rotate( an )
      for i = 0, nm do
         gr.line( i * st, 0, i * st + dash,0 )
      end
      gr.line( nm * st, 0, nm * st + dash,0 )
   gr.pop()
end

function getRandomAlienString(length)
	local char_select = ' abcdefghijklmnop'
	local new_string = ''
	for i=1,length do
		local rint = love.math.random(1, #char_select) -- 1 out of length of chars
		local rchar = char_select:sub(rint, rint) -- Pick it
		new_string = new_string .. rchar
	end
	return new_string
end

function getRandomDirection()
	local r1,r2 = love.math.random(1,2),love.math.random(1,2)
	local vx,vy
	if r1 == 1 then vx = 1 else vx = -1 end
	if r2 == 1 then vy = 1 else vy = -1 end
	return vx,vy
end