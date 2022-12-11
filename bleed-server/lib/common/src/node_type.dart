
import 'node_orientation.dart';

/// TODO Add cobblestone
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
  static const Soil = 38;
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
  static const Spawn_Weapon = 73;
  static const Spawn_Player = 74;
  static const Respawning = 72;

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

  static bool supportsOrientationSolid(int type) =>
    type == Brick_2 ||
    type == Soil ||
    type == Stone ||
    type == Wood_2 ||
    type == Grass ||
    type == Plain ||
    type == Wooden_Plank ||
    type == Bau_Haus_2 ||
    type == Table ||
    type == Oven ||
    type == Bed_Top ||
    type == Bed_Bottom ||
    type == Chimney ||
    type == Boulder;

  static bool supportsOrientationEmpty(int type) =>
    type == Empty ||
    type == Water ||
    type == Spawn ||
    type == Spawn_Weapon ||
    type == Spawn_Player ||
    type == Respawning ||
    type == Rain_Landing ||
    type == Tree_Top ||
    type == Grass_Long ||
    type == Sunflower ||
    type == Rain_Falling ;

  static bool supportsOrientationRadial(int type) =>
    type == Tree_Bottom ||
    type == Torch ||
    type == Fireplace ;

  static bool supportsOrientationSlopeSymmetric(int type) =>
    type == Cottage_Roof ||
    type == Wood_2 ||
    type == Grass ||
    type == Brick_2 ||
    type == Bau_Haus_2;

  static bool supportsOrientationSlopeCornerInner(int type) =>
    type == Cottage_Roof ||
    type == Grass ||
    type == Bau_Haus_2;

  static bool supportsOrientationSlopeCornerOuter(int type) =>
    type == Grass;

  static bool supportsOrientationHalf(int type) =>
    type == Wood_2 ||
    type == Plain ||
    type == Window ||
    type == Wooden_Plank ||
    type == Brick_2 ||
    type == Bau_Haus_2;

  static bool supportsOrientationCorner(int type) =>
    type == Wood_2 ||
    type == Plain ||
    type == Brick_2 ||
    type == Bau_Haus_2 ||
    type == Wooden_Plank;

  static bool isDestroyable(int type) =>
      type == Boulder         ||
      type == Sunflower       ||
      type == Grass_Long       ;

  static bool isTransient(int value) =>
      value == Empty          ||
      value == Grass_Long     ||
      value == Rain_Falling   ||
      value == Tree_Bottom    ||
      value == Tree_Top       ||
      value == Rain_Landing    ;

  static bool isRainOrEmpty(value) =>
      isRain(value)           ||
      value == Empty           ;
  
  static bool isRain(int value) =>
     value == Rain_Falling ||
     value == Rain_Landing ;
  
  static bool blocksPerception(int value) =>
     supportsOrientationSolid(value);

  static bool emitsLight(int value) =>
    value == Torch || 
    value == Fireplace;

  static int getDefaultOrientation(int value){
     if (supportsOrientationEmpty(value)) {
       return NodeOrientation.None;
     }
     if (supportsOrientationSolid(value)) {
       return NodeOrientation.Solid;
     }
     if (supportsOrientationSlopeSymmetric(value)) {
       return NodeOrientation.Slope_North;
     }
     if (supportsOrientationSlopeCornerInner(value)) {
       return NodeOrientation.Slope_Inner_North_East;
     }
     if (supportsOrientationSlopeCornerOuter(value)) {
       return NodeOrientation.Slope_Outer_North_East;
     }
     if (supportsOrientationHalf(value)) {
       return NodeOrientation.Half_North;
     }
     if (supportsOrientationCorner(value)) {
       return NodeOrientation.Corner_Top;
     }
     if (supportsOrientationRadial(value)) {
       return NodeOrientation.Radial;
     }
     throw Exception('node_type.getDefaultOrientation(${getName(value)}');
  }

  static bool supportsOrientation(int type, int orientation) {

    if (orientation == NodeOrientation.None) {
      return supportsOrientationEmpty(type);
    }

    if (orientation == NodeOrientation.Solid) {
      return supportsOrientationSolid(type);
    }

    if (NodeOrientation.isHalf(orientation)) {
      return supportsOrientationHalf(type);
    }

    if (NodeOrientation.isCorner(orientation)) {
      return supportsOrientationCorner(type);
    }

    if (NodeOrientation.isSlopeCornerInner(orientation)) {
      return supportsOrientationSlopeCornerInner(type);
    }

    if (NodeOrientation.isSlopeCornerOuter(orientation)) {
      return supportsOrientationSlopeCornerOuter(type);
    }

    if (NodeOrientation.isSlopeSymmetric(orientation)) {
      return supportsOrientationSlopeSymmetric(type);
    }

    if (orientation == NodeOrientation.Radial) {
      return supportsOrientationRadial(type);
    }

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
    Soil: 'Soil',
    Stone: 'Stone',
    Bau_Haus: 'Bau Haus',
    Bau_Haus_2: 'Bau Haus',
    Bau_Haus_Window: 'Bau Haus Window',
    Bau_Haus_Plain: 'Bau Hau Plain',
    Chimney: 'Chimney',
    Bed_Bottom: 'Bed Bottom',
    Bed_Top: 'Bed Top',
    Table: 'Table',
    Sunflower: 'Sunflower',
    Oven: 'Oven',
    Grass_Flowers: 'Grass Flowers',
    Brick_2: 'Brick',
    Wood_2: 'Wood',
    Cottage_Roof: 'Cottage Roof',
    Grass: 'Grass',
    Plain: 'Plain',
    Window: 'Window',
    Wooden_Plank: 'Wooden Plank',
    Boulder: 'Boulder',
    Spawn: 'Spawn',
    Respawning: 'Respawning',
    Spawn_Weapon: 'Spawn Weapon',
    Spawn_Player: 'Spawn Player',
  }[type] ?? 'unknown($type)';
}