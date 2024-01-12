local popupClass = require('lib/floatingtext/effects/PopupText')
local PopupManagerClass = require('lib/floatingtext/effects/PopupTextManager')
local gPopupManager = PopupManagerClass(popupClass)
local TextManager = {}

function TextManager:init(font)
  self.font = font
  self.timer = Timer.new()
end

function TextManager:update(dt)
  gPopupManager:update(dt)
  self.timer:update(dt)
end

function TextManager:draw()
  gPopupManager:render()
end

function TextManager.drawUI(o,o2,oB,oR,oXC,oYC)
  TextManager.introText(oXC, o2)
  
  if promptsRan.drops then
    Typo.draw(oR - 75, oB - 10, alpha.a)
    love.graphics.setColor(1,1,1,1)
  end
end

function TextManager:genericPopup(x, y, str, color, scale)
	local r,g,b,a = unpack(color)
  gPopupManager:addPopup(
  {
      text = str,
      font = self.font,
      color = {r = r, g = g, b = b, a = a},
      x = x,
      y = y + 10,
      scaleX = scale,
      scaleY = scale,
      fadeOut = {start = .7, finish = 1},
      dX = 0,
      dY = 100,
      duration = 1
  })
end

function TextManager:cancel(index)
  self.timer:clear()
  Typo.kill(index)
  promptsRan.drops = false
end

function TextManager:clear()
  self.timer:clear()
  gPopupManager = PopupManagerClass(popupClass)
end

return TextManager