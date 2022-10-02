
import 'node_orientation.dart';


class NodeType {
  static const Empty = 0;
  static const Boundary = 1;
  static const Water = 8;
  static const Torch = 9;
  static const Tree_Bottom = 10;
  static const Tree_Top = 11;
  static const Grass_Long = 13;
  static const Rain_Falling = 18;
  static const Rain_Landing = 19;
  static const Fireplace = 20;
  static const Water_Flowing = 26;
  static const Brick_Top = 27;
  static const Roof_Tile_North = 33;
  static const Roof_Tile_South = 37;
  static const Soil = 38;
  static const Roof_Hay_North = 39;
  static const Roof_Hay_South = 40;
  static const Stone = 41;
  static const Bau_Haus = 50;
  static const Bau_Haus_Window = 53;
  static const Bau_Haus_Plain = 54;
  static const Chimney = 55;
  static const Bed_Bottom = 56;
  static const Bed_Top = 57;
  static const Table = 58;
  static const Sunflower = 59;
  static const Oven = 60;
  static const Grass_Flowers = 61;
  static const Brick_2 = 62;
  static const Wood_2 = 63;
  static const Cottage_Roof = 64;
  static const Grass = 65;
  static const Plain = 66;
  static const Window = 67;
  static const Wooden_Plank = 68;
  static const Bau_Haus_2 = 69;
  static const Boulder = 70;
  static const Spawn = 71;
  static const Respawning = 72;

  static bool isStrikable(int type) =>
    type == Grass ||
    type == Brick_2 ||
    type == Wood_2;

  static bool isMaterialWood(int value) =>
    value == Torch ||
    value == Tree_Bottom ||
    value == Table ||
    value == Wood_2 ||
    value == Wooden_Plank;

  static bool isMaterialGrass(int value) =>
    value == Grass_Long ||
    value == Grass_Flowers ||
    value == Grass;

  static bool isMaterialStone(int value) =>
    value == Brick_Top ||
    value == Stone ||
    value == Oven ||
    value == Brick_2 ||
    value == Chimney;

  static bool isOriented(int value) =>
    value == Brick_2 ||
    value == Wood_2 ||
    value == Grass ||
    value == Plain ||
    value == Window ||
    value == Wooden_Plank ||
    value == Bau_Haus_2 ||
    value == Boulder ||
    value == Cottage_Roof;

  static bool isSolid(int type) =>
    type == Brick_2 ||
    type == Stone ||
    type == Wood_2 ||
    type == Grass ||
    type == Plain ||
    type == Wooden_Plank ||
    type == Bau_Haus_2 ||
    type == Boulder;

  static bool isDestroyable(int type) =>
    type == Boulder ||
    type == Sunflower ||
    type == Grass_Long;

  static bool isSlopeSymmetric(int type) =>
    type == Cottage_Roof ||
    type == Wood_2 ||
    type == Grass ||
    type == Brick_2 ||
    type == Bau_Haus_2;

  static bool isSlopeCornerInner(int type) =>
    type == Cottage_Roof ||
    type == Grass ||
    type == Bau_Haus_2;

  static bool isSlopeCornerOuter(int type) =>
    type == Grass;

  static bool isHalf(int type) =>
    type == Wood_2 ||
    type == Plain ||
    type == Window ||
    type == Wooden_Plank ||
    type == Brick_2 ||
    type == Bau_Haus_2;

  static bool isCorner(int type) =>
    type == Wood_2 ||
    type == Plain ||
    type == Brick_2 ||
    type == Bau_Haus_2 ||
    type == Wooden_Plank;

  static bool isRainable(int type) =>
    type == Water ||
    type == Brick_2 ||
    type == Grass;

  static bool isRain(int value) =>
     value == Rain_Falling       ||
     value == Rain_Landing       ;
  
  static bool blocksPerception(int value){
    return value == isSolid(value);
  }
  
  static bool emitsLight(int value) =>
    value == Torch || 
    value == Fireplace;

  static int getDefaultOrientation(int value){
     if (value == Empty)
       return NodeOrientation.None;
     if (isSolid(value))
       return NodeOrientation.Solid;
     if (isSlopeSymmetric(value))
       return NodeOrientation.Slope_North;
     if (isSlopeCornerInner(value))
       return NodeOrientation.Slope_Inner_North_East;
     if (isSlopeCornerOuter(value))
       return NodeOrientation.Slope_Outer_North_East;
     if (isHalf(value))
       return NodeOrientation.Half_North;
     if (isCorner(value))
       return NodeOrientation.Corner_Top;

     return NodeOrientation.None;
  }

  static bool supportsOrientation(int type, int orientation){

    if (NodeOrientation.isSolid(orientation))
      return isSolid(type);

    if (NodeOrientation.isHalf(orientation))
      return isHalf(type);

    if (NodeOrientation.isCorner(orientation))
      return isCorner(type);

    if (NodeOrientation.isSlopeCornerInner(orientation))
      return isSlopeCornerInner(type);

    if (NodeOrientation.isSlopeCornerOuter(orientation))
      return isSlopeCornerOuter(type);

    if (NodeOrientation.isSlopeSymmetric(orientation))
      return isSlopeSymmetric(type);

    return false;
  }

  static String getName(int type) => const {
    Empty: 'Empty',
    Boundary: 'Boundary',
    Brick_Top: 'Brick Top',
    Water: 'Water',
    Water_Flowing: 'Flowing Water',
    Torch: 'Torch',
    Tree_Bottom: 'Tree Bottom',
    Tree_Top: 'Tree Top',
    Grass_Long: 'Grass Long',
    Rain_Falling: 'Rain Falling',
    Rain_Landing: 'Rain Landing',
    Fireplace: 'Fireplace',
    Soil: "Soil",
    Roof_Hay_North: "Roof Hay North",
    Roof_Hay_South: "Roof Hay South",
    Stone: "Stone",
    Bau_Haus: "Bau Haus",
    Bau_Haus_2: "Bau Haus",
    Bau_Haus_Window: "Bau Haus Window",
    Bau_Haus_Plain: "Bau Hau Plain",
    Chimney: "Chimney",
    Bed_Bottom: "Bed Bottom",
    Bed_Top: "Bed Top",
    Table: "Table",
    Sunflower: "Sunflower",
    Oven: "Oven",
    Grass_Flowers: "Grass Flowers",
    Brick_2: "Brick",
    Wood_2: "Wood",
    Cottage_Roof: "Cottage Roof",
    Grass: "Grass",
    Plain: "Plain",
    Window: "Window",
    Wooden_Plank: "Wooden Plank",
    Boulder: "Boulder",
    Spawn: "Spawn",
  }[type] ?? "unknown($type)";
}