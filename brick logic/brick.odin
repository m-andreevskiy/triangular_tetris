package logic

import "core:fmt"
import "core:math/rand"
import rl "vendor:raylib"

// randomGenerator := rand.create(2)

FALLING_SPEED : f32 = 20
WINDOW_WIDTH : i32 = 0
initWindowWidth :: proc (width: i32) {
  WINDOW_WIDTH = width
}

Vector2 :: struct {
    x : f32,
    y : f32,
}

BrickType :: enum {
	A,
	B,
	C,
	D,
	E,
	F,
	G,
	H,
	I,
}

brickTypeProcs : [9]proc() -> [4][dynamic]BrickCell = {
	getBrickStructure_A,
	getBrickStructure_B,
	getBrickStructure_C,
	getBrickStructure_D,
	getBrickStructure_E,
	getBrickStructure_F,
	getBrickStructure_G,
	getBrickStructure_H,
	getBrickStructure_I,
}

brickRotationProcs : [9]proc(brick: BrickEx, env: Environment) -> bool = {
	canRotate_A,
	canRotate_B,
	canRotate_C,
	canRotate_D,
	canRotate_E,
	canRotate_F,
	canRotate_G,
	canRotate_H,
	canRotate_I,
}

// nextBrickType : BrickType = rand.choice_enum(BrickType)
nextBrickType : BrickType = BrickType.C
// nextBrickType := getNextType()

BrickEx :: struct {
	position: Vector2,
	positionOffset: Vector2,
	gridX: i32,
	gridY: i32,
	type: BrickType,
	rotation: i32,     // 0..3
	isAlive: bool,
	form: [4][dynamic]BrickCell,
	color: rl.Color,
}

BrickCell :: struct {
	position: [2]i32,
	tr: bool,
	br: bool,
	bl: bool,
	tl: bool,
}

weightCutoffs : [dynamic]i32
initWeightCutoffs :: proc (cutoffs: [dynamic]i32) {
	weightCutoffs = cutoffs
}

getNextType :: proc () -> BrickType {
	r := rand.int31_max(weightCutoffs[len(weightCutoffs) - 1])
	for t in BrickType {
		if r < weightCutoffs[int(t)] {
			return t
		}
	}
	
	return BrickType.C
}


initNewBrick :: proc (brick : ^BrickEx, env: Environment) {
	// brickPos : Vector2 = {f32(150), f32(160)}
	brickPos : Vector2 = {f32(WINDOW_WIDTH / 2), f32(160)}

	type := nextBrickType
	nextBrickType = getNextType()

	brick^ = {
		position = Vector2(brickPos), 
		gridX = i32(brickPos.x / f32(CELL_SIZE)), 
		gridY = i32(brickPos.y / f32(CELL_SIZE)), 
		type = type, 
		rotation = 0,
		isAlive = true,
		form = brickTypeProcs[int(type)](),
		color = brickColors[int(type)]
	}

	pulseCheck(brick, env)

}

moveBrick :: proc(brick: ^BrickEx, env: ^Environment, speed: f32 = FALLING_SPEED) -> i32 {
	scoreGain : i32 = 0

	if (len(COMPLETE_ROWS) == 0){
		brick.position.y += speed * rl.GetFrameTime()
	}

	newGridY := i32(brick.position.y / f32(CELL_SIZE))
	if (newGridY > brick.gridY) {
		if (canMoveBrick(brick^, env^, "down")) {
			brick.gridY = i32(brick.position.y / f32(CELL_SIZE))
		}
		else {
			// fmt.println("Can't move down >:|")
			scoreGain = appendBrickToEnvironmentEx(env, brick^)
			initNewBrick(brick, env^)
		}
	}

	return scoreGain
}

drawBrickUni :: proc(brick: BrickEx) {
	form := brick.form[brick.rotation]

	for cell in form {
		drawBrickCell(cell, brick)
	}
}

drawBrickCell :: proc(cell: BrickCell, brick: BrickEx) {
	outlineColor: rl.Color = rl.DARKGRAY
	cellSize := f32(CELL_SIZE)
	snappedX := brick.gridX * CELL_SIZE + i32(brick.positionOffset.x)
	snappedY := brick.gridY * CELL_SIZE + i32(brick.positionOffset.y)
	snappedPos : rl.Vector2 = {f32(snappedX), f32(snappedY)} 
	offset : rl.Vector2 = {snappedPos.x + f32(cell.position[0]) * cellSize, snappedPos.y + f32(cell.position[1]) * cellSize}
	
	p1 : rl.Vector2
	p2 : rl.Vector2
	p3 : rl.Vector2

	if cell.tr{
		p1 = {0, 0}
		p2 = {cellSize, cellSize}
		p3 = {cellSize, 0}
		rl.DrawTriangle(offset + p1, offset + p2, offset + p3, brick.color)
		rl.DrawTriangleLines(offset + p1, offset + p2, offset + p3, outlineColor)
	}

	if cell.br{
		p1 = {0, cellSize}
		p2 = {cellSize, cellSize}
		p3 = {cellSize, 0}
		rl.DrawTriangle(offset + p1, offset + p2, offset + p3, brick.color)
		rl.DrawTriangleLines(offset + p1, offset + p2, offset + p3, outlineColor)
	}
	
	if cell.bl{
		p1 = {0, cellSize}
		p2 = {cellSize, cellSize}
		p3 = {0, 0}
		rl.DrawTriangle(offset + p1, offset + p2, offset + p3, brick.color)
		rl.DrawTriangleLines(offset + p1, offset + p2, offset + p3, outlineColor)
	}

	if cell.tl{
		p1 = {0, cellSize}
		p2 = {cellSize, 0}
		p3 = {0, 0}
		rl.DrawTriangle(offset + p1, offset + p2, offset + p3, brick.color)
		rl.DrawTriangleLines(offset + p1, offset + p2, offset + p3, outlineColor)
	}
}


canRotate :: proc (brick: BrickEx, env: Environment) -> bool {
	return brickRotationProcs[int(brick.type)](brick, env)
}

canMoveBrick :: proc (brick: BrickEx, env: Environment, direction: string) -> bool {
	cells := brick.form[brick.rotation]

	switch direction {
		case "left":
			for cell in cells {
				if !canMoveCell(cell, cell.position[0] + brick.gridX, cell.position[1] + brick.gridY, env, "left") {
					return false
				}
			}

		case "right":
			for cell in cells {
				if !canMoveCell(cell, cell.position[0] + brick.gridX, cell.position[1] + brick.gridY, env, "right") {
					return false
				}
			}

		case "down":
			for cell in cells {
				if !canMoveCell(cell, cell.position[0] + brick.gridX, cell.position[1] + brick.gridY, env, "down") {
					return false
				}
			}
	}
	return true
}

canMoveCell :: proc (cell: BrickCell, cellX: i32, cellY: i32, env: Environment, direction: string) -> bool {
	dangerCell : Cell
	dangerSelf := env.cells[cellY * env.columns + cellX]

	switch direction {
		case "down":
			if cellY >= env.rows - 1 {
				return false
			}

			dangerCell = env.cells[(cellY + 1) * env.columns + cellX]

			// if cell is full
			if (cell.tr && cell.bl) || (cell.tl && cell.br) {
				if (dangerCell.tr || dangerCell.br || dangerCell.bl || dangerCell.tl) {
					return false
				}
			}

			if cell.tr {
				if (dangerCell.tr || dangerCell.br || dangerCell.tl) {
					return false
				}
				if (dangerSelf.bl) {
					return false
				}
			}

			if cell.br {
				if (dangerCell.tr || dangerCell.br || dangerCell.bl || dangerCell.tl) {
					return false
				}
			}

			if cell.bl {
				if (dangerCell.tr || dangerCell.br || dangerCell.bl || dangerCell.tl) {
					return false
				}
			}

			if cell.tl {
				if (dangerCell.tr || dangerCell.bl || dangerCell.tl) {
					return false
				}
				if (dangerSelf.br) {
					return false
				}				
			}


		case "left":
			if cellX <= 0 {
				return false
			}

			dangerCell = env.cells[cellY * env.columns + cellX - 1]

			if (cell.tr && cell.bl) || (cell.tl && cell.br) {
				if (dangerCell.tr || dangerCell.br || dangerCell.bl || dangerCell.tl) {
					return false
				}
			}

			if cell.tr {
				if (dangerCell.tr || dangerCell.br || dangerCell.tl) {
					return false
				}
				if (dangerSelf.bl) {
					return false
				}
			}

			if cell.br {
				if (dangerCell.tr || dangerCell.br || dangerCell.bl) {
					return false
				}
				if (dangerSelf.tl) {
					return false
				}
			}

			if cell.bl {
				if (dangerCell.tr || dangerCell.br || dangerCell.bl || dangerCell.tl) {
					return false
				}
			}

			if cell.tl {
				if (dangerCell.tr || dangerCell.br || dangerCell.bl || dangerCell.tl) {
					return false
				}
			}


		case "right":
			if cellX >= env.columns - 1 {
				return false
			}

			dangerCell = env.cells[cellY * env.columns + cellX + 1]

			if (cell.tr && cell.bl) || (cell.tl && cell.br) {
				if (dangerCell.tr || dangerCell.br || dangerCell.bl || dangerCell.tl) {
					return false
				}
			}
			if cell.tr {
				if (dangerCell.tr || dangerCell.br || dangerCell.bl || dangerCell.tl) {
					return false
				}
			}

			if cell.br {
				if (dangerCell.tr || dangerCell.br || dangerCell.bl || dangerCell.tl) {
					return false
				}
			}

			if cell.bl {
				if (dangerCell.br || dangerCell.bl || dangerCell.tl) {
					return false
				}
			}
				if (dangerSelf.tr) {
					return false
				}

			if cell.tl {
				if (dangerCell.tr || dangerCell.bl || dangerCell.tl) {
					return false
				}
			}
				if (dangerSelf.br) {
					return false
				}

	}

	return true
}


pulseCheckCell :: proc (cell: BrickCell, brick: ^BrickEx, env: Environment) {
	cellX := cell.position[0] + brick.gridX
	cellY := cell.position[1] + brick.gridY
	envCell := env.cells[cellY * env.columns + cellX]

	if cell.tr {
		if envCell.br || envCell.bl || envCell.tl {
			brick.isAlive = false
		}
	}

	if cell.br {
		if envCell.tr || envCell.bl || envCell.tl {
			brick.isAlive = false
		}
	}

	if cell.bl {
		if envCell.tr || envCell.br || envCell.tl {
			brick.isAlive = false
		}
	}

	if cell.tl {
		if envCell.tr || envCell.br || envCell.bl {
			brick.isAlive = false
		}
	}

}


pulseCheck :: proc (brick: ^BrickEx, env: Environment) {
	cells := brick.form[brick.rotation]

	for cell in cells {
		pulseCheckCell(cell, brick, env)
	} 
}