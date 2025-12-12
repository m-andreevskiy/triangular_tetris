package logic

import rl "vendor:raylib"

/** BrickType is a enum so it can be interpreted as index in array. 
    Type "brickColors[int(bickType)]" to use these colors 
  */
brickColors : [9]rl.Color = {
  rl.WHITE,                       // A
  // rl.Color{238, 177, 242, 255},   // B
  rl.YELLOW,                      // B
  rl.LIME,                        // C
  rl.Color{200, 200, 200, 255},   // D
  rl.ORANGE,
  rl.SKYBLUE,
  rl.BLUE,
  rl.BEIGE,
  rl.BROWN,
}
