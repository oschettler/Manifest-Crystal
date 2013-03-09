SpriteGridView = {}

function SpriteGridView:new(spriteGrid, tileWidth, tileHeight)

	local view = display.newGroup()
	view.spriteGrid = nil
	view.tileWidth = tileWidth
	view.tileHeight = tileHeight

	function view:init(spriteGrid, tileWidth, tileHeight)
		self.spriteGrid = spriteGrid
		self.spriteGrid:addEventListener("onAdded", self)
		self.spriteGrid:addEventListener("onRemoved", self)
		self.spriteGrid:addEventListener("onMoved", self)

		self.tileWidth = tileWidth
		self.tileHeight = tileHeight

		local startX = 0
		local startY = 0
		local r, c
		for r=1,spriteGrid.rows do
			for c=1,spriteGrid.cols do
				local spriteVO = spriteGrid:getSprite(r, c)
				if type(spriteVO) == "table" and spriteVO.classType == "SpriteVO" then
					local sprite = self:createSprite(spriteVO)
				end
				startX = startX + tileWidth
			end
			startX = 0
			startY = startY + tileHeight
		end
	end

	function view:createSprite(spriteVO)
		local rect = display.newRect(0, 0, tileWidth, tileHeight)
		rect.spriteVO = spriteVO
		rect:setFillColor(210, 210, 210, 200)
		rect:setStrokeColor(50, 50, 50)
		rect.strokeWidth = 1
		self:insert(rect)
		rect.x = spriteVO.currentCol * self.tileWidth - rect.width / 2
		rect.y = spriteVO.currentRow * self.tileHeight - rect.height / 2
		return rect
	end

	function view:findSprite(spriteVO)
		local i = 1
		local len = self.numChildren
		if len < 1 then error("what the...") end
		while self[i] do
			local child = self[i]
			if child.spriteVO == spriteVO then
				return child
			end
			i = i + 1
		end
		return nil
	end

	function view:onAdded(event)
		local spriteVO = event.sprite
		local sprite = self:createSprite(spriteVO)
		sprite.x = spriteVO.currentCol * self.tileWidth - sprite.width / 2
		sprite.y = spriteVO.currentRow * self.tileHeight - sprite.height / 2
	end

	function view:onRemoved(event)
		local sprite = self:findSprite(event.sprite)
		assert(sprite, "Nil sprite?")
		sprite:removeSelf()
	end

	function view:onMoved(event)
		local spriteVO = event.sprite
		local sprite = self:findSprite(spriteVO)
		assert(sprite, "Can't move a nil sprite")
		if sprite.tweenID then
			transition.cancel(sprite.tweenID)
			sprite.tweenID = nil
		end
		
		local targetX = event.col * self.tileWidth - sprite.width / 2
		local targetY = event.row * self.tileHeight - sprite.height / 2
		sprite.tweenID = transition.to(sprite, {x=targetX, y=targetY, time=500})
		self.lastSprite = sprite
	end

	view:init(spriteGrid, tileWidth, tileHeight)

	return view

end

return SpriteGridView