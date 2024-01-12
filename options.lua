local Options = {}
local function rgba(r,g,b,a) return {r/255, g/255, b/255, a} end

Options.width 				= 1920
Options.height 				= 1080
Options.flags				= {}
Options.flags.fullscreen	= true
Options.flags.resizable		= false
Options.flags.msaa			= 8
Options.flags.vsync			= false

Options.font_path			= 'data/pixel.ttf'
Options.default_font_size	= 64
Options.reticle_path		= 'data/assets/cursor.png'

function Options.getColors()
	--ROBOTSRCOOL
	return {
		white 		= rgba(255,255,255,1),
		pink		= rgba(251,205,205,1),
		lightest	= rgba(156,174,187,1),
		light		= rgba(119,130,153,1),
		dark		= rgba(67,61,76,1),
		darkest		= rgba(37,29,41,1)
	}
end

function Options.getSounds()
	local sounds = {
		btn_hover	= love.audio.newSource('data/assets/sfx/btn_hover.ogg', 'static'),
		btn_click	= love.audio.newSource('data/assets/sfx/btn_click.ogg', 'static'),
		power_off	= love.audio.newSource('data/assets/sfx/power_off.ogg', 'static'),
		ball_collide= love.audio.newSource('data/assets/sfx/ball_collide.ogg', 'static'),
		error_type	= love.audio.newSource('data/assets/sfx/error_type.ogg', 'static'),
		angry		= love.audio.newSource('data/assets/sfx/angry.ogg', 'static'),
		type_1		= love.audio.newSource('data/assets/sfx/type_1.ogg', 'static'),
		type_alien	= love.audio.newSource('data/assets/sfx/type_alien.ogg', 'static'),
		type_alien_2= love.audio.newSource('data/assets/sfx/type_alien_2.ogg', 'static'),
		type_alien_3= love.audio.newSource('data/assets/sfx/type_alien_3.ogg', 'static'),
		menu_music	= love.audio.newSource('data/assets/sfx/menu_music.ogg', 'stream'),
		win_music	= love.audio.newSource('data/assets/sfx/win_music.ogg', 'stream'),
		game_music	= love.audio.newSource('data/assets/sfx/game_music.ogg', 'stream'),
		game_music_1= love.audio.newSource('data/assets/sfx/game_music_1.ogg', 'stream'),
		game_music_2= love.audio.newSource('data/assets/sfx/game_music_2.ogg', 'stream'),
		creepy_music= love.audio.newSource('data/assets/sfx/creepy_music.ogg', 'stream'),
		white_noise = love.audio.newSource('data/assets/sfx/white_noise.ogg', 'stream')
	}
	for _,sound in ipairs(sounds) do
		sound:setVolume(0.1)
	end
	sounds.game_music:setVolume(0.65)
	sounds.game_music_1:setVolume(0.65)
	sounds.game_music_2:setVolume(0.55)
	sounds.menu_music:setVolume(1.0)
	sounds.win_music:setVolume(1.0)

	return sounds
end

function Options.getGameStates()
	return {
		warning = require('states.warning'),
		menu = require('states.menu'),
		game = require('states.game'),
		game_2 = require('states.game_2'),
		game_3 = require('states.game_3'),
		game_4 = require('states.game_4'),
		game_5 = require('states.game_5'),
		win = require('states.win'),
		pause = require('states.pause')
	}
end

return Options