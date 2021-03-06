require "tilemap.Direction"
require "tilemap.TileTypes"
require "tilemap.Grid"

SpriteGrid = {}

function SpriteGrid:new(grid)

	local spriteGrid = display.newGroup()
	spriteGrid.grid = nil
	spriteGrid.sprites = nil

	-- Proxy --
	spriteGrid.rows = nil
	spriteGrid.cols = nil

	function spriteGrid:init(grid)
		self.grid = grid
		self.rows = grid.rows
		self.cols = grid.cols
		self.sprites = Grid:new(self.rows, self.cols, TileTypes.WALKABLE)
	end

	function spriteGrid:getSprite(row, col)
		local value = self.sprites:getTile(row, col)
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
		self.sprites:setTile(row, col, spriteVO)
		spriteVO.currentRow = row
		spriteVO.currentCol = col
		self:dispatchEvent({name="onAdded", target=self, row=row, col=col, sprite=spriteVO})
		return true
	end

	function spriteGrid:removeSprite(sprite)
		local map = self.sprites
		if map:getTile(sprite.currentRow, sprite.currentCol) == sprite then
			map:setTile(sprite.currentRow, sprite.currentCol, TileTypes.WALKABLE)
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
		if sprite.moving == true then return true, "Sprite is moving" end
		
		local grid = self.sprites
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
		
		local canMoveThere, whyNot = self:canMoveToTile(sprite, row, col)
		if canMoveThere == false  then return false, whyNot end

		local spriteAtPos = grid:getTile(row, col)
		if spriteAtPos ~= TileTypes.WALKABLE and spriteAtPos == sprite  then return false end
		if grid:getTile(oldRow, oldCol) == sprite then
			grid:setTile(oldRow, oldCol, TileTypes.WALKABLE)
		end

		sprite.currentRow = row
		sprite.currentCol = col
		grid:setTile(row, col, sprite)
		self:dispatchEvent({name="onMoved", target=self, oldRow = oldRow, oldCol = oldCol, sprite = sprite, row=row, col=col})
		return true
	end

	function spriteGrid:getWhateverYoureFacing(sprite)
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
		return self.sprites:getTile(targetRow, targetCol)	
	end

	function spriteGrid:moveNorth(sprite)
		return self:moveSprite(sprite, sprite.currentRow - 1, sprite.currentCol)
	end

	function spriteGrid:moveSouth(sprite)
		return self:moveSprite(sprite, sprite.currentRow + 1, sprite.currentCol)
	end

	function spriteGrid:moveEast(sprite)
		return self:moveSprite(sprite, sprite.currentRow, sprite.currentCol + 1)
	end

	function spriteGrid:moveWest(sprite)
		return self:moveSprite(sprite, sprite.currentRow, sprite.currentCol - 1)
	end

	-- utility --
	function spriteGrid:tileEmpty(row, col)
		if self.sprites:getTile(row, col) == TileTypes.WALKABLE then
			return true
		else
			return false
		end
	end

	function spriteGrid:canMoveToTile(sprite, row, col)
		if row < 1 then return false, "Row too small" end
		if col < 1 then return false, "Col too small" end
		local grid = self.grid
		if row > grid.rows then return false, "Row too big" end
		if col > grid.cols then return false, "Col too big" end

		local tile = grid:getTile(row, col)
		local spriteTile = self.sprites:getTile(row, col)
		if spriteTile == sprite then return false, "You're already in that tile" end
		if type(spriteTile) == "table" and spriteTile.classType == "SpriteVO" then return false, "Another sprite is there." end
		if tile == TileTypes.WALKABLE or tile == TileTypes.ACTION or tile == TileTypes.STARTING then
			return true
		end

		return false, "Tile is not moveable:" .. tostring(tile)
	end

	spriteGrid:init(grid)

	return spriteGrid
end

return SpriteGrid