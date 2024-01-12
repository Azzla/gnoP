local typo = {}

function typo:new(text, time, delay, width, align, scale, font, colour, sounds)
  local t = {
    t = text,
    time = time,
    delay = delay,
    orig = delay,
    width = width,
    align = align,
    scale = scale,
    font = font,
    colour = colour,
    sounds = sounds,

    string = {},
    index = 1,
    timer = 0,

    text = '',
    isRemoving = false
  }

  local i = 1

  for c in text:gmatch('.') do
    t.string[i] = c

    i = i + 1
  end

  table.insert(typo, t)
  return #typo
end

function typo:update(dt)
  for i,v in ipairs(typo) do
    v.timer = v.timer + dt
    v.time = v.time - dt

    if v.timer >= v.delay and v.index <= #v.string then
--      local variation = love.math.random(.01,.05)
--      v.delay = v.delay + variation
--      if v.delay > 0.25 then v.delay = v.orig end
      
      local char = tostring(v.string[v.index])
      v.text = v.text .. char
      
      if char:match("[^%s]") and v.sounds ~= nil then
      	if #v.sounds > 1 then
      		local rand_int = love.math.random(1,#v.sounds)
      		v.sounds[rand_int]:stop()
      		v.sounds[rand_int]:play()
      	elseif #v.sounds == 1 then
        	v.sounds[1]:stop()
        	v.sounds[1]:play()
        end
      end
      
      v.index = v.index + 1

      v.timer = 0
      
    elseif v.index >= #v.string and not v.isRemoving and v.time <= 0 then
      v.isRemoving = true
    end
  end
  
  for i=#typo,1,-1 do
    local _t = typo[i]
    if _t.isRemoving then
      table.remove(typo, i)
    end
  end
end

function typo:draw(x, y, a)
  for i,v in ipairs(typo) do
    love.graphics.setColor({v.colour[1], v.colour[2], v.colour[3], a})
    love.graphics.setFont(v.font)
    love.graphics.printf(v.text, x, y, v.width, v.align, nil, v.scale, v.scale)
    love.graphics.setColor(1,1,1,1)
  end
end

function typo:getSize()
  return #typo
end

function typo:clearAll()
  for i=#typo,1,-1 do
    local _t = typo[i]
      table.remove(typo, i)
  end
end

return typo 
