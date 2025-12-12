package logic

offset_D: Vector2 = {0.5, 0.5}

getBrickStructure_D :: proc () -> [4][dynamic]BrickCell {
  structure: [4][dynamic]BrickCell
  
  // rotation 0
  append(&structure[0],
          BrickCell{position = {-1, 0}, tr = true},
          BrickCell{position = {0, 0}, tl = true, br = true},
          BrickCell{position = {1, 0}, bl = true},
  )


  // rotation 1
  append(&structure[1],
          BrickCell{position = {0, -1}, br = true},
          BrickCell{position = {0, 0}, tr = true, bl = true},
          BrickCell{position = {0, 1}, tl = true},
  )

  
  // rotation 2
  append(&structure[2],
          BrickCell{position = {-1, 0}, tr = true},
          BrickCell{position = {0, 0}, tl = true, br = true},
          BrickCell{position = {1, 0}, bl = true},
  )

  
  // rotation 3
  append(&structure[3],
          BrickCell{position = {0, -1}, br = true},
          BrickCell{position = {0, 0}, tr = true, bl = true},
          BrickCell{position = {0, 1}, tl = true},
  )


  return structure
}

canRotate_D :: proc (brick: BrickEx, env: Environment) -> bool {
	dangerCell1 : Cell
	dangerCell2 : Cell
	dangerCell3 : Cell
	dangerCell4 : Cell
	cautiousCell1 : Cell
	cautiousCell2 : Cell

  switch brick.rotation {
    case 0, 2:
      if brick.gridY > env.rows - 2 {
        return false
      }
      dangerCell1 = env.cells[brick.gridY * env.columns + brick.gridX + 1]
      dangerCell2 = env.cells[(brick.gridY + 1) * env.columns + brick.gridX + 1]
      dangerCell3 = env.cells[brick.gridY * env.columns + brick.gridX - 1]
      dangerCell4 = env.cells[(brick.gridY - 1) * env.columns + brick.gridX - 1]
      cautiousCell1 = env.cells[(brick.gridY - 1) * env.columns + brick.gridX]
      cautiousCell2 = env.cells[(brick.gridY + 1) * env.columns + brick.gridX]

      if ( dangerCell1.tr || dangerCell1.br || dangerCell1.bl || dangerCell1.tl
        || dangerCell2.tr || dangerCell2.br || dangerCell2.bl || dangerCell2.tl
        || dangerCell3.tr || dangerCell3.br || dangerCell3.bl || dangerCell3.tl
        || dangerCell4.tr || dangerCell4.br || dangerCell4.bl || dangerCell4.tl
        || cautiousCell1.tr || cautiousCell1.br || cautiousCell1.bl || cautiousCell1.tl
        || cautiousCell2.tr || cautiousCell2.br || cautiousCell2.bl || cautiousCell2.tl
      ){
        return false
      }

    case 1, 3:
      if brick.gridX < 1 || brick.gridX > env.columns - 2 {
        return false
      }
      dangerCell1 = env.cells[(brick.gridY + 1) * env.columns + brick.gridX]
      dangerCell2 = env.cells[(brick.gridY + 1) * env.columns + brick.gridX - 1]
      dangerCell3 = env.cells[(brick.gridY - 1) * env.columns + brick.gridX]
      dangerCell4 = env.cells[(brick.gridY - 1) * env.columns + brick.gridX + 1]
      cautiousCell1 = env.cells[brick.gridY * env.columns + brick.gridX - 1]
      cautiousCell2 = env.cells[brick.gridY * env.columns + brick.gridX + 1]

      if ( dangerCell1.tr || dangerCell1.br || dangerCell1.bl || dangerCell1.tl
        || dangerCell2.tr || dangerCell2.br || dangerCell2.bl || dangerCell2.tl
        || dangerCell3.tr || dangerCell3.br || dangerCell3.bl || dangerCell3.tl
        || dangerCell4.tr || dangerCell4.br || dangerCell4.bl || dangerCell4.tl
        || cautiousCell1.tr || cautiousCell1.br || cautiousCell1.bl || cautiousCell1.tl
        || cautiousCell2.tr || cautiousCell2.br || cautiousCell2.bl || cautiousCell2.tl
      ){
        return false
      }

  }

  return true
}