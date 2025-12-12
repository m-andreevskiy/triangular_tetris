package logic

import "core:fmt"
import "core:time"
import rl "vendor:raylib"

CELL_SIZE : i32 = 30
COMPLETE_ROW : i32 = 10
COMPLETE_ROWS : [dynamic]i32

isHalt := false

initCellSize :: proc (size: i32) {
  CELL_SIZE = size
}

Environment :: struct {
    rows: i32,
    columns: i32,
    cells: [dynamic]Cell
}

/** Cell is 'divided' into 4 triangles. Each field says whether the triangle is occupied or not
    (Only two triangles can fit in one cell: tr+bl or tl+br )
  */
Cell :: struct {
    tr: bool,
    br: bool,
    bl: bool,
    tl: bool,
    triangles: [dynamic]Triangle
}

Triangle :: struct {
  first: [2]f32,
  second: [2]f32,
  third: [2]f32,
  color: rl.Color
}

TriangleType :: enum {
  tr,   // top-right
  br,   // bottom-right
  bl,   // bottom-left
  tl    // top-left
}

line_highlight_shader : cstring = `
  #version 330
  in vec2 fragTexCoord;

  out vec4 finalColor;

  uniform int lineToHighlight;
  uniform int cellSize;

  uniform vec2 resolution;

  uniform ivec3 hightlightRows;

  uniform float time;

  void main(){
    vec2 fragCoord = gl_FragCoord.xy;
    fragCoord.y = resolution.y - fragCoord.y;

    float intensity = 0.0;

    for(int i = 0; i < hightlightRows.length(); i++) {
      if (hightlightRows[i] != 0) {
        if (fragCoord.y > hightlightRows[i] * cellSize && fragCoord.y < (hightlightRows[i] + 1) * cellSize){
          intensity = 0.7;
        }

      }
    }


    finalColor = vec4(0.9, 0.0, 1.0, 1.0) * (intensity) * sin(time);
    
  }
`
    // if (fragCoord.y > lineToHighlight * cellSize && fragCoord.y < (lineToHighlight + 1) * cellSize){
    //   intensity = 0.6;
    // }

  createTriangle :: proc (type: TriangleType, cellSize: f32, color: rl.Color) -> Triangle {
  res : Triangle
  res.color = color

  switch type {
    case TriangleType.tr:
      res.first = {0, 0}
      res.second = {cellSize, cellSize}
      res.third = {cellSize, 0}

    case TriangleType.br:
      res.first = {cellSize, 0}
      res.second = {0, cellSize}
      res.third = {cellSize, cellSize}

    case TriangleType.bl:
      res.first = {0, 0}
      res.second = {0, cellSize}
      res.third = {cellSize, cellSize}

    case TriangleType.tl:
      res.first = {0, 0}
      res.second = {0, cellSize}
      res.third = {cellSize, 0}
  }

  return res
}

initCells :: proc (cells: ^[dynamic]Cell, rows: i32, columns: i32) {
    clear(cells)

    for i : i32 = 0; i < rows * columns; i += 1 {
        append(cells, Cell{tr=false, br=false, bl=false, tl=false})
    }
}


printEnvironment :: proc (env: Environment) {
    fmt.println("printing environment:")

    for i : i32 = 0; i < env.rows; i += 1 {
        for j : i32 = 0; j < env.columns; j += 1 {
            cell := env.cells[i*env.columns + j]
            fmt.print((cell.tr || cell.br || cell.bl || cell.tl) ? 1 : 0)
            fmt.print(" ")
        } 

        fmt.println()
    }
}

drawEnvironment :: proc (env: Environment) {
  for i : i32 = 0; i < env.rows; i += 1 {
    for j : i32 = 0; j < env.columns; j += 1 {
      snappedX := j * CELL_SIZE
      snappedY := i * CELL_SIZE
      cellPos : rl.Vector2 = {f32(snappedX), f32(snappedY)}  

      for t : int = 0; t < len(env.cells[i * env.columns + j].triangles); t += 1 {
        triangle := env.cells[i * env.columns + j].triangles[t]

        rl.DrawTriangle(cellPos + rl.Vector2(triangle.first), cellPos + rl.Vector2(triangle.second), cellPos + rl.Vector2(triangle.third), triangle.color)
			  rl.DrawTriangleLines(cellPos + rl.Vector2(triangle.first), cellPos + rl.Vector2(triangle.second), cellPos + rl.Vector2(triangle.third), rl.DARKGRAY)
      }
    }
  }
}

appendTriangleToCell :: proc (cell: ^Cell, type: TriangleType, color: rl.Color) {
  cellsize : f32 = f32(CELL_SIZE)

  switch type { 
    case TriangleType.tr:
      cell.tr = true
      append(
        &cell.triangles, 
        createTriangle(type, cellsize, color),
      )

    case TriangleType.br:
      cell.br = true
      append(
        &cell.triangles, 
        createTriangle(type, cellsize, color),
      )

    case TriangleType.bl:
      cell.bl = true
      append(
        &cell.triangles, 
        createTriangle(type, cellsize, color),
      )

    case TriangleType.tl:
      cell.tl = true
      append(
        &cell.triangles, 
        createTriangle(type, cellsize, color),
      )
  }
}

appendBrickToEnvironmentEx :: proc (env: ^Environment, brick: BrickEx) -> i32 {
  form := brick.form[brick.rotation]

  for cell in form {
    appendCellToEnvironment(env, cell, brick)
  }

  scoreGain := checkRows(env^)
  return scoreGain
}

appendCellToEnvironment :: proc (env: ^Environment, cell: BrickCell, brick: BrickEx) {
  cellX := brick.gridX + cell.position[0]
  cellY := brick.gridY + cell.position[1]

  if cell.tr {
    appendTriangleToCell(&env.cells[cellY * env.columns + cellX], TriangleType.tr, brick.color)
  }
  if cell.br {
    appendTriangleToCell(&env.cells[cellY * env.columns + cellX], TriangleType.br, brick.color)
  }
  if cell.bl {
    appendTriangleToCell(&env.cells[cellY * env.columns + cellX], TriangleType.bl, brick.color)
  }
  if cell.tl {
    appendTriangleToCell(&env.cells[cellY * env.columns + cellX], TriangleType.tl, brick.color)
  }
}


checkRows :: proc (env: Environment) -> i32 {
  score : i32 = 0
  lines : i32 = 0

  for row : i32 = 0; row < env.rows; row += 1 {
    if (isRowFull(env, row)) {

      append(&COMPLETE_ROWS, row)
  
      lines += 1
      score += 10

      /*
      for r : i32 = row; r > 1; r -= 1 {
        for i : i32 = 0; i < env.columns; i += 1{
          // copy cell which is on top of this cell
          env.cells[r * env.columns + i] = env.cells[(r - 1) * env.columns + i]
        }
      }
      */
    }
  }

  fmt.println("c rows: ", &COMPLETE_ROWS)

  return i32(f32(score) * getScoreMultiplier(lines))
}


clearRows :: proc (env: Environment) {
  for row : i32 = 0; row < env.rows; row += 1 {
    if (isRowFull(env, row)) {      
      for r : i32 = row; r > 1; r -= 1 {
        for i : i32 = 0; i < env.columns; i += 1{
          // copy cell which is on top of this cell
          env.cells[r * env.columns + i] = env.cells[(r - 1) * env.columns + i]
        }
      }
      
    }
  }

}


isRowFull :: proc (env: Environment, row: i32) -> bool {
  for i : i32 = 0; i < env.columns; i += 1 {
    if (!isCellFull(env.cells[row * env.columns + i])){
      return false
    }
  }

  return true
}

isCellFull :: proc (cell: Cell) -> bool {
  return (cell.tr && cell.bl) || (cell.tl && cell.br)
}

getScoreMultiplier :: proc (lines: i32) -> f32 {
  switch lines {
    case 1:
      return 1
    case 2:
      return 1.5
    case 3:
      return 2
    case 4: 
      return 3
    
    case: 
      return 4
    }
}
