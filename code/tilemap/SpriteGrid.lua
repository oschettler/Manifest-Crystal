require "tilemap.Direction"

SpriteGrid = {}

function SpriteGrid:new(grid)

	local spriteGrid = display.newGroup()
	spriteGrid.grid = nil

	-- Proxy --
	spriteGrid.rows = nil
	spriteGrid.cols = nil

	function spriteGrid:init(grid)
		self.grid = grid
		self.rows = grid.rows
		self.cols = grid.cols
	end

	function spriteGrid:getSprite(row, col)
		local value = self.grid:getTile(row, col)
		if type(value) == "table" and value.classType == "SpriteVO" then
			return value
		else
			return nil
		end
	end

	-- Public --
	function spriteGrid:addSprite(spriteVO, row, col)
		assert(spriteVO, "null SpriteVO not allowed")
		assert(self:canMoveToTile(sprite, row, col), "Can't move to that tile.")
		self.grid:setTile(row, col, spriteVO)
		spriteVO.currentRow = row
		spriteVO.currentCol = col
		self:dispatchEvent({name="onAdded", target=self, row=row, col=col, sprite=spriteVO})
		return true
	end

	function spriteGrid:removeSprite(sprite)
		local map = self.grid
		if map:getTile(sprite.currentRow, sprite.currentCol) == sprite then
			map:setTile(sprite.currentRow, sprite.currentCol, 0)
			local oldRow = sprite.currentRow
			local oldCol = sprite.currentCol
			sprite.currentRow = nil
			sprite.currentCol = nil
			self:dispatchEvent({name="onRemoved", target=self, row=oldRow, col=oldCol, sprite=sprite})
			return true
		else
			return false
		end
	end

	function spriteGrid:moveSprite(sprite, row, col)
		local grid = self.grid
		local direction
		local oldRow = sprite.currentRow
		local oldCol = sprite.currentCol
		if oldRow > row then
			direction = Direction.NORTH
		elseif oldRow < row then
			direction = Direction.SOUTH
		elseif oldCol > col then
			direction = Direction.WEST
		elseif oldCol < col then
			direction = Direction.EAST
		end
		
		sprite.direction = direction

		if self:canMoveToTile(sprite, row, col) == false  then return false end

		local spriteAtPos = grid:getTile(row, col)
		if spriteAtPos ~= 0 and spriteAtPos == sprite  then return false end
		if grid:getTile(oldRow, oldCol) == sprite then
			grid:setTile(oldRow, oldCol, nil)
		end

		sprite.currentRow = row
		sprite.currentCol = col
		grid:setTile(row, col, sprite)
		self:dispatchEvent({name="onMoved", target=self, oldRow = oldRow, oldCol = oldCol, sprite = sprite, row=row, col=col})
		return true
	end

	function spriteGrid:getWhateverYourFacing(sprite)
		local currentRow = sprite.currentRow
		local currentCol = sprite.currentCol
		local targetRow = currentRow
		local targetCol = currentCol
		local direction = sprite.direction
		if direction == Direction.NORTH then
			targetRow = targetRow - 1
		elseif direction == Direction.SOUTH then
			targetRow = targetRow + 1
		elseif direction == Direction.EAST then
			targetCol = targetCol + 1
		elseif direction == Direction.WEST then
			targetCol = targetCol - 1
		end
		return grid:getTile(targetRow, targetCol)	
	end

	function spriteGrid:moveNorth(sprite)
		self:moveSprite(sprite, sprite.currentRow - 1, sprite.currentCol)
	end

	function spriteGrid:moveSouth(sprite)
		self:moveSprite(sprite, sprite.currentRow + 1, sprite.currentCol)
	end

	function spriteGrid:moveEase(sprite)
		self:moveSprite(sprite, sprite.currentRow, sprite.currentCol + 1)
	end

	function spriteGrid:moveWest(sprite)
		self:moveSprite(sprite, sprite.currentRow, sprite.currentCol - 1)
	end

	-- utility --
	function spriteGrid:tileEmpty(row, col)
		if self.grid:getTile(row, col) == 0 then
			return true
		else
			return false
		end
	end

	function spriteGrid:canMoveToTile(sprite, row, col)
		if row < 0 then return false end
		if col < 0 then return false end
		local grid = self.grid
		if row > grid.rows then return false end
		if col > grid.cols then return false end

		local tile = grid:getTile(row, col)
		if tile == sprite then return false end
		if tile == 0  then return true end

		return false
	end

	spriteGrid:init(grid)

	return spriteGrid
end

return SpriteGrid