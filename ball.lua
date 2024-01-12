local Ball = Class{}

function Ball:init(pos, w, h, v)
	self.pos = pos
	self.w = w
	self.h = h
	self.v = v
	self.coll = Collider.rectangle(self.pos.x, self.pos.y, self.w, self.h)
	self.coll.parent = self
	-----------------------
	self.vx = -1
	self.vy = -1
	self.can_collide = true
	self.glitch_out = false
end

function Ball:update(dt)
	local new_x = self.pos.x + (self.vx * self.v * dt)
	local new_y = self.pos.y + (self.vy * self.v * dt)
	self.pos.x = new_x
	self.pos.y = new_y
	self.coll:moveTo(new_x + self.w/2, new_y + self.h/2)

	if not self.glitch_out then
		if self.pos.y <= 0 or self.pos.y + self.h >= love.graphics.getHeight() then
			Sounds.ball_collide:stop()
			Sounds.ball_collide:play()
			self.vy = -self.vy
		end
		--hacky fix for inconsistent 'getting stuck' behavior
		if self.pos.y <= 0 then self.pos.y = 1 end
		if self.pos.y + self.h >= love.graphics.getHeight() then self.pos.y = love.graphics.getHeight() - (self.h + 1) end
	else
		local random_size = love.math.random(2,7)*10
		self.w = random_size
		self.h = random_size
		Sounds.ball_collide:stop()
		Sounds.ball_collide:play()
		self.vx = -self.vx
		self.vy = -self.vy
	end
end

function Ball:draw(alt_color)
	local color = alt_color or {0,0,0,1}
	love.graphics.setColor(color)
	love.graphics.rectangle('fill', self.pos.x, self.pos.y, self.w, self.h)

	-- local r,g,b,a = love.graphics.getColor()
	-- love.graphics.setColor(1,0,0,1)
	-- love.graphics.setLineWidth(.25)
	-- self.coll:draw('line')
	-- love.graphics.setColor(r,g,b,a)
end

return Ball