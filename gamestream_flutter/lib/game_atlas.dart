import 'library.dart';

class AtlasNodeX {
  static const Brick_Solid = 680.0;
  static const Spawn_Weapon = 0.0;
  static const Spawn_Player = 49.0;
  static const Spawn_Zombie = 0.0;
  static const Soil = 618.0;
  static const Wood = 177.0;
  static const Wooden_Plank = 716.0;
  static const Bau_Haus = 520.0;
  static const Chimney = 618.0;
  static const Table = 667.0;
  static const Fireplace = 667.0;

  static double mapNodeType(int type) => {
    NodeType.Brick_2: Brick_Solid,
    NodeType.Grass: AtlasNode.Grass,
    NodeType.Torch: AtlasNode.X_Torch,
    NodeType.Grass_Long: AtlasNode.Grass_Long,
    NodeType.Grass_Flowers: AtlasNode.Grass_Flowers,
    NodeType.Brick_Top: 0.0,
    NodeType.Stone: AtlasNode.Stone_X,
    NodeType.Plain: AtlasNode.Plain_Solid_X,
    NodeType.Soil: Soil,
    NodeType.Bau_Haus: AtlasNode.Bau_Haus_Solid_X,
    NodeType.Bed_Bottom: AtlasNode.X_Bed_Bottom,
    NodeType.Bed_Top: AtlasNode.X_Bed_Top,
    NodeType.Sunflower: AtlasNode.Sunflower_X,
    NodeType.Oven: AtlasNode.Oven_X,
    NodeType.Cottage_Roof: -1.0,
    NodeType.Tree_Bottom: AtlasNode.Tree_Bottom_X,
    NodeType.Tree_Top: AtlasNode.Tree_Top_X,
    NodeType.Wooden_Plank: AtlasNode.Wooden_Plank_Solid_X,
    NodeType.Boulder: AtlasNode.Boulder_X,
    NodeType.Spawn: AtlasNode.Spawn_X,
    NodeType.Empty: 0.0,
    NodeType.Water: AtlasNode.Water_X,
    NodeType.Spawn_Weapon: Spawn_Weapon,
    NodeType.Spawn_Player: Spawn_Player,
    NodeType.Wood_2: Wood,
    NodeType.Bau_Haus_2: Bau_Haus,
    NodeType.Chimney: Chimney,
    NodeType.Table: Table,
    NodeType.Fireplace: Fireplace,
  }[type] ?? 7055;
}

class AtlasNodeY {
  static const Spawn_Weapon = 592.0;
  static const Spawn_Player = 592.0;
  static const Spawn_Zombie = 665.0;
  static const Soil = 584.0;
  static const Wood = 512.0;
  static const Wooden_Plank = 512.0;
  static const Bau_Haus = 512.0;
  static const Chimney = 730.0;
  static const Table = 945.0;
  static const Fireplace = 512.0;

  static double mapNodeType(int type) => {
    NodeType.Water: AtlasNode.Water_Y,
    NodeType.Torch: AtlasNode.Y_Torch,
    NodeType.Water_Flowing: 0.0,
    NodeType.Window: AtlasNode.Window_South_Y,
    NodeType.Spawn: AtlasNode.Spawn_Y,
    NodeType.Spawn_Weapon: AtlasNodeY.Spawn_Weapon,
    NodeType.Spawn_Player: AtlasNodeY.Spawn_Player,
    NodeType.Soil: AtlasNodeY.Soil,
    NodeType.Wood_2: AtlasNodeY.Wood,
    NodeType.Wooden_Plank: AtlasNodeY.Wooden_Plank,
    NodeType.Bau_Haus_2: Bau_Haus,
    NodeType.Chimney: Chimney,
    NodeType.Table: Table,
    NodeType.Fireplace: Fireplace,
  }[type] ?? 0;
}

class AtlasNodeWidth {
  static double mapNodeType(int type) => {
    NodeType.Torch: AtlasNode.Width_Torch,
    NodeType.Tree_Bottom: AtlasNode.Width_Tree_Bottom,
    NodeType.Tree_Top: 62.0,
  }[type] ?? 48;
}

class AtlasNodeHeight {
  static double mapNodeType(int type) => {

  }[type] ?? 72;
}


class AtlasNode {
  static const Sprite_Width = 48.0;
  static const Sprite_Height = 72.0;
  static const Sprite_Width_Padded = Sprite_Width + 1;
  static const Sprite_Height_Padded = Sprite_Height + 1;
  static const Grass = 0.0;
  static const Grass_Flowers = Grass + Sprite_Width_Padded;
  static const Node_Grass_Slope_North = Grass_Flowers + Sprite_Width_Padded;
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
  static const Node_Grass_Slope_Outer_South_West = Node_Grass_Slope_Outer_North_West + Sprite_Width_Padded;
  // static const Brick_Solid = 680.0;
  static const Node_Brick_Half_North = AtlasNodeX.Brick_Solid + Sprite_Width;
  static const Node_Brick_Half_East = Node_Brick_Half_North + Sprite_Width;
  static const Node_Brick_Half_South = Node_Brick_Half_North;
  static const Node_Brick_Half_West = Node_Brick_Half_East;
  static const Node_Brick_Slope_North = 1023.0;
  static const Node_Brick_Slope_East = Node_Brick_Slope_North + Sprite_Width_Padded;
  static const Node_Brick_Slope_South = Node_Brick_Slope_East + Sprite_Width_Padded;
  static const Node_Brick_Slope_West = Node_Brick_Slope_South + Sprite_Width_Padded;
  static const Node_Brick_Corner_Top = 11524.0;
  static const Node_Brick_Corner_Right = Node_Brick_Corner_Top + Sprite_Width_Padded;
  static const Node_Brick_Corner_Bottom = Node_Brick_Corner_Right + Sprite_Width_Padded;
  static const Node_Brick_Corner_Left = Node_Brick_Corner_Bottom + Sprite_Width_Padded;
  static const Grass_Long = 1218.0;
  static const Stone_X = 1508.0;
  static const Plain_Solid_X = 1557.0;
  static const Node_Plain_Half_Row_X = Plain_Solid_X;
  static const Node_Plain_Half_Row_Y = Sprite_Height_Padded;
  static const Node_Plain_Half_Column_X = Plain_Solid_X;
  static const Node_Plain_Half_Column_Y = Sprite_Height_Padded * 2;
  static const Node_Plain_Corner_Top_X = Plain_Solid_X;
  static const Node_Plain_Corner_Top_Y = Sprite_Height_Padded * 6;
  static const Node_Plain_Corner_Right_X = Plain_Solid_X;
  static const Node_Plain_Corner_Right_Y = Sprite_Height_Padded * 5;
  static const Node_Plain_Corner_Bottom_X = Plain_Solid_X;
  static const Node_Plain_Corner_Bottom_Y = Sprite_Height_Padded * 4;
  static const Node_Plain_Corner_Left_X = Plain_Solid_X;
  static const Node_Plain_Corner_Left_Y = Sprite_Height_Padded * 3;
  static const Node_Rain_Falling_Light_X = 1606.0;
  static const Node_Rain_Falling_Heavy_X = Node_Rain_Falling_Light_X + Sprite_Width_Padded;
  static const Node_Rain_Landing_Light_X = 1704.0;
  static const Node_Rain_Landing_Heavy_X = Node_Rain_Landing_Light_X + Sprite_Width_Padded;
  static const Node_Rain_Landing_Water_X = 1802.0;
  static const Tree_Bottom_X = 0.0;
  static const Node_Tree_Bottom_Y = 512.0;
  static const Width_Tree_Bottom = 62.0;
  static const Node_Tree_Bottom_Height = 75.0;
  static const Tree_Top_X = Width_Tree_Bottom;
  static const Node_Tree_Top_Y = Node_Tree_Bottom_Y;
  static const Node_Tree_Top_Width = Width_Tree_Bottom;
  static const Node_Tree_Top_Height = Node_Tree_Bottom_Height;
  static const Water_X = 128.0;
  static const Water_Y = 512.0;
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
  static const Bau_Haus_Solid_X = 520.0;
  static const Node_Bau_Haus_Solid_Y = 512.0;
  static const Node_Bau_Haus_Half_South_X = Bau_Haus_Solid_X;
  static const Node_Bau_Haus_Half_South_Y = Node_Bau_Haus_Solid_Y + Sprite_Height_Padded;
  static const Node_Bau_Haus_Half_West_X = Bau_Haus_Solid_X;
  static const Node_Bau_Haus_Half_West_Y = Node_Bau_Haus_Solid_Y + Sprite_Height_Padded;
  static const Node_Bau_Haus_Corner_Top_X = Bau_Haus_Solid_X;
  static const Node_Bau_Haus_Corner_Top_Y = Node_Bau_Haus_Half_West_Y + Sprite_Height_Padded;
  static const Node_Bau_Haus_Corner_Right_X = Bau_Haus_Solid_X;
  static const Node_Bau_Haus_Corner_Right_Y = Node_Bau_Haus_Corner_Top_Y + Sprite_Height_Padded;
  static const Node_Bau_Haus_Corner_Bottom_X = Bau_Haus_Solid_X;
  static const Node_Bau_Haus_Corner_Bottom_Y = Node_Bau_Haus_Corner_Right_Y + Sprite_Height_Padded;
  static const Node_Bau_Haus_Corner_Left_X = Bau_Haus_Solid_X;
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
  static const Sunflower_X = 618.0;
  static const Node_Sunflower_Y = 512.0;
  static const Soil_X = 618.0;
  static const Node_Soil_Y = 584.0;
  static const Campfire_X = 667.0;
  static const Node_Campfire_Y = 512.0;
  static const Boulder_X = 618.0;
  static const Node_Boulder_Y = 657.0;
  static const Chimney_X = 618.0;
  static const Node_Chimney_Y = 730.0;
  static const Oven_X = 618.0;
  static const Node_Oven_Y = 804.0;
  static const Node_Window_West_X = 618.0;
  static const Node_Window_West_Y = 876.0;
  static const Window_South_X = Node_Window_West_X;
  static const Window_South_Y = Node_Window_West_Y + Sprite_Height_Padded;

  static const Wooden_Plank_Solid_X = 716.0;
  static const Node_Wooden_Plank_Solid_Y = 512.0;
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
  static const Spawn_X = 618.0;
  static const Spawn_Y = 1021.0;
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
  static const X_Torch_Windy = 986.0;
  static const X_Torch = 960.0;
  static const Y_Torch = 512.0;
  static const Y_Torch_Windy = 512.0;
  static const Width_Torch = 25.0;
  static const Height_Torch = 70.0;
}