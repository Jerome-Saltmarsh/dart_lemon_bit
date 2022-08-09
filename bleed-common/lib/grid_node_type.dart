class GridNodeType {
  static const Empty = 0;
  static const Boundary = 1;
  static const Grass = 2;
  static const Bricks = 3;
  static const Stairs_North = 4;
  static const Stairs_East = 5;
  static const Stairs_South = 6;
  static const Stairs_West = 7;
  static const Water = 8;
  static const Torch = 9;
  static const Tree_Bottom = 10;
  static const Tree_Top = 11;
  static const Grass_Long = 13;
  static const Rain_Falling = 18;
  static const Rain_Landing = 19;
  static const Fireplace = 20;
  static const Wood = 21;
  static const Grass_Slope_North = 22;
  static const Grass_Slope_East = 23;
  static const Grass_Slope_South = 24;
  static const Grass_Slope_West = 25;
  static const Water_Flowing = 26;
  static const Brick_Top = 27;
  static const Wood_Half_Row_1 = 28;
  static const Wood_Half_Column_1 = 29;
  static const Wood_Corner_Bottom = 30;
  static const Wood_Half_Row_2 = 31;
  static const Wood_Half_Column_2 = 32;
  static const Roof_Tile_North = 33;
  static const Wood_Corner_Left = 34;
  static const Wood_Corner_Top = 35;
  static const Wood_Corner_Right = 36;
  static const Roof_Tile_South = 37;
  static const Soil = 38;
  static const Roof_Hay_North = 39;
  static const Roof_Hay_South = 40;
  static const Stone = 41;
  static const Grass_Slope_Top = 42;
  static const Grass_Slope_Right = 43;
  static const Grass_Slope_Bottom = 44;
  static const Grass_Slope_Left = 45;
  static const Grass_Edge_Top = 46;
  static const Grass_Edge_Right = 47;
  static const Grass_Edge_Bottom = 48;
  static const Grass_Edge_Left = 49;
  static const Bau_Haus = 50;
  static const Bau_Haus_Roof_North = 51;
  static const Bau_Haus_Roof_South = 52;
  static const Bau_Haus_Window = 53;
  static const Bau_Haus_Plain = 54;


  static isSolid(int type){
    if (type == GridNodeType.Bricks) return true;
    if (type == GridNodeType.Grass) return true;
    if (type == GridNodeType.Wood) return true;
    if (type == GridNodeType.Soil) return true;
    if (type == GridNodeType.Boundary) return true;
    if (type == GridNodeType.Stone) return true;
    return false;
  }
  
  static isGrassSlope(int type){
    if (type == GridNodeType.Grass_Slope_North) return true;
    if (type == GridNodeType.Grass_Slope_East) return true;
    if (type == GridNodeType.Grass_Slope_South) return true;
    if (type == GridNodeType.Grass_Slope_West) return true;
    if (type == GridNodeType.Grass_Slope_Top) return true;
    if (type == GridNodeType.Grass_Slope_Right) return true;
    if (type == GridNodeType.Grass_Slope_Bottom) return true;
    if (type == GridNodeType.Grass_Slope_Left) return true;
    return false;
  }
  
  static isStone(int type){
    return const [
        Bricks,
        Stairs_North,
        Stairs_East,
        Stairs_South,
        Stairs_West,
        Brick_Top,
        Stone,
    ].contains(type);
  }

  static bool isSlopeNorth(int type){
    return type == Stairs_North || type == Grass_Slope_North;
  }

  static bool isSlopeEast(int type){
    return type == Stairs_East || type == Grass_Slope_East;
  }

  static bool isSlopeSouth(int type){
    return type == Stairs_South || type == Grass_Slope_South;
  }

  static bool isSlopeWest(int type){
    return type == Stairs_West || type == Grass_Slope_West;
  }

  static bool isWater(int type) {
    return type == Water || type == Water_Flowing;
  }

  static const values = [
    Empty,
    Boundary,
    Grass,
    Bricks,
    Brick_Top,
    Stairs_North,
    Stairs_East,
    Stairs_South,
    Stairs_West,
    Water,
    Water_Flowing,
    Torch,
    Tree_Bottom,
    Tree_Top,
    Grass_Long,
    // Enemy_Spawn,
    Rain_Falling,
    Rain_Landing,
    Fireplace,
    Wood,
  ];
  
  static String getName(int type){
     return const {
       Empty: 'Empty',
       Boundary: 'Boundary',
       Grass: 'Grass',
       Bricks: 'Bricks',
       Brick_Top: 'Brick Top',
       Stairs_North: 'Stairs North',
       Stairs_East: 'Stairs East',
       Stairs_South: 'Stairs South',
       Stairs_West: 'Stairs West',
       Water: 'Water',
       Water_Flowing: 'Flowing Water',
       Torch: 'Torch',
       Tree_Bottom: 'Tree Bottom',
       Tree_Top: 'Tree Top',
       Grass_Long: 'Grass Long',
       // Enemy_Spawn: 'Enemy Spawn',
       Rain_Falling: 'Rain Falling',
       Rain_Landing: 'Rain Landing',
       Fireplace: 'Fireplace',
       Wood: "Wood",
       Wood_Half_Row_1: "Wood Half Row 1",
       Wood_Half_Row_2: "Wood Half Row 2",
       Wood_Half_Column_1: "Wood Half Column 1",
       Wood_Half_Column_2: "Wood Half Column 2",
       Wood_Corner_Bottom: "Wood Corner Bottom",
       Wood_Corner_Left: "Wood Corner Left",
       Wood_Corner_Top: "Wood Corner Top",
       Wood_Corner_Right: "Wood Corner Right",
       Grass_Slope_North: "Grass Slope North",
       Grass_Slope_East: "Grass Slope East",
       Grass_Slope_South: "Grass Slope South",
       Grass_Slope_West: "Grass Slope West",
       Roof_Tile_North: "Roof Tile North",
       Roof_Tile_South: "Roof Tile South",
       Soil: "Soil",
       Roof_Hay_North: "Roof Hay North",
       Roof_Hay_South: "Roof Hay South",
       Stone: "Stone",
       Grass_Slope_Top: "Grass Slope Top",
       Grass_Slope_Right: "Grass Slope Right",
       Grass_Slope_Bottom: "Grass Slope Bottom",
       Grass_Slope_Left: "Grass Slope Left",
       Grass_Edge_Top: "Grass Edge Top",
       Grass_Edge_Right: "Grass Edge Right",
       Grass_Edge_Bottom: "Grass Edge Bottom",
       Grass_Edge_Left: "Grass Edge Left",
       Bau_Haus: "Bau Haus",
       Bau_Haus_Roof_North: "Bau Haus Roof North",
       Bau_Haus_Roof_South: "Bau Haus Roof South",
       Bau_Haus_Window: "Bau Haus Window",
       Bau_Haus_Plain: "Bau Hau Plain",
     }[type] ?? "unknown($type)";
  }
  
  static bool isFire(int value) =>
     value == Fireplace           ||
     value == Torch               ;

  static bool isRain(int value) =>
      value == Rain_Falling       ||
      value == Rain_Landing       ;

  static bool isRainOrEmpty(int value) =>
      value == Rain_Falling       ||
      value == Rain_Landing       ||
      value == Empty;

  static bool isTree(int value) =>
     value == Tree_Top            ||
     value == Tree_Bottom         ;

  static bool isStairs(int value) =>
      value == Stairs_North       ||
      value == Stairs_East        ||
      value == Stairs_West        ||
      value == Stairs_South       ||
      value == Grass_Slope_North  ||
      value == Grass_Slope_East   ||
      value == Grass_Slope_South  ||
      value == Grass_Slope_West   ;
}