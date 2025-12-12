package main

import "core:fmt"
import "core:sync"
import "core:time"
import "core:math/rand"
import rl "vendor:raylib"
import bl "brick logic"

/**
	CHECK LIST FOR ADDING NEW BRICK
	Create file inside "brick logic" directory (with "pachage logic" annotation) and
		- Specify cell structure of a brick (see other brick files)
		- Implement canRotate_<typeName>
	
	Set offset in this file for "next brick" (search "switch type")
*/

CELL_SIZE : i32 = 30
NUMBER_OF_COLUMNS : i32 = 15
NUMBER_OF_ROWS : i32 = 23 

WINDOW_WIDTH : i32 = CELL_SIZE * NUMBER_OF_COLUMNS
WINDOW_HEIGHT : i32 = CELL_SIZE * NUMBER_OF_ROWS

FALLING_SPEED : f32 = 20
fallingSpeed : f32 = FALLING_SPEED

COMPLETE_ROW_TIME : f32 = 1.05 	// seconds
HIGHLIGHT_TIME_MULTIPLIER : f32 = 4

SCORE : i32 = 0

// randomGenerator := rand.create(1)

draw_shader_screen :: proc(width, height : f32){
    rl.rlBegin(rl.RL_QUADS)
    rl.rlVertex2f(0, 0)
    rl.rlVertex2f(0, height)
    rl.rlVertex2f(width, height)
    rl.rlVertex2f(width, 0)
    rl.rlEnd()
}

drawGrid :: proc() {
	rowNum := i32(WINDOW_HEIGHT / CELL_SIZE)
	columnNum := i32(WINDOW_WIDTH / CELL_SIZE)

	for i : i32 = 3; i < rowNum; i += 1 {
		rl.DrawLine(0, i * CELL_SIZE, WINDOW_WIDTH, i * CELL_SIZE, rl.LIME)
	}

	for i : i32 = 0; i < columnNum; i += 1 {
		rl.DrawLine(i * CELL_SIZE, 3*CELL_SIZE, i * CELL_SIZE, WINDOW_HEIGHT, rl.LIME	)
	}
}

restart :: proc(brick : ^bl.BrickEx, cells: ^[dynamic]bl.Cell, env: ^bl.Environment){
	fmt.println("Re:Zero moment")

	bl.initCells(cells, NUMBER_OF_ROWS, NUMBER_OF_COLUMNS)
	env^ = {NUMBER_OF_ROWS, NUMBER_OF_COLUMNS, cells^}
	bl.initNewBrick(brick, env^)
	SCORE = 0
}

initWeights :: proc () {
	// weights := [8]i32{40000, 2, 30000, 40000, 2, 50000, 50000, 40000}
	weights := [9]i32{40000, 2, 30000, 40000, 2, 40000, 40000, 40000, 30000}
	cutoffs : [dynamic]i32
	runningSum : i32 = 0
	for w in weights {
		runningSum += w
		append(&cutoffs, runningSum)
	}
	bl.initWeightCutoffs(cutoffs)
}

getOffsetForNextBrick :: proc (type : bl.BrickType) -> bl.Vector2 {
	cellSizeF := f32(CELL_SIZE)
	#partial switch type {
		case bl.BrickType.A, bl.BrickType.D, bl.BrickType.H, bl.BrickType.I:
			return bl.Vector2{- cellSizeF / 4, 0}

		case:
			return bl.Vector2{cellSizeF / 2, cellSizeF / 2}
	}
}


main :: proc() {
	fmt.println("entered 'main'")

	rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "Don't wanna mess with toilet paper")
	// if window wasn't created ...

	defer rl.CloseWindow()

	rl.SetTargetFPS(60)


	time : f32 = 0
	timer : f32 = 0

	shader := rl.LoadShaderFromMemory(nil, bl.line_highlight_shader)
	defer rl.UnloadShader(shader)
    loc_light_pos := rl.GetShaderLocation(shader, "lightPos")
    loc_resolution := rl.GetShaderLocation(shader, "resolution")
    loc_mousePos := rl.GetShaderLocation(shader, "mousPos")
    loc_LTH := rl.GetShaderLocation(shader, "lineToHighlight")
    loc_highlight_rows := rl.GetShaderLocation(shader, "hightlightRows")
    loc_time := rl.GetShaderLocation(shader, "time")
    loc_cellSize := rl.GetShaderLocation(shader, "cellSize")

    // res := rl.Vector2{f32(700), f32(600)}
    res := rl.Vector2{f32(WINDOW_WIDTH), f32(WINDOW_HEIGHT)}
		LTH : i32 = 15

    rl.SetShaderValue(shader, loc_resolution, &res, rl.ShaderUniformDataType.VEC2)
    rl.SetShaderValue(shader, loc_LTH, &LTH, rl.ShaderUniformDataType.INT)
    rl.SetShaderValue(shader, loc_cellSize, &CELL_SIZE, rl.ShaderUniformDataType.INT)
    light_pos := rl.Vector2{100, 100}


	initWeights()

	cellSizeF := f32(CELL_SIZE)
	bl.initCellSize(CELL_SIZE)
	bl.initWindowWidth(WINDOW_WIDTH)
	
	cells : [dynamic]bl.Cell
	bl.initCells(&cells, NUMBER_OF_ROWS, NUMBER_OF_COLUMNS)
	environment : bl.Environment = {NUMBER_OF_ROWS, NUMBER_OF_COLUMNS, cells}
	
	currentBrick : bl.BrickEx
	bl.initNewBrick(&currentBrick, environment)

	nextBrick : bl.BrickEx
	nextBrickPos : bl.Vector2 = {f32(WINDOW_WIDTH - 50), f32(50)}
	type := bl.nextBrickType

	nextBrick = {
		position = bl.Vector2(nextBrickPos), 
		positionOffset = getOffsetForNextBrick(type),
		gridX = i32(nextBrickPos.x / cellSizeF), 
		gridY = i32(nextBrickPos.y / cellSizeF), 
		type = type, 
		rotation = 0,
	}


	for (!rl.WindowShouldClose()){
		scoreGain : i32 = bl.moveBrick(&currentBrick, &environment, fallingSpeed)
		SCORE += scoreGain
		nextBrick.type = bl.nextBrickType
		nextBrick.form = bl.brickTypeProcs[int(nextBrick.type)]()
		nextBrick.color = bl.brickColors[int(nextBrick.type)]
		nextBrick.positionOffset = getOffsetForNextBrick(nextBrick.type)



				time += rl.GetFrameTime() * HIGHLIGHT_TIME_MULTIPLIER
				rl.SetShaderValue(shader, loc_time ,&time, rl.ShaderUniformDataType.FLOAT)
		
    		LTH = bl.COMPLETE_ROW
				LLTH : [3]i32
				for i : int = 0; i < len(bl.COMPLETE_ROWS); i += 1 {
					LLTH[i] = bl.COMPLETE_ROWS[i]
				}
				// LLTH := bl.COMPLETE_ROWS
				rl.SetShaderValue(shader, loc_LTH, &LTH, rl.ShaderUniformDataType.INT)
				rl.SetShaderValue(shader, loc_highlight_rows, &LLTH, rl.ShaderUniformDataType.IVEC3)

				// if LTH != 0 && timer < COMPLETE_ROW_TIME{
				if len(bl.COMPLETE_ROWS) != 0 && timer < COMPLETE_ROW_TIME{
					timer += rl.GetFrameTime()
				}
				else {
					timer = 0
					time = 0 
					bl.COMPLETE_ROW = 0
					clear(&bl.COMPLETE_ROWS)
					bl.clearRows(environment)
				}



		rl.BeginDrawing()

			// rl.ClearBackground(rl.Color{83, 55, 122, 255})		// 'medium'
			// rl.ClearBackground(rl.Color{99, 67, 143, 255})		// 'light'
			rl.ClearBackground(rl.Color{64, 41, 97, 255})			// 'dark'
			rl.DrawLineEx({0, 3*cellSizeF}, {f32(WINDOW_WIDTH), 3*cellSizeF}, 4, rl.WHITE)
			drawGrid()

			bl.drawBrickUni(currentBrick)
			bl.drawBrickUni(nextBrick)
			bl.drawEnvironment(environment)

			rl.DrawText(fmt.ctprintf("Score: %i", SCORE), 10, WINDOW_HEIGHT/20 - 10, 35, rl.GOLD)
						
			if !currentBrick.isAlive {
				message : cstring = "GG WB"
				message2 : cstring = "Press R to restart"
				fontSize : i32 = 70
				fontSize2 : i32 = 28
				textWidth := rl.MeasureText(message, fontSize)
				textWidth2 := rl.MeasureText(message2, fontSize2)
				textX := (WINDOW_WIDTH - textWidth) / 2
				text2X := (WINDOW_WIDTH - textWidth2) / 2

				rl.DrawText(message, textX, WINDOW_HEIGHT/5, fontSize, rl.RED)
				rl.DrawText(message2, text2X, WINDOW_HEIGHT/5 + fontSize/3*4 , fontSize2, rl.RED)

			}


			rl.BeginShaderMode(shader)
				draw_shader_screen(f32(WINDOW_WIDTH), f32(WINDOW_HEIGHT))
			rl.EndShaderMode()


		rl.EndDrawing()

		if currentBrick.isAlive{
			#partial switch rl.GetKeyPressed() {
				case rl.KeyboardKey.LEFT:
					if (bl.canMoveBrick(currentBrick, environment, "left")){
						currentBrick.gridX -= 1
					}
	
				case rl.KeyboardKey.RIGHT:
					if (bl.canMoveBrick(currentBrick, environment, "right")){
						currentBrick.gridX += 1
					}
	
				case rl.KeyboardKey.UP:
					if (bl.canRotate(currentBrick, environment)){
						currentBrick.rotation = (currentBrick.rotation + 1) % 4
					}
					else{
						fmt.println("can't rotate :(")
					}
				
				case rl.KeyboardKey.R:
					restart(&currentBrick, &cells, &environment)
			}
		}

		if rl.GetKeyPressed() == rl.KeyboardKey.R {
			restart(&currentBrick, &cells, &environment)
		}

		if currentBrick.isAlive {
			if rl.IsKeyDown(rl.KeyboardKey.DOWN) {
				fallingSpeed = 20 * FALLING_SPEED
			}
			else {
				fallingSpeed = FALLING_SPEED
			}
		}
		else {
			fallingSpeed = FALLING_SPEED
		}

	}

}