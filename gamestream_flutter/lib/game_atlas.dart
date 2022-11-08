import 'library.dart';

class AtlasItems {
  static double getSrcX(int itemType) => <int, double> {
      ItemType.Weapon_Melee_Sword: 0,
      ItemType.Weapon_Melee_Magic_Staff: 32,
      ItemType.Weapon_Ranged_Bow: 64,
      ItemType.Empty: 224,
      ItemType.Head_Steel_Helm: 128,
      ItemType.Head_Rogues_Hood: 160,
      ItemType.Head_Wizards_Hat: 192,
      ItemType.Weapon_Ranged_Shotgun: 0,
      ItemType.Weapon_Ranged_Handgun: 32,
      ItemType.Body_Shirt_Blue: 64,
      ItemType.Body_Shirt_Cyan: 96,
      ItemType.Body_Tunic_Padded: 128,
      ItemType.Body_Swat: 128,
      ItemType.Resource_Ammo_9mm: 256,
      ItemType.Legs_Blue: 224,
      ItemType.Legs_Brown: 192,
      ItemType.Recipe_Staff_Of_Fire: 0,
      ItemType.Resource_Wood: 32,
      ItemType.Resource_Stone: 64,
      ItemType.Resource_Crystal: 96,
      ItemType.Resource_Gold: 128,
  }[itemType] ?? 0;

  static double getSrcY(int itemType) => <int, double> {
    ItemType.Weapon_Ranged_Shotgun: 32,
    ItemType.Weapon_Ranged_Handgun: 32,
    ItemType.Body_Shirt_Blue: 32,
    ItemType.Body_Shirt_Cyan: 32,
    ItemType.Body_Tunic_Padded: 32,
    ItemType.Body_Swat: 32,
    ItemType.Legs_Blue: 32,
    ItemType.Legs_Brown: 32,
    ItemType.Recipe_Staff_Of_Fire: 64,
    ItemType.Resource_Wood: 64,
    ItemType.Resource_Stone: 64,
    ItemType.Resource_Crystal: 64,
    ItemType.Resource_Gold: 64,
  }[itemType] ?? 0;
}

class AtlasIconsX {
  static const Arrows_Yellow = 0.0;
  static const Arrows_Orange = 22.0;
  static const Home = 44.0;
  static const Fullscreen = 93.0;
  static const Zoom = 48.0;
  static const Weather_Inactive = 153.0;
  static const Weather_Active = 217.0;
  static const Slot = 288.0;

  // static double getWeaponType(int weaponType) => <int, double> {
  //   AttackType.Blade: 288,
  //   AttackType.Shotgun: 288,
  //   AttackType.Rifle: 288,
  //   AttackType.Assault_Rifle: 288,
  //   AttackType.Staff: 318,
  //   AttackType.Unarmed: 384,
  //   AttackType.Handgun: 320,
  // } [weaponType] ?? 0.0;

  // static double getBodyType(int bodyType) => <int, double> {
  //     BodyType.shirtBlue: 352,
  //     BodyType.shirtCyan: 384,
  //     BodyType.swat: 416,
  //     BodyType.tunicPadded: 448,
  // } [bodyType] ?? 0.0;

  // static double getHeadType(int headType) => <int, double> {
  //     HeadType.Steel_Helm: 416,
  //     HeadType.Rogues_Hood: 448,
  //     HeadType.Wizards_Hat: 480,
  // } [headType] ?? 0.0;
}

class AtlasIconsY {
  static const Arrows_Up = 0.0;
  static const Arrows_Down = 26.0;
  static const Arrows_South = 56.0;
  static const Arrows_West = 83.0;
  static const Arrows_North = 110.0;
  static const Arrows_East = 137.0;
  static const Home = 0.0;
  static const Fullscreen = 0.0;
  static const Zoom = 48.0;
  static const Slot = 64.0;

  // static double getWeaponType(int weaponType) => <int, double> {
  //   AttackType.Staff: 0,
  //   AttackType.Blade: 0,
  //   AttackType.Unarmed: 0,
  //   AttackType.Shotgun: 32,
  //   AttackType.Rifle: 32,
  //   AttackType.Assault_Rifle: 32,
  //   AttackType.Handgun: 32,
  // } [weaponType] ?? 0.0;

  // static double getBodyType(int bodyType) => <int, double> {
  //   BodyType.shirtBlue: 32,
  //   BodyType.shirtCyan: 32,
  //   BodyType.tunicPadded: 32,
  //   BodyType.swat: 32,
  // } [bodyType] ?? 0.0;

  // static double getHeadType(int bodyType) => <int, double> {
  //   HeadType.Steel_Helm: 0,
  // } [bodyType] ?? 0.0;
}

class AtlasIconSize {
  static const Home = 48.0;
  static const Fullscreen = 48.0;
  static const Zoom = 32.0;
  static const Default = 32.0;
  static const Slot = 32.0;

  static double getWeaponType(int weaponType) => <int, double> {
  } [weaponType] ?? Default;

  static double getBodyType(int bodyType) => <int, double> {
  } [bodyType] ?? Default;

  static double getHeadType(int bodyType) => <int, double> {
  } [bodyType] ?? Default;
}

class AtlasNodeX {
  static const Bau_Haus_Solid = 520.0;
  static const Bau_Haus_Half = Bau_Haus_Solid;
  static const Bau_Haus_Corner = Bau_Haus_Half;
  static const Bau_Haus_Slope = Bau_Haus_Solid + GameConstants.Sprite_Width_Padded;
  static const Brick_Solid = 680.0;
  static const Brick_Half_West = Brick_Solid + GameConstants.Sprite_Width_Padded;
  static const Brick_Half_South = Brick_Half_West + GameConstants.Sprite_Width_Padded;
  static const Brick_Corner_Top = Brick_Half_South + GameConstants.Sprite_Width_Padded;
  static const Brick_Corner_Right = Brick_Corner_Top + GameConstants.Sprite_Width_Padded;
  static const Brick_Corner_Bottom = Brick_Corner_Right + GameConstants.Sprite_Width_Padded;
  static const Brick_Corner_Left = Brick_Corner_Bottom + GameConstants.Sprite_Width_Padded;
  static const Brick_Slope_Symmetric_North = Brick_Corner_Left + GameConstants.Sprite_Width_Padded;
  static const Brick_Slope_Symmetric_East = Brick_Slope_Symmetric_North + GameConstants.Sprite_Width_Padded;
  static const Brick_Slope_Symmetric_South = Brick_Slope_Symmetric_East + GameConstants.Sprite_Width_Padded;
  static const Brick_Slope_Symmetric_West = Brick_Slope_Symmetric_South + GameConstants.Sprite_Width_Padded;
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
  static const Sunflower = 618.0;
  static const Tree_Top = 62.0;
  static const Tree_Bottom = 0.0;
  static const Water = 128.0;
  static const Grass = 0.0;
  static const Grass_Long = 1218.0;
  static const Grass_Flowers = 49.0;
  static const Torch = 960.0;
  static const Stone = 1508.0;
  static const Plain_Solid = 1557.0;
  static const Oven = 618.0;
  static const Window = 618.0;
  static const Boulder = 618.0;
  static const Wireframe_Blue = 0.0;
  static const Wireframe_Red = 49.0;
  static const Orientation_Solid = 1018.0;
  static const Orientation_Half = 1018.0;
  static const Orientation_Slope_Symmetric = 1018.0;
  static const Orientation_Corner = 1067.0;
  static const Orientation_Slope_Inner = 1067.0;
  static const Orientation_Slope_Outer = 1067.0;
  static const Orientation_Empty = 1018.0;

  static double mapNodeType(int type) => {
    NodeType.Brick_2: Brick_Solid,
    NodeType.Grass: Grass,
    NodeType.Torch: Torch,
    NodeType.Grass_Long: Grass_Long,
    NodeType.Grass_Flowers: Grass_Flowers,
    NodeType.Brick_Top: 0.0,
    NodeType.Stone: Stone,
    NodeType.Plain: Plain_Solid,
    NodeType.Soil: Soil,
    NodeType.Bau_Haus: Bau_Haus_Solid,
    NodeType.Bed_Bottom: AtlasNode.X_Bed_Bottom,
    NodeType.Bed_Top: AtlasNode.X_Bed_Top,
    NodeType.Cottage_Roof: -1.0,
    NodeType.Tree_Bottom: Tree_Bottom,
    NodeType.Wooden_Plank: AtlasNode.Wooden_Plank_Solid_X,
    NodeType.Spawn: AtlasNode.Spawn_X,
    NodeType.Empty: 0.0,
    NodeType.Water: Water,
    NodeType.Spawn_Weapon: Spawn_Weapon,
    NodeType.Spawn_Player: Spawn_Player,
    NodeType.Wood_2: Wood,
    NodeType.Bau_Haus_2: Bau_Haus,
    NodeType.Chimney: Chimney,
    NodeType.Table: Table,
    NodeType.Fireplace: Fireplace,
    NodeType.Sunflower: Sunflower,
    NodeType.Tree_Top: Tree_Top,
    NodeType.Oven: Oven,
    NodeType.Window: Window,
    NodeType.Boulder: Boulder,
  }[type] ?? 7055;

  static double mapOrientation(int orientation) {
    if (NodeOrientation.isSolid(orientation)){
      return Orientation_Solid;
    }
    if (NodeOrientation.isCorner(orientation)){
      return Orientation_Corner;
    }
    if (NodeOrientation.isSlopeCornerOuter(orientation)){
      return Orientation_Slope_Outer;
    }
    if (NodeOrientation.isSlopeCornerInner(orientation)){
      return Orientation_Slope_Inner;
    }
    if (NodeOrientation.isHalf(orientation)){
      return Orientation_Half;
    }
    if (NodeOrientation.isSlopeSymmetric(orientation)){
      return Orientation_Slope_Symmetric;
    }
    if (orientation == NodeOrientation.None){
      return Orientation_Empty;
    }
    throw Exception('AtlasNodeX.mapOrientation(${NodeOrientation.getName(orientation)}');
  }
}

class AtlasNodeY {
  static const Bau_Haus_Solid = 512.0;
  static const Bau_Haus_Half_South = Bau_Haus_Solid + GameConstants.Sprite_Height_Padded;
  static const Bau_Haus_Half_West = Bau_Haus_Half_South + GameConstants.Sprite_Height_Padded;
  static const Bau_Haus_Corner_Top = Bau_Haus_Half_West + GameConstants.Sprite_Height_Padded;
  static const Bau_Haus_Corner_Right = Bau_Haus_Corner_Top + GameConstants.Sprite_Height_Padded;
  static const Bau_Haus_Corner_Bottom = Bau_Haus_Corner_Right + GameConstants.Sprite_Height_Padded;
  static const Bau_Haus_Corner_Left = Bau_Haus_Corner_Bottom + GameConstants.Sprite_Height_Padded;
  static const Bau_Haus_Slope_Symmetric_North = 512.0;
  static const Bau_Haus_Slope_Symmetric_East = Bau_Haus_Slope_Symmetric_North + GameConstants.Sprite_Height_Padded;
  static const Bau_Haus_Slope_Symmetric_South = Bau_Haus_Slope_Symmetric_East + GameConstants.Sprite_Height_Padded;
  static const Bau_Haus_Slope_Symmetric_West = Bau_Haus_Slope_Symmetric_South + GameConstants.Sprite_Height_Padded;
  static const Bau_Haus_Slope_Inner_North_East = Bau_Haus_Slope_Symmetric_West + GameConstants.Sprite_Height_Padded;
  static const Bau_Haus_Slope_Inner_South_East = Bau_Haus_Slope_Inner_North_East + GameConstants.Sprite_Height_Padded;
  static const Bau_Haus_Slope_Inner_South_West = Bau_Haus_Slope_Inner_South_East + GameConstants.Sprite_Height_Padded;
  static const Bau_Haus_Slope_Inner_North_West = Bau_Haus_Slope_Inner_South_West + GameConstants.Sprite_Height_Padded;
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
  static const Sunflower = 512.0;
  static const Tree_Top = 512.0;
  static const Tree_Bottom = 512.0;
  static const Water = 512.0;
  static const Stone = 0.0;
  static const Plain_Solid = 0.0;
  static const Torch = 512.0;
  static const Water_Flowing = 0.0;
  static const Window = 876.0;
  static const Spawn = 1021.0;
  static const Oven = 804.0;
  static const Boulder = 657.0;
  static const Wireframe_Blue = 738.0;
  static const Wireframe_Red = 738.0;
  static const Orientation_Solid = 512.0;
  static const Orientation_Half_North = 586.0;
  static const Orientation_Half_East = Orientation_Half_North + AtlasNode.Sprite_Height_Padded;
  static const Orientation_Half_South = Orientation_Half_East + AtlasNode.Sprite_Height_Padded;
  static const Orientation_Half_West = Orientation_Half_South + AtlasNode.Sprite_Height_Padded;
  static const Orientation_Slope_Symmetric_North = 878.0;
  static const Orientation_Slope_Symmetric_East = 951.0;
  static const Orientation_Slope_Symmetric_South = 1024.0;
  static const Orientation_Slope_Symmetric_West = Orientation_Slope_Symmetric_South + AtlasNode.Sprite_Height;
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

  static double mapNodeType(int type) => {
    NodeType.Water: Water,
    NodeType.Torch: Torch,
    NodeType.Water_Flowing: Water_Flowing,
    NodeType.Window: Window,
    NodeType.Spawn: Spawn,
    NodeType.Spawn_Weapon: Spawn_Weapon,
    NodeType.Spawn_Player: Spawn_Player,
    NodeType.Soil: Soil,
    NodeType.Wood_2: Wood,
    NodeType.Wooden_Plank: Wooden_Plank,
    NodeType.Bau_Haus_2: Bau_Haus,
    NodeType.Chimney: Chimney,
    NodeType.Table: Table,
    NodeType.Fireplace: Fireplace,
    NodeType.Sunflower: Sunflower,
    NodeType.Tree_Top: Tree_Top,
    NodeType.Tree_Bottom: Tree_Bottom,
    NodeType.Stone: Stone,
    NodeType.Plain: Plain_Solid,
    NodeType.Oven: Oven,
    NodeType.Boulder: Boulder,
  }[type] ?? 0;

  static double mapOrientation(int orientation) {
    if (orientation == NodeOrientation.Solid)
      return Orientation_Solid;
    if (orientation == NodeOrientation.Slope_North)
      return Orientation_Slope_Symmetric_North;
    if (orientation == NodeOrientation.Slope_East)
      return Orientation_Slope_Symmetric_East;
    if (orientation == NodeOrientation.Slope_South)
      return Orientation_Slope_Symmetric_South;
    if (orientation == NodeOrientation.Slope_West)
      return Orientation_Slope_Symmetric_West;
    if (orientation == NodeOrientation.Half_North)
      return Orientation_Half_North;
    if (orientation == NodeOrientation.Half_East)
      return Orientation_Half_East;
    if (orientation == NodeOrientation.Half_South)
      return Orientation_Half_South;
    if (orientation == NodeOrientation.Half_West)
      return Orientation_Half_West;
    if (orientation == NodeOrientation.Corner_Top)
      return Orientation_Corner_Top;
    if (orientation == NodeOrientation.Corner_Right)
      return Orientation_Corner_Right;
    if (orientation == NodeOrientation.Corner_Bottom)
      return Orientation_Corner_Bottom;
    if (orientation == NodeOrientation.Corner_Left)
      return Orientation_Corner_Left;
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
    if (orientation == NodeOrientation.None)
      return Orientation_Empty;
    throw Exception('AtlasNodeY.mapOrientation(${NodeOrientation.getName(orientation)}');
  }
}

class AtlasNodeAnchorY{
   static const Torch = 0.33;
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
  // static const Node_Bau_Haus_Solid_Y = 512.0;
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
  static const Campfire_X = 667.0;
  static const Node_Campfire_Y = 512.0;
  static const Chimney_X = 618.0;
  static const Node_Chimney_Y = 730.0;
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
  static const Y_Torch_Windy = 512.0;
  static const Width_Torch = 25.0;
  static const Height_Torch = 70.0;
}