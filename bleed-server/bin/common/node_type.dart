
// node_type belongs to a
// node_group
// wood
// has solid, slopes, corners rows_columns
// node_orientation
// node_orientation_groups
  // Slope_Symetric (North, East, South, West)
  // Slope_Inner
  // Slope_Outter
  // Halvable
// a node_group has possible node_orientations
class NodeType {
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
  static const Chimney = 55;
  static const Bed_Bottom = 56;
  static const Bed_Top = 57;
  static const Table = 58;
  static const Sunflower = 59;
  static const Oven = 60;
  static const Grass_Flowers = 61;
  static const Brick_Stairs = 62;
  static const Wood_2 = 63;
  static const Cottage_Roof = 64;

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
       Chimney: "Chimney",
       Bed_Bottom: "Bed Bottom",
       Bed_Top: "Bed Top",
       Table: "Table",
       Sunflower: "Sunflower",
       Oven: "Oven",
       Grass_Flowers: "Grass Flowers",
       Brick_Stairs: "Brick Stairs",
       Wood_2: "Wood 2",
       Cottage_Roof: "Cottage Roof",
     }[type] ?? "unknown($type)";
  }

  static bool isRain(int value) =>
      value == Rain_Falling       ||
      value == Rain_Landing       ;

  static bool isOriented(int value) {
     if (value == Brick_Stairs) return true;
     return false;
  }
}