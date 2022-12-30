import 'library.dart';

class AtlasItems {
  static const size = 32.0;

  static double getSrcX(int itemType) => const <int, double> {
      ItemType.GameObjects_Car: 0,
      ItemType.GameObjects_Crystal: 75,
      ItemType.GameObjects_Barrel: 11,
      ItemType.GameObjects_Cup: 0,
      ItemType.GameObjects_Tavern_Sign: 40,
      ItemType.GameObjects_Grenade: 0,
      ItemType.Trinket_Ring_of_Health: 256,
      ItemType.Trinket_Ring_of_Damage: 288,
      ItemType.Empty: 224,
      ItemType.Head_Steel_Helm: 128,
      ItemType.Head_Rogues_Hood: 160,
      ItemType.Head_Wizards_Hat: 192,
      ItemType.Head_Swat: 288,
      ItemType.Body_Shirt_Blue: 64,
      ItemType.Body_Shirt_Cyan: 96,
      ItemType.Body_Tunic_Padded: 128,
      ItemType.Body_Swat: 256,
      ItemType.Legs_Blue: 224,
      ItemType.Legs_Brown: 192,
      ItemType.Legs_Swat: 320,
      ItemType.Legs_Red: 352,
      ItemType.Legs_Green: 384,
      ItemType.Weapon_Melee_Sword: 0,
      ItemType.Weapon_Melee_Knife: 128,
      ItemType.Weapon_Ranged_Bow: 64,
      ItemType.Weapon_Thrown_Grenade: 96,
      ItemType.Weapon_Ranged_Shotgun: 0,
      ItemType.Weapon_Handgun_Flint_Lock_Old: 320,
      ItemType.Weapon_Handgun_Flint_Lock: 288,
      ItemType.Weapon_Handgun_Flint_Lock_Superior: 288,
      ItemType.Weapon_Handgun_Glock: 32,
      ItemType.Weapon_Handgun_Desert_Eagle: 32,
      ItemType.Weapon_Handgun_Revolver: 224,
      ItemType.Weapon_Rifle_Jager: 64,
      ItemType.Weapon_Rifle_Musket: 64,
      ItemType.Weapon_Rifle_Arquebus: 64,
      ItemType.Weapon_Rifle_Blunderbuss: 96,
      ItemType.Weapon_Rifle_M4: 64,
      ItemType.Weapon_Rifle_AK_47: 64,
      ItemType.Weapon_Rifle_Steyr: 64,
      ItemType.Weapon_Rifle_Sniper: 64,
      ItemType.Weapon_Smg_Mp5: 160,
      ItemType.Weapon_Flamethrower: 64,
      ItemType.Weapon_Special_Bazooka: 64,
      ItemType.Weapon_Special_Minigun: 1,
      ItemType.Resource_Wood: 32,
      ItemType.Resource_Stone: 64,
      ItemType.Resource_Crystal: 96,
      ItemType.Resource_Gold: 128,
      ItemType.Resource_Gun_Powder: 160,
      ItemType.Resource_Round_9mm: 416,
      ItemType.Resource_Round_50cal: 416,
      ItemType.Resource_Round_Rifle: 416,
      ItemType.Resource_Round_Shotgun: 416,
      ItemType.Resource_Arrow: 192,
      ItemType.Resource_Rocket: 192,
      ItemType.Consumables_Meat: 224,
      ItemType.Consumables_Apple: 256,
      ItemType.Base_Health: 288,
      ItemType.Base_Damage: 352,
  }[itemType] ?? 0;

  static double getSrcY(int itemType) => const <int, double> {
    ItemType.GameObjects_Car: 144,
    ItemType.GameObjects_Crystal: 0,
    ItemType.GameObjects_Barrel: 0,
    ItemType.GameObjects_Cup: 0,
    ItemType.GameObjects_Tavern_Sign: 0,
    ItemType.GameObjects_Grenade: 48,
    ItemType.Trinket_Ring_of_Health: 32,
    ItemType.Trinket_Ring_of_Damage: 32,
    ItemType.Weapon_Ranged_Shotgun: 32,
    ItemType.Head_Swat: 96,
    ItemType.Body_Shirt_Blue: 32,
    ItemType.Body_Shirt_Cyan: 32,
    ItemType.Body_Tunic_Padded: 32,
    ItemType.Body_Swat: 96,
    ItemType.Legs_Blue: 32,
    ItemType.Legs_Brown: 32,
    ItemType.Legs_Swat: 96,
    ItemType.Legs_Red: 96,
    ItemType.Legs_Green: 96,
    ItemType.Resource_Wood: 64,
    ItemType.Resource_Stone: 64,
    ItemType.Resource_Crystal: 64,
    ItemType.Resource_Gold: 64,
    ItemType.Resource_Gun_Powder: 64,
    ItemType.Resource_Round_9mm: 0,
    ItemType.Resource_Round_Shotgun: 32,
    ItemType.Resource_Round_Rifle: 64,
    ItemType.Resource_Round_50cal: 96,
    ItemType.Resource_Scrap_Metal: 96,
    ItemType.Resource_Rocket: 96,
    ItemType.Resource_Arrow: 64,
    ItemType.Consumables_Meat: 64,
    ItemType.Consumables_Apple: 64,
    ItemType.Weapon_Thrown_Grenade: 96,
    ItemType.Weapon_Melee_Knife: 96,
    ItemType.Weapon_Handgun_Glock: 96,
    ItemType.Weapon_Handgun_Revolver: 96,
    ItemType.Weapon_Handgun_Desert_Eagle: 32,
    ItemType.Weapon_Rifle_Jager: 96,
    ItemType.Weapon_Rifle_Musket: 96,
    ItemType.Weapon_Rifle_Arquebus: 96,
    ItemType.Weapon_Rifle_Blunderbuss: 128,
    ItemType.Weapon_Rifle_AK_47:  128,
    ItemType.Weapon_Rifle_M4: 160,
    ItemType.Weapon_Rifle_Steyr: 192,
    ItemType.Weapon_Rifle_Sniper: 224,
    ItemType.Weapon_Smg_Mp5: 96,
    ItemType.Weapon_Flamethrower: 240,
    ItemType.Weapon_Special_Bazooka: 272,
    ItemType.Weapon_Special_Minigun: 130,
    ItemType.Base_Health: 64,
    ItemType.Base_Damage: 64,
  }[itemType] ?? 0;


  static double getSrcWidth(int itemType) => const <int, double> {
    ItemType.GameObjects_Car: 143,
    ItemType.GameObjects_Crystal: 22,
    ItemType.GameObjects_Barrel: 28,
    ItemType.GameObjects_Cup: 6,
    ItemType.GameObjects_Tavern_Sign: 19,
    ItemType.GameObjects_Grenade: 8,
    ItemType.Weapon_Rifle_Sniper: 48,
    ItemType.Weapon_Flamethrower: 64,
    ItemType.Weapon_Special_Bazooka: 48,
    ItemType.Weapon_Special_Minigun: 35,
  }[itemType] ?? size;

  static double getSrcHeight(int itemType) => const <int, double> {
    ItemType.GameObjects_Car: 105,
    ItemType.GameObjects_Crystal: 45,
    ItemType.GameObjects_Barrel: 40,
    ItemType.GameObjects_Cup: 11,
    ItemType.GameObjects_Tavern_Sign: 39,
    ItemType.GameObjects_Grenade: 8,
    ItemType.Weapon_Rifle_Sniper: 16,
    ItemType.Weapon_Special_Bazooka: 16,
    ItemType.Weapon_Special_Minigun: 12,
  }[itemType] ?? size;
}


class AtlasIcons {

  static const Size = 32.0;

  static double getSrcX(int itemType) => const <int, double> {
    IconType.Zoom: Size * 1,
    IconType.Home: Size * 2,
    IconType.Fullscreen: Size * 3,
    IconType.Slot: Size * 1,
    IconType.Rain_None: 128,
    IconType.Rain_Light: 128,
    IconType.Rain_Heavy: 128,
    IconType.Lightning_Off: 128,
    IconType.Lightning_Nearby: 128,
    IconType.Lightning_On: 128,
    IconType.Wind_Calm: 128,
    IconType.Wind_Gentle: 128,
    IconType.Wind_Strong: 128,
    IconType.Inventory: 64,
    IconType.Sound_Enabled: 192,
    IconType.Sound_Disabled: 224,
    IconType.Plus: 32,
    IconType.Minus: 64,
  }[itemType] ?? 0;

  static double getSrcY(int itemType) => const  <int, double> {
    IconType.Arrows_Up: Size * 0,
    IconType.Arrows_Down: Size * 1,
    IconType.Arrows_North: Size * 2,
    IconType.Arrows_East: Size * 3,
    IconType.Arrows_South: Size * 4,
    IconType.Arrows_West: Size * 5,
    IconType.Home: 0,
    IconType.Fullscreen: 0,
    IconType.Zoom: 0,
    IconType.Slot: Size * 1,
    IconType.Rain_None: 64 * 0,
    IconType.Rain_Light: 64 * 1,
    IconType.Rain_Heavy: 64 * 2,
    IconType.Lightning_Off: 64 * 0,
    IconType.Lightning_Nearby: 64 * 3,
    IconType.Lightning_On: 64 * 4,
    IconType.Wind_Calm: 64 * 0,
    IconType.Wind_Gentle: 64 * 5,
    IconType.Wind_Strong: 64 * 6,
    IconType.Inventory: 32,
    IconType.Plus: 96,
    IconType.Minus: 96,
  }[itemType] ?? 0;
}

class AtlasNodeX {
  static const Bau_Haus_Solid = 520.0;
  static const Bau_Haus_Half = Bau_Haus_Solid;
  static const Bau_Haus_Corner = Bau_Haus_Half;
  static const Bau_Haus_Slope = Bau_Haus_Solid + GameConstants.Sprite_Width_Padded;
  static const Brick_Solid = GameConstants.Sprite_Width_Padded_2;
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
  static const Spawn_Zombie = 0.0;
  static const Wooden_Plank = 716.0;
  static const Chimney = 618.0;
  static const Table = 667.0;
  static const Tree_Top = 1668.0;
  static const Tree_Bottom = 1606.0;
  static const Water = 1606.0;
  static const Grass = 0.0;
  static const Grass_Long = 1218.0;
  static const Grass_Flowers = 49.0;
  static const Torch = 1655.0;
  static const Stone = 1508.0;
  static const Plain_Solid = 1557.0;
  static const Oven = 618.0;
  static const Window = 618.0;
  static const Boulder = 618.0;
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
    NodeType.Brick: GameConstants.Sprite_Width_Padded_2,
    NodeType.Grass: GameConstants.Sprite_Width_Padded_3,
    NodeType.Wood: GameConstants.Sprite_Width_Padded_5,
    NodeType.Bau_Haus: GameConstants.Sprite_Width_Padded_6,
    NodeType.Soil: GameConstants.Sprite_Width_Padded_7,
    NodeType.Concrete: GameConstants.Sprite_Width_Padded_8,
    NodeType.Torch: Torch,
    NodeType.Grass_Long: Grass_Long,
    NodeType.Grass_Flowers: Grass_Flowers,
    NodeType.Metal: GameConstants.Sprite_Width_Padded_4,
    NodeType.Bed_Bottom: AtlasNode.X_Bed_Bottom,
    NodeType.Bed_Top: AtlasNode.X_Bed_Top,
    NodeType.Tree_Bottom: Tree_Bottom,
    NodeType.Wooden_Plank: AtlasNode.Wooden_Plank_Solid_X,
    NodeType.Spawn: 1704.0,
    NodeType.Empty: 0.0,
    NodeType.Water: Water,
    NodeType.Spawn_Weapon: Spawn_Weapon,
    NodeType.Spawn_Player: 1655.0,
    NodeType.Chimney: Chimney,
    NodeType.Table: Table,
    NodeType.Fireplace: 1753.0,
    NodeType.Sunflower: 1753.0,
    NodeType.Tree_Top: Tree_Top,
    NodeType.Oven: Oven,
    NodeType.Window: Window,
    NodeType.Boulder: Boulder,
    NodeType.Road: 768.0,
    NodeType.Road_2: 768.0,
  }[type] ?? 7055;
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
  static const Spawn_Zombie = 665.0;
  static const Soil = 584.0;
  static const Wood = 512.0;
  static const Wooden_Plank = 512.0;
  static const Bau_Haus = 512.0;
  static const Chimney = 730.0;
  static const Table = 945.0;
  static const Sunflower = 867.0;
  static const Tree_Top = 433.0;
  static const Tree_Bottom = 433.0;
  static const Water = 512.0;
  static const Stone = 0.0;
  static const Plain_Solid = 0.0;
  static const Torch = 728.0;
  static const Water_Flowing = 0.0;
  static const Window = 876.0;
  static const Oven = 804.0;
  static const Boulder = 657.0;
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
    NodeType.Spawn: 655.0,
    NodeType.Spawn_Weapon: Spawn_Weapon,
    NodeType.Spawn_Player: 655.0,
    NodeType.Wooden_Plank: Wooden_Plank,
    NodeType.Chimney: Chimney,
    NodeType.Table: Table,
    NodeType.Fireplace: 434.0,
    NodeType.Sunflower: Sunflower,
    NodeType.Tree_Top: Tree_Top,
    NodeType.Tree_Bottom: Tree_Bottom,
    NodeType.Oven: Oven,
    NodeType.Boulder: Boulder,
    NodeType.Road: 672.0,
    NodeType.Road_2: 672.0 + GameConstants.Sprite_Height_Padded,
  }[type] ?? 0;

  static double mapOrientation(int orientation) {
    if (orientation == NodeOrientation.Solid)
      return 0;
    if (orientation == NodeOrientation.Slope_North)
      return GameConstants.Sprite_Height_Padded_07;
    if (orientation == NodeOrientation.Slope_East)
      return GameConstants.Sprite_Height_Padded_08;
    if (orientation == NodeOrientation.Slope_South)
      return GameConstants.Sprite_Height_Padded_09;
    if (orientation == NodeOrientation.Slope_West)
      return GameConstants.Sprite_Height_Padded_10;
    if (orientation == NodeOrientation.Half_North)
      return GameConstants.Sprite_Height_Padded_01;
    if (orientation == NodeOrientation.Half_East)
      return GameConstants.Sprite_Height_Padded_02;
    if (orientation == NodeOrientation.Half_South)
      return GameConstants.Sprite_Height_Padded_01;
    if (orientation == NodeOrientation.Half_West)
      return GameConstants.Sprite_Height_Padded_02;
    if (orientation == NodeOrientation.Corner_Top)
      return GameConstants.Sprite_Height_Padded_03;
    if (orientation == NodeOrientation.Corner_Right)
      return GameConstants.Sprite_Height_Padded_04;
    if (orientation == NodeOrientation.Corner_Bottom)
      return GameConstants.Sprite_Height_Padded_05;
    if (orientation == NodeOrientation.Corner_Left)
      return GameConstants.Sprite_Height_Padded_06;
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
    if (orientation == NodeOrientation.Radial)
      return GameConstants.Sprite_Height_Padded_19;
    if (NodeOrientation.isHalfVertical(orientation))
      return GameConstants.Sprite_Height_Padded_20;
    if (NodeOrientation.isColumn(orientation))
      return GameConstants.Sprite_Height_Padded_21;
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
  static const X_Torch_Windy = 1681.0;
  static const Y_Torch_Windy = 728.0;
  static const Width_Torch = 25.0;
  static const Height_Torch = 70.0;
}