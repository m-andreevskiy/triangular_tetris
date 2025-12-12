package logic

getBrickStructure_C :: proc () -> [4][dynamic]BrickCell {
  structure: [4][dynamic]BrickCell
  
  // rotation 0
  append(&structure[0],
          BrickCell{position = {0, 0}, bl = true},
          BrickCell{position = {-1, 0}, tr = true, bl = true},
          BrickCell{position = {-1, -1}, bl = true},
  )


  // rotation 1
  append(&structure[1],
          BrickCell{position = {-1, 0}, tl = true},
          BrickCell{position = {0, -1}, tl = true},
          BrickCell{position = {-1, -1}, tl = true, br = true},
  )

  
  // rotation 2
  append(&structure[2],
          BrickCell{position = {-1, -1}, tr = true},
          BrickCell{position = {0, -1}, tr = true, bl = true},
          BrickCell{position = {0, 0}, tr = true},
  )

  
  // rotation 3
  append(&structure[3],
          BrickCell{position = {0, -1}, br = true},
          BrickCell{position = {-1, 0}, br = true},
          BrickCell{position = {0, 0}, tl = true, br = true},
  )


  return structure
}

canRotate_C :: proc (brick: BrickEx, env: Environment) -> bool {
	dangerCell1 : Cell
	cautiousCell1 : Cell

  switch brick.rotation {
    case 0:
      dangerCell1 = env.cells[(brick.gridY - 1) * env.columns + brick.gridX - 1]
      cautiousCell1 = env.cells[(brick.gridY - 1) * env.columns + brick.gridX]

      if ( dangerCell1.tr || dangerCell1.br || dangerCell1.bl || dangerCell1.tl
        || cautiousCell1.tr || cautiousCell1.bl || cautiousCell1.tl
      ){
        return false
      }

    case 1:
      dangerCell1 = env.cells[(brick.gridY - 1) * env.columns + brick.gridX ]
      cautiousCell1 = env.cells[brick.gridY * env.columns + brick.gridX]

      if ( dangerCell1.tr || dangerCell1.br || dangerCell1.bl || dangerCell1.tl
        || cautiousCell1.tr || cautiousCell1.br || cautiousCell1.tl
      ){
        return false
      }

    case 2:
      dangerCell1 = env.cells[(brick.gridY) * env.columns + brick.gridX]
      cautiousCell1 = env.cells[(brick.gridY) * env.columns + brick.gridX - 1]

      if ( dangerCell1.tr || dangerCell1.br || dangerCell1.bl || dangerCell1.tl
        || cautiousCell1.tr || cautiousCell1.bl || cautiousCell1.br
      ){
        return false
      }

    case 3:
      dangerCell1 = env.cells[(brick.gridY) * env.columns + brick.gridX - 1]
      cautiousCell1 = env.cells[(brick.gridY - 1) * env.columns + brick.gridX - 1]

      if ( dangerCell1.tr || dangerCell1.br || dangerCell1.bl || dangerCell1.tl
        || cautiousCell1.bl || cautiousCell1.br || cautiousCell1.tl
      ){
        return false
      }
  }
  return true
  
}