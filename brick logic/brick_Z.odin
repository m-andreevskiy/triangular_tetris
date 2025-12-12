package logic

offset_Z: Vector2 = {0, 0}

getBrickStructure_Z :: proc () -> [4][dynamic]BrickCell {
  structure: [4][dynamic]BrickCell
  
  // rotation 0
  append(&structure[0],
          BrickCell{position = {0, 0}, tl = true},
          BrickCell{position = {-1, 0}, tr = true},
          BrickCell{position = {0, -1}, bl = true},
          BrickCell{position = {-1, -1}, br = true},
  )


  // rotation 1
  append(&structure[1],
          BrickCell{position = {0, 0}, tl = true},
          BrickCell{position = {-1, 0}, tr = true},
          BrickCell{position = {0, -1}, bl = true},
          BrickCell{position = {-1, -1}, br = true},
  )

  
  // rotation 2
  append(&structure[2],
          BrickCell{position = {0, 0}, tl = true},
          BrickCell{position = {-1, 0}, tr = true},
          BrickCell{position = {0, -1}, bl = true},
          BrickCell{position = {-1, -1}, br = true},
  )

  
  // rotation 3
  append(&structure[3],
          BrickCell{position = {0, 0}, tl = true},
          BrickCell{position = {-1, 0}, tr = true},
          BrickCell{position = {0, -1}, bl = true},
          BrickCell{position = {-1, -1}, br = true},
  )


  return structure
}

canRotate_Z :: proc (brick: BrickEx, env: Environment) -> bool {

  return true
}