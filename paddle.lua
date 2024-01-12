local Paddle = Class{}

function Paddle:init(pos, w, h, is_ai)
	self.pos = pos
	self.w = w
	self.h = h
	self.is_ai = is_ai
	self.coll = Collider.rectangle(self.pos.x, self.pos.y, self.w, self.h)
	self.coll:moveTo(self.pos.x + self.w/2,self.pos.y + self.h/2)
	self.coll.parent = self
	-----------------------
	self.s = 550
	self.timer = Timer.new()
	self.sporadic = false
	self.sporadic_dir = 1
end

function Paddle:update(dt)
	local colliding_top = self.pos.y <= 0
	local colliding_bottom = self.pos.y + self.h >= Options.height

	if love.keyboard.isDown('up', 'w') and not colliding_top and not self.is_ai then
		local new_y = self.pos.y - (self.s * dt)
		self.pos.y = new_y
		self.coll:moveTo(self.pos.x + self.w/2, new_y + self.h/2)

	elseif love.keyboard.isDown('down', 's') and not colliding_bottom and not self.is_ai then
		local new_y = self.pos.y + (self.s * dt)
		self.pos.y = new_y
		self.coll:moveTo(self.pos.x + self.w/2, new_y + self.h/2)

	end
end

function Paddle:draw(alt_color)
	local color = alt_color or {0,0,0,1}
	love.graphics.setColor(color)
	love.graphics.rectangle('fill', self.pos.x, self.pos.y, self.w, self.h)

	-- local r,g,b,a = love.graphics.getColor()
	-- love.graphics.setColor(1,0,0,1)
	-- love.graphics.setLineWidth(.25)
	-- self.coll:draw('line')
	-- love.graphics.setColor(r,g,b,a)
end

function Paddle:automatic_movement(dt, ball)
	if not ball then return end
	local ball_y = ball.pos.y + ball.h/2 --exact midpoint
	local paddle_y = self.pos.y + self.h/2 --exact midpoint
	local padding = 90

	if ball.pos.x >= love.graphics.getWidth()/2 then
		if paddle_y > ball_y + padding then
			local new_y = self.pos.y - (self.s * dt)
			self.pos.y = new_y
			self.coll:moveTo(self.pos.x + self.w/2, new_y + self.h/2)
		elseif paddle_y < ball_y - padding then
			local new_y = self.pos.y + (self.s * dt)
			self.pos.y = new_y
			self.coll:moveTo(self.pos.x + self.w/2, new_y + self.h/2)
		end
	end
end

function Paddle:sporadic_movement(dt)
	local colliding_top = self.pos.y <= 0
	local colliding_bottom = self.pos.y + self.h >= Options.height
	self.timer:update(dt)

	if not self.sporadic then
		self.sporadic = true
		self.sporadic_dir = -self.sporadic_dir
		local move_time = love.math.random(1,9)/100
		self.s = math.random(self.s, self.s + 200)
		self.timer:after(move_time, function()
			self.sporadic = false
		end)
	elseif colliding_top then
		self.pos.y = 1
		self.coll:moveTo(self.pos.x + self.w/2, self.pos.y + self.h/2)
	elseif colliding_bottom then
		self.pos.y = Options.height - self.h - 1
		self.coll:moveTo(self.pos.x + self.w/2, self.pos.y + self.h/2)

	elseif not colliding_top and not colliding_bottom then
		local new_y = self.pos.y + (self.sporadic_dir * (self.s * dt))
		self.pos.y = new_y
		self.coll:moveTo(self.pos.x + self.w/2, new_y + self.h/2)
	end
end

return Paddle