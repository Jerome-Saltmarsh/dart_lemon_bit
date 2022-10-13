
import 'render_constants.dart';



class AtlasSrcX {
  static const Sprite_Width = 48;
  /// Padded width each sprite is separated by one empty pixel
  static const Width = Sprite_Width + 1;
  static const Node_Grass = 0.0;
  static const Node_Grass_Flowers = Node_Grass + Width;
  static const Node_Grass_Slope_North = Node_Grass_Flowers + Width;
  static const Node_Grass_Slope_East = Node_Grass_Slope_North + Width;
  static const Node_Grass_Slope_South = Node_Grass_Slope_East + Width;
  static const Node_Grass_Slope_West = Node_Grass_Slope_South + Width;
  static const Node_Grass_Slope_Inner_South_East = Node_Grass_Slope_West + Width;
  static const Node_Grass_Slope_Inner_North_East = Node_Grass_Slope_Inner_South_East + Width;
  static const Node_Grass_Slope_Inner_North_West = Node_Grass_Slope_Inner_North_East + Width;
  static const Node_Grass_Slope_Inner_South_West = Node_Grass_Slope_Inner_North_West + Width;
  static const Node_Grass_Slope_Outer_South_East = Node_Grass_Slope_Inner_South_West + Width;
  static const Node_Grass_Slope_Outer_North_East = Node_Grass_Slope_Outer_South_East + Width;
  static const Node_Grass_Slope_Outer_North_West = Node_Grass_Slope_Outer_North_East + Width;
  static const Node_Grass_Slope_Outer_South_West = Node_Grass_Slope_Outer_North_West + Width;
  static const Node_Brick = 680.0;
  static const Node_Brick_Half_North = Node_Brick + Sprite_Width;
  static const Node_Brick_Half_East = Node_Brick_Half_North + Sprite_Width;
  static const Node_Brick_Half_South = Node_Brick_Half_North;
  static const Node_Brick_Half_West = Node_Brick_Half_East;
  static const Node_Brick_Slope_North = Node_Brick + Sprite_Width;
  static const Node_Brick_Slope_East = 7443.0;
  static const Node_Brick_Slope_South = 7492.0;
  static const Node_Brick_Slope_West = 7541.0;

  static const Node_Brick_Corner_Top = 11524.0;
  static const Node_Brick_Corner_Right = Node_Brick_Corner_Top + spriteWidthPadded;
  static const Node_Brick_Corner_Bottom = Node_Brick_Corner_Right + spriteWidthPadded;
  static const Node_Brick_Corner_Left = Node_Brick_Corner_Bottom + spriteWidthPadded;
  static const Node_Grass_Long = 10240.0 + srcIndexX1;
  static const Node_Stone = 9831.0;
  static const Node_Plain_Solid = 11277.0;
  static const Node_Wooden_Plank = 7688.0;
  static const Node_Wood_Solid = 8886.0;
  static const Node_Wood_Slope_North = 11179.0;
  static const Node_Wood_Slope_East = 11130.0;
  static const Node_Wood_Slope_South = 11082.0;
  static const Node_Wood_Slope_West = 11032.0;
  static const Node_Wood_Half_North = 8983.0;
  static const Node_Wood_Half_East = 8935.0;
  static const Node_Wood_Half_South = 8983.0;
  static const Node_Wood_Half_West = 8935.0;
  static const Node_Wood_Corner_Top = 9082.0;
  static const Node_Wood_Corner_Right = 9131.0;
  static const Node_Wood_Corner_Bottom = 9180.0;
  static const Node_Wood_Corner_Left = 9033.0;
  static const Node_Sunflower = 10934.0;
  static const Node_Soil = 8320.0;
  static const Node_Boulder = 11769.0;
  static const Node_Oven = 10984.0;
  static const Node_Chimney = 10787.0;
  static const Node_Window = 10689.0;
  static const Node_Spawn = 8752.0;
  static const Node_Bau_Haus_Solid = 11720.0;
  static const Node_Bau_Haus_Slope = 11228.0;
  static const Node_Table = 7639.0;
  static const Node_Bed_Bottom = 10836.0;
  static const Node_Bed_Top = 10885.0;
}