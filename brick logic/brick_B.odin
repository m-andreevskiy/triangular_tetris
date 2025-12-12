package logic

getBrickStructure_B :: proc () -> [4][dynamic]BrickCell {
  structure: [4][dynamic]BrickCell
  
  // rotation 0
  append(&structure[0],
          BrickCell{position = {0, -1}, tr = true, bl = true},
          BrickCell{position = {-1, 0}, tr = true},
          BrickCell{position = {-1, -1}, br = true},
  )


  // rotation 1
  append(&structure[1],
          BrickCell{position = {0, 0}, tl = true, br = true},
          BrickCell{position = {0, -1}, bl = true},
          BrickCell{position = {-1, -1}, br = true},
  )

  
  // rotation 2
  append(&structure[2],
          BrickCell{position = {-1, 0}, tr = true, bl = true},
          BrickCell{position = {0, -1}, bl = true},
          BrickCell{position = {0, 0}, tl = true},
  )

  
  // rotation 3
  append(&structure[3],
          BrickCell{position = {-1, -1}, tl = true, br = true},
          BrickCell{position = {-1, 0}, tr = true},
          BrickCell{position = {0, 0}, tl = true},
  )


  return structure
}

canRotate_B :: proc (brick: BrickEx, env: Environment) -> bool {

  dangerCell : Cell
  switch brick.rotation {
    case 0:
      dangerCell = env.cells[brick.gridY * env.columns + brick.gridX] 
    case 1:
      dangerCell = env.cells[brick.gridY * env.columns + brick.gridX - 1] 
    case 2:
      dangerCell = env.cells[(brick.gridY - 1) * env.columns + brick.gridX - 1] 
    case 3:
      dangerCell = env.cells[(brick.gridY - 1) * env.columns + brick.gridX] 
  }
  return !(dangerCell.tr || dangerCell.br || dangerCell.bl || dangerCell.tl)	
  
}