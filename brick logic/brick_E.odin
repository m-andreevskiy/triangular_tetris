package logic

getBrickStructure_E :: proc () -> [4][dynamic]BrickCell {
  structure: [4][dynamic]BrickCell
  
  // rotation 0
  append(&structure[0],
          BrickCell{position = {0, -1}, bl = true},
          BrickCell{position = {0, 0}, tl = true},
          BrickCell{position = {-1, -1}, br = true, tl = true},
  )


  // rotation 1
  append(&structure[1],
          BrickCell{position = {0, 0}, tl = true},
          BrickCell{position = {0, -1}, bl = true, tr = true},
          BrickCell{position = {-1, 0}, tr = true},
  )

  
  // rotation 2
  append(&structure[2],
          BrickCell{position = {-1, -1}, br = true},
          BrickCell{position = {-1, 0}, tr = true},
          BrickCell{position = {0, 0}, tl = true, br = true},
  )

  
  // rotation 3
  append(&structure[3],
          BrickCell{position = {-1, -1}, br = true},
          BrickCell{position = {-1, 0}, tr = true, bl = true},
          BrickCell{position = {0, -1}, bl = true},
  )


  return structure
}

canRotate_E :: proc (brick: BrickEx, env: Environment) -> bool {

	dangerCell1 : Cell
	dangerCell2 : Cell
  
  switch brick.rotation {
    case 0, 2:
      dangerCell1 = env.cells[(brick.gridY - 1) * env.columns + brick.gridX]
      dangerCell2 = env.cells[(brick.gridY) * env.columns + brick.gridX - 1]

      if ( dangerCell1.tr || dangerCell1.br || dangerCell1.bl || dangerCell1.tl
        || dangerCell2.tr || dangerCell2.br || dangerCell2.bl || dangerCell2.tl
      ){
        return false
      }

    case 1, 3:
      dangerCell1 = env.cells[(brick.gridY - 1) * env.columns + brick.gridX - 1]
      dangerCell2 = env.cells[(brick.gridY) * env.columns + brick.gridX]

      if ( dangerCell1.tr || dangerCell1.br || dangerCell1.bl || dangerCell1.tl
        || dangerCell2.tr || dangerCell2.br || dangerCell2.bl || dangerCell2.tl
      ){
        return false
      }
  }
  
  return true
  
}