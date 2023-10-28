import 'package:gamestream_flutter/gamestream/isometric/ui/isometric_constants.dart';
import 'package:gamestream_flutter/packages/common.dart';

class AtlasNodeX {
  static const Bau_Haus_Solid = 520.0;
  static const Bau_Haus_Half = Bau_Haus_Solid;
  static const Bau_Haus_Corner = Bau_Haus_Half;
  static const Bau_Haus_Slope = Bau_Haus_Solid + IsometricConstants.Sprite_Width_Padded;
  static const Brick_Solid = IsometricConstants.Sprite_Width_Padded_2;
  static const Brick_Half_West = Brick_Solid + IsometricConstants.Sprite_Width_Padded;
  static const Brick_Half_South = Brick_Half_West + IsometricConstants.Sprite_Width_Padded;
  static const Brick_Corner_Top = Brick_Half_South + IsometricConstants.Sprite_Width_Padded;
  static const Brick_Corner_Right = Brick_Corner_Top + IsometricConstants.Sprite_Width_Padded;
  static const Brick_Corner_Bottom = Brick_Corner_Right + IsometricConstants.Sprite_Width_Padded;
  static const Brick_Corner_Left = Brick_Corner_Bottom + IsometricConstants.Sprite_Width_Padded;
  static const Brick_Slope_Symmetric_North = Brick_Corner_Left + IsometricConstants.Sprite_Width_Padded;
  static const Brick_Slope_Symmetric_East = Brick_Slope_Symmetric_North + IsometricConstants.Sprite_Width_Padded;
  static const Brick_Slope_Symmetric_South = Brick_Slope_Symmetric_East + IsometricConstants.Sprite_Width_Padded;
  static const Brick_Slope_Symmetric_West = Brick_Slope_Symmetric_South + IsometricConstants.Sprite_Width_Padded;
  static const Spawn_Weapon = 0.0;
  static const Spawn_Zombie = 0.0;
  static const Chimney = 618.0;
  static const Table = 667.0;
  static const Tree_Top = 1668.0;
  static const Tree_Bottom = 1606.0;
  static const Water = 1606.0;
  static const Grass = 0.0;
  static const Grass_Long = 1218.0;
  static const Grass_Flowers = 49.0;
  static const Torch = 1659.0;
  static const Stone = 1508.0;
  static const Plain_Solid = 1557.0;
  static const Oven = 618.0;
  static const Boulder = 1344.0;
  static const Wireframe_Blue = 1704.0;
  static const Wireframe_Red = 1704.0;
  static const Orientation_Solid = 0.0;
  static const Orientation_Half = 1018.0;
  static const Orientation_Slope_Symmetric = 1018.0;
  static const Orientation_Corner = 1067.0;
  static const Orientation_Slope_Inner = 1067.0;
  static const Orientation_Slope_Outer = 1067.0;
  static const Orientation_Empty = 1018.0;
  static const Orientation_Radial = 1888.0;


  static double mapNodeType(int type) => const {
    NodeType.Brick: IsometricConstants.Sprite_Width_Padded_2,
    NodeType.Grass: IsometricConstants.Sprite_Width_Padded_3,
    NodeType.Metal: IsometricConstants.Sprite_Width_Padded_4,
    NodeType.Wood: IsometricConstants.Sprite_Width_Padded_5,
    NodeType.Bau_Haus: IsometricConstants.Sprite_Width_Padded_6,
    NodeType.Soil: IsometricConstants.Sprite_Width_Padded_7,
    NodeType.Concrete: IsometricConstants.Sprite_Width_Padded_8,
    NodeType.Road: IsometricConstants.Sprite_Width_Padded_9,
    NodeType.Sandbag: IsometricConstants.Sprite_Width_Padded_11,
    NodeType.Tile: IsometricConstants.Sprite_Width_Padded_12,
    NodeType.Bricks_Red: IsometricConstants.Sprite_Width_Padded_13,
    NodeType.Bricks_Brown: IsometricConstants.Sprite_Width_Padded_14,
    NodeType.Scaffold: IsometricConstants.Sprite_Width_Padded_15,
    NodeType.Torch: Torch,
    NodeType.Grass_Long: Grass_Long,
    NodeType.Grass_Flowers: Grass_Flowers,
    NodeType.Tree_Bottom: Tree_Bottom,
    NodeType.Wooden_Plank: AtlasNode.Wooden_Plank_Solid_X,
    NodeType.Empty: 0.0,
    NodeType.Water: Water,
    NodeType.Chimney: Chimney,
    NodeType.Table: Table,
    NodeType.Fireplace: 1753.0,
    NodeType.Sunflower: 1753.0,
    NodeType.Tree_Top: Tree_Top,
    NodeType.Oven: Oven,
    NodeType.Window: 1508.0,
    NodeType.Boulder: Boulder,
    NodeType.Road_2: 1490.0,
    NodeType.Shopping_Shelf: 1441.0,
    NodeType.Bookshelf: 1392.0,
  }[type] ?? 7055;
}

class AtlasNodeY {
  static const Water = 509.0;
  static const Stone = 0.0;
  static const Plain_Solid = 0.0;
  static const Torch = 749.0;
  static const Water_Flowing = 0.0;
  static const Window = 80.0;
  static const Oven = 804.0;
  static const Boulder = 160.0;
  static const Wireframe_Blue = 509.0;
  static const Wireframe_Red = 582.0;
  static const Orientation_Solid = 512.0;
  static const Orientation_Half_North = 586.0;
  static const Orientation_Half_East = Orientation_Half_North + AtlasNode.Sprite_Height_Padded;
  static const Orientation_Half_South = Orientation_Half_East + AtlasNode.Sprite_Height_Padded;
  static const Orientation_Half_West = Orientation_Half_South + AtlasNode.Sprite_Height_Padded;
  static const Orientation_Corner_Top = 512.0;
  static const Orientation_Corner_Right = Orientation_Corner_Top + AtlasNode.Sprite_Height_Padded;
  static const Orientation_Corner_Bottom = Orientation_Corner_Right + AtlasNode.Sprite_Height_Padded;
  static const Orientation_Corner_Left = Orientation_Corner_Bottom + AtlasNode.Sprite_Height_Padded;
  static const Orientation_Slope_Outer_South_West = Orientation_Corner_Left + AtlasNode.Sprite_Height_Padded;
  static const Orientation_Slope_Outer_North_West = Orientation_Slope_Outer_South_West + AtlasNode.Sprite_Height_Padded;
  static const Orientation_Slope_Outer_North_East = Orientation_Slope_Outer_North_West + AtlasNode.Sprite_Height_Padded;
  static const Orientation_Slope_Outer_South_East = Orientation_Slope_Outer_North_East + AtlasNode.Sprite_Height_Padded;
  static const Orientation_Slope_Inner_South_East = Orientation_Slope_Outer_South_East + AtlasNode.Sprite_Height_Padded;
  static const Orientation_Slope_Inner_North_East = Orientation_Slope_Inner_South_East + AtlasNode.Sprite_Height_Padded;
  static const Orientation_Slope_Inner_North_West = Orientation_Slope_Inner_North_East + AtlasNode.Sprite_Height_Padded;
  static const Orientation_Slope_Inner_South_West = Orientation_Slope_Inner_North_West + AtlasNode.Sprite_Height_Padded;
  static const Orientation_Empty = 1185.0;

  static double mapNodeType(int type) => const {
    NodeType.Water: Water,
    NodeType.Torch: Torch,
    NodeType.Water_Flowing: Water_Flowing,
    NodeType.Window: Window,
    NodeType.Wooden_Plank: 0.0,
    NodeType.Chimney: 730.0,
    NodeType.Table: 945.0,
    NodeType.Fireplace: 434.0,
    NodeType.Sunflower: 867.0,
    NodeType.Tree_Top: 433.0,
    NodeType.Tree_Bottom: 433.0,
    NodeType.Oven: Oven,
    NodeType.Boulder: Boulder,
    NodeType.Road_2: 305.0,
    NodeType.Shopping_Shelf: 160.0,
    NodeType.Bookshelf: 233.0,
  }[type] ?? 0;

  static double mapOrientation(int orientation) {
    if (orientation == NodeOrientation.Solid)
      return 0;
    if (orientation == NodeOrientation.Slope_North)
      return IsometricConstants.Sprite_Height_Padded_07;
    if (orientation == NodeOrientation.Slope_East)
      return IsometricConstants.Sprite_Height_Padded_08;
    if (orientation == NodeOrientation.Slope_South)
      return IsometricConstants.Sprite_Height_Padded_09;
    if (orientation == NodeOrientation.Slope_West)
      return IsometricConstants.Sprite_Height_Padded_10;
    if (orientation == NodeOrientation.Half_North)
      return IsometricConstants.Sprite_Height_Padded_01;
    if (orientation == NodeOrientation.Half_East)
      return IsometricConstants.Sprite_Height_Padded_02;
    if (orientation == NodeOrientation.Half_South)
      return IsometricConstants.Sprite_Height_Padded_01;
    if (orientation == NodeOrientation.Half_West)
      return IsometricConstants.Sprite_Height_Padded_02;
    if (orientation == NodeOrientation.Corner_North_East)
      return IsometricConstants.Sprite_Height_Padded_03;
    if (orientation == NodeOrientation.Corner_South_East)
      return IsometricConstants.Sprite_Height_Padded_04;
    if (orientation == NodeOrientation.Corner_South_West)
      return IsometricConstants.Sprite_Height_Padded_05;
    if (orientation == NodeOrientation.Corner_North_West)
      return IsometricConstants.Sprite_Height_Padded_06;
    if (orientation == NodeOrientation.Slope_Outer_South_West)
      return Orientation_Slope_Outer_South_West;
    if (orientation == NodeOrientation.Slope_Outer_North_West)
      return Orientation_Slope_Outer_North_West;
    if (orientation == NodeOrientation.Slope_Outer_North_East)
      return Orientation_Slope_Outer_North_East;
    if (orientation == NodeOrientation.Slope_Outer_South_East)
      return Orientation_Slope_Outer_South_East;
    if (orientation == NodeOrientation.Slope_Inner_South_East)
      return Orientation_Slope_Inner_South_East;
    if (orientation == NodeOrientation.Slope_Inner_North_East)
      return Orientation_Slope_Inner_North_East;
    if (orientation == NodeOrientation.Slope_Inner_North_West)
      return Orientation_Slope_Inner_North_West;
    if (orientation == NodeOrientation.Slope_Inner_South_West)
      return Orientation_Slope_Inner_South_West;
    if (orientation == NodeOrientation.Radial)
      return IsometricConstants.Sprite_Height_Padded_19;
    if (NodeOrientation.isHalfVertical(orientation))
      return IsometricConstants.Sprite_Height_Padded_20;
    if (NodeOrientation.isColumn(orientation))
      return IsometricConstants.Sprite_Height_Padded_21;
    if (orientation == NodeOrientation.None)
      return 79.0;
    throw Exception('AtlasNodeY.mapOrientation(${NodeOrientation.getName(orientation)}');
  }
}


class AtlasNodeAnchorY{
  static const Torch = 0.33;
}

class AtlasNodeWidth {
  static double mapNodeType(int type) => const {
    NodeType.Torch: AtlasNode.Width_Torch,
    NodeType.Tree_Bottom: AtlasNode.Width_Tree_Bottom,
    NodeType.Tree_Top: 62.0,
  }[type] ?? 48;
}

class AtlasNodeHeight {
  static double mapNodeType(int type) => const {

  }[type] ?? 72;
}

class AtlasParticleX {
  static const Blood = 0.0;
}

class AtlasParticleY {
  static const Blood = 72.0;
}

class AtlasNode {
  static const Sprite_Width = 48.0;
  static const Sprite_Height = 72.0;
  static const Sprite_Width_Padded = Sprite_Width + 1;
  static const Sprite_Height_Padded = Sprite_Height + 1;
  static const Node_Grass_Slope_North = 49 + Sprite_Width_Padded;
  static const Node_Grass_Slope_East = Node_Grass_Slope_North + Sprite_Width_Padded;
  static const Node_Grass_Slope_South = Node_Grass_Slope_East + Sprite_Width_Padded;
  static const Node_Grass_Slope_West = Node_Grass_Slope_South + Sprite_Width_Padded;
  static const Node_Grass_Slope_Inner_South_East = Node_Grass_Slope_West + Sprite_Width_Padded;
  static const Node_Grass_Slope_Inner_North_East = Node_Grass_Slope_Inner_South_East + Sprite_Width_Padded;
  static const Node_Grass_Slope_Inner_North_West = Node_Grass_Slope_Inner_North_East + Sprite_Width_Padded;
  static const Node_Grass_Slope_Inner_South_West = Node_Grass_Slope_Inner_North_West + Sprite_Width_Padded;
  static const Node_Grass_Slope_Outer_South_East = Node_Grass_Slope_Inner_South_West + Sprite_Width_Padded;
  static const Node_Grass_Slope_Outer_North_East = Node_Grass_Slope_Outer_South_East + Sprite_Width_Padded;
  static const Node_Grass_Slope_Outer_North_West = Node_Grass_Slope_Outer_North_East + Sprite_Width_Padded;
  static const Node_Grass_Slope_Outer_South_West = 631.0;
  static const Node_Plain_Half_Row_X = 1557.0;
  static const Node_Plain_Half_Row_Y = Sprite_Height_Padded;
  static const Node_Plain_Half_Column_X = 1557.0;
  static const Node_Plain_Half_Column_Y = Sprite_Height_Padded * 2;
  static const Node_Plain_Corner_Top_X = 1557.0;
  static const Node_Plain_Corner_Top_Y = Sprite_Height_Padded * 6;
  static const Node_Plain_Corner_Right_X = 1557.0;
  static const Node_Plain_Corner_Right_Y = Sprite_Height_Padded * 5;
  static const Node_Plain_Corner_Bottom_X = 1557.0;
  static const Node_Plain_Corner_Bottom_Y = Sprite_Height_Padded * 4;
  static const Node_Plain_Corner_Left_X = 1557.0;
  static const Node_Plain_Corner_Left_Y = Sprite_Height_Padded * 3;
  static const Node_Rain_Falling_Heavy_X = 1606.0;
  static const Node_Rain_Falling_Light_X = Node_Rain_Falling_Heavy_X + Sprite_Width_Padded;
  static const Node_Rain_Landing_Light_X = 1704.0;
  static const Node_Rain_Landing_Heavy_X = Node_Rain_Landing_Light_X + Sprite_Width_Padded;
  static const Node_Rain_Landing_Water_X = 1802.0;
  static const Width_Tree_Bottom = 62.0;
  static const Node_Tree_Bottom_Height = 75.0;
  static const Node_Tree_Top_Width = Width_Tree_Bottom;
  static const Node_Tree_Top_Height = Node_Tree_Bottom_Height;
  static const Wood_Solid_X = 177.0;
  static const Node_Wood_Solid_Y = 512.0;
  static const Node_Wood_Half_West_X = Wood_Solid_X + Sprite_Width_Padded;
  static const Node_Wood_Half_West_Y = Node_Wood_Solid_Y;
  static const Node_Wood_Half_South_X = Node_Wood_Half_West_X + Sprite_Width_Padded;
  static const Node_Wood_Half_South_Y = Node_Wood_Solid_Y;
  static const Node_Wood_Corner_Left_X = Node_Wood_Half_South_X + Sprite_Width_Padded;
  static const Node_Wood_Corner_Left_Y = Node_Wood_Solid_Y;
  static const Node_Wood_Corner_Top_X = Node_Wood_Corner_Left_X + Sprite_Width_Padded;
  static const Node_Wood_Corner_Top_Y = Node_Wood_Solid_Y;
  static const Node_Wood_Corner_Right_X = Node_Wood_Corner_Top_X + Sprite_Width_Padded;
  static const Node_Wood_Corner_Right_Y = Node_Wood_Solid_Y;
  static const Node_Wood_Corner_Bottom_X = Node_Wood_Corner_Right_X + Sprite_Width_Padded;
  static const Node_Wood_Corner_Bottom_Y = Node_Wood_Solid_Y;
  static const Node_Bau_Haus_Half_South_X = 520.0;
  static const Node_Bau_Haus_Half_South_Y = 512.0 + Sprite_Height_Padded;
  static const Node_Bau_Haus_Half_West_X = 520.0;
  static const Node_Bau_Haus_Half_West_Y = 512.0 + Sprite_Height_Padded;
  static const Node_Bau_Haus_Corner_Top_X = 520.0;
  static const Node_Bau_Haus_Corner_Top_Y = Node_Bau_Haus_Half_West_Y + Sprite_Height_Padded;
  static const Node_Bau_Haus_Corner_Right_X = 520.0;
  static const Node_Bau_Haus_Corner_Right_Y = Node_Bau_Haus_Corner_Top_Y + Sprite_Height_Padded;
  static const Node_Bau_Haus_Corner_Bottom_X = 520.0;
  static const Node_Bau_Haus_Corner_Bottom_Y = Node_Bau_Haus_Corner_Right_Y + Sprite_Height_Padded;
  static const Node_Bau_Haus_Corner_Left_X = 520.0;
  static const Node_Bau_Haus_Corner_Left_Y = Node_Bau_Haus_Corner_Bottom_Y + Sprite_Height_Padded;
  static const Node_Bau_Haus_Slope_North_X = 569.0;
  static const Node_Bau_Haus_Slope_North_Y = 512.0;
  static const Node_Bau_Haus_Slope_East_X = Node_Bau_Haus_Slope_North_X;
  static const Node_Bau_Haus_Slope_East_Y = Node_Bau_Haus_Slope_North_Y + Sprite_Height_Padded;
  static const Node_Bau_Haus_Slope_South_X = Node_Bau_Haus_Slope_North_X;
  static const Node_Bau_Haus_Slope_South_Y = Node_Bau_Haus_Slope_East_Y + Sprite_Height_Padded;
  static const Node_Bau_Haus_Slope_West_X = Node_Bau_Haus_Slope_North_X;
  static const Node_Bau_Haus_Slope_West_Y = Node_Bau_Haus_Slope_South_Y + Sprite_Height_Padded;
  static const Node_Bau_Haus_Slope_Inner_North_East_X = Node_Bau_Haus_Slope_North_X;
  static const Node_Bau_Haus_Slope_Inner_North_East_Y = Node_Bau_Haus_Slope_West_Y + Sprite_Height_Padded;
  static const Node_Bau_Haus_Slope_Inner_South_East_X = Node_Bau_Haus_Slope_North_X;
  static const Node_Bau_Haus_Slope_Inner_South_East_Y = Node_Bau_Haus_Slope_Inner_North_East_Y + Sprite_Height_Padded;
  static const Node_Bau_Haus_Slope_Inner_South_West_X = Node_Bau_Haus_Slope_North_X;
  static const Node_Bau_Haus_Slope_Inner_South_West_Y = Node_Bau_Haus_Slope_Inner_South_East_Y + Sprite_Height_Padded;
  static const Node_Bau_Haus_Slope_Inner_North_West_X = Node_Bau_Haus_Slope_North_X;
  static const Node_Bau_Haus_Slope_Inner_North_West_Y = Node_Bau_Haus_Slope_Inner_South_West_Y + Sprite_Height_Padded;
  static const Soil_X = 618.0;
  static const Node_Soil_Y = 584.0;
  static const Src_Fireplace_X = 1753.0;
  static const Src_Fireplace_Y = 434.0;
  static const Src_Fireplace_Width = 48.0;
  static const Src_Fireplace_Height = 72.0;
  static const Chimney_X = 618.0;
  static const Node_Chimney_Y = 730.0;
  static const Node_Window_West_X = 618.0;
  static const Node_Window_West_Y = 876.0;
  static const Window_South_X = Node_Window_West_X;
  static const Window_South_Y = Node_Window_West_Y + Sprite_Height_Padded;

  static const Wooden_Plank_Solid_X = 490.0;
  static const Node_Wooden_Plank_Solid_Y = 0.0;
  static const Node_Wooden_Plank_Half_West_X = Wooden_Plank_Solid_X;
  static const Node_Wooden_Plank_Half_West_Y = Node_Wooden_Plank_Solid_Y + Sprite_Height_Padded;
  static const Node_Wooden_Plank_Half_South_X = Wooden_Plank_Solid_X;
  static const Node_Wooden_Plank_Half_South_Y = Node_Wooden_Plank_Half_West_Y + Sprite_Height_Padded;
  static const Node_Wooden_Plank_Corner_Top_X = Wooden_Plank_Solid_X;
  static const Node_Wooden_Plank_Corner_Top_Y = Node_Wooden_Plank_Half_South_Y + Sprite_Height_Padded;
  static const Node_Wooden_Plank_Corner_Right_X = Wooden_Plank_Solid_X;
  static const Node_Wooden_Plank_Corner_Right_Y = Node_Wooden_Plank_Corner_Top_Y + Sprite_Height_Padded;
  static const Node_Wooden_Plank_Corner_Bottom_X = Wooden_Plank_Solid_X;
  static const Node_Wooden_Plank_Corner_Bottom_Y = Node_Wooden_Plank_Corner_Right_Y + Sprite_Height_Padded;
  static const Node_Wooden_Plank_Corner_Left_X = Wooden_Plank_Solid_X;
  static const Node_Wooden_Plank_Corner_Left_Y = Node_Wooden_Plank_Corner_Bottom_Y + Sprite_Height_Padded;
  static const Spawn_X = 1704.0;
  static const Spawn_Y = 655.0;
  static const Spawn_Weapon_X = 0.0;
  static const Spawn_Weapon_Y = 592.0;
  static const Spawn_Player_X = 1655.0;
  static const Spawn_Player_Y = 655.0;
  static const Table_X = 667.0;
  static const Node_Table_Y = 945.0;
  static const Node_Wood_Slope_North_X = 912.0;
  static const Node_Wood_Slope_North_Y = 512.0;
  static const Node_Wood_Slope_East_X = Node_Wood_Slope_North_X - Sprite_Width_Padded;
  static const Node_Wood_Slope_East_Y = Node_Wood_Slope_North_Y;
  static const Node_Wood_Slope_South_X = Node_Wood_Slope_East_X - Sprite_Width_Padded;
  static const Node_Wood_Slope_South_Y = Node_Wood_Slope_North_Y;
  static const Node_Wood_Slope_West_X = Node_Wood_Slope_South_X - Sprite_Width_Padded;
  static const Node_Wood_Slope_West_Y = Node_Wood_Slope_North_Y;
  static const X_Bed_Bottom = 765.0;
  static const Y_Bed_Bottom = 585.0;
  static const X_Bed_Top = X_Bed_Bottom + Sprite_Width_Padded;
  static const Y_Bed_Top = Y_Bed_Bottom;
  static const X_Torch_Windy = 1691.0;
  static const Y_Torch_Windy = 749.0;
  static const Width_Torch = 25.0;
  static const Height_Torch = 51.0;
}