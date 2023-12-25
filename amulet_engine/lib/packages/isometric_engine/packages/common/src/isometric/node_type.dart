
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
  static const Soil = 38;
  static const Concrete = 41;
  static const Bau_Haus_Window = 53;
  static const Bau_Haus_Plain = 54;
  static const Chimney = 55;
  static const Table = 58;
  static const Sunflower = 59;
  static const Oven = 60;
  static const Grass_Flowers = 61;
  static const Brick = 62;
  static const Wood = 63;
  static const Grass = 65;
  static const Window = 67;
  static const Wooden_Plank = 68;
  static const Bau_Haus = 69;
  static const Boulder = 70;
  static const Respawning = 72;
  static const Road = 75;
  static const Road_2 = 76;
  static const Metal = 77;
  static const Sandbag = 79;
  static const Shopping_Shelf = 80;
  static const Tile = 81;
  static const Dust = 82;
  static const Bookshelf = 83;
  static const Bricks_Red = 84;
  static const Bricks_Brown = 85;
  static const Scaffold = 86;
  static const Glass = 87;
  static const Torch_Blue = 88;
  static const Torch_Red = 89;
  static const Grass_Short = 90;
  static const Tree_Stump = 91;

  static bool supportsOrientationSolid(int type) => const [
        Brick,
        Bricks_Red,
        Bricks_Brown, 
        Soil,
        Road,
        Road_2,
        Concrete,
        Wood,
        Grass,
        Wooden_Plank,
        Bau_Haus,
        Table,
        Oven,
        Chimney,
        Metal,
        Sandbag,
        Shopping_Shelf,
        Bookshelf,
        Tile,
        Boulder,
        Glass,
      ].contains(type);

  static bool supportsOrientationEmpty(int type) => const [
        Empty,
        Water,
        Respawning,
        Rain_Landing,
        Tree_Top,
        Grass_Long,
        Grass_Short,
        Sunflower,
        Dust,
        Rain_Falling
  ].contains(type);

  static bool supportsOrientationRadial(int type) => const [
        Grass,
        Tree_Bottom,
        Tree_Top,
        Torch,
        Torch_Blue,
        Torch_Red,
        Concrete,
        Brick,
        Bricks_Red,
        Bricks_Brown,
        Wood,
        Road,
        Metal,
        Tree_Stump,
        Fireplace
  ].contains(type);

  static bool supportsOrientationSlopeSymmetric(int type) => const [
        Wood,
        Grass,
        Brick,
        Bricks_Red,
        Bricks_Brown,
        Concrete,
        Road,
        Metal,
        Wooden_Plank,
        Bau_Haus,
        Scaffold,
        Glass,
  ].contains(type);

  static bool supportsOrientationSlopeCornerInner(int type) => const [
        Grass,
        Concrete,
        Road,
        Metal,
        Bau_Haus,
  ].contains(type);

  static bool supportsOrientationSlopeCornerOuter(int type) => const [
        Concrete,
        Road,
        Metal,
        Grass
  ].contains(type);

  static bool supportsOrientationHalf(int type) => const [
        Wood,
        Window,
        Wooden_Plank,
        Brick,
        Bricks_Red,
        Bricks_Brown,
        Concrete,
        Road,
        Metal,
        Bau_Haus,
        Scaffold,
        Glass,
  ].contains(type);

  static bool supportsOrientationHalfVertical(int type) => const [
        Grass,
        Wood,
        Brick,
        Bricks_Red,
        Bricks_Brown,
        Road,
        Metal,
        Tile,
        Bau_Haus,
        Scaffold,
  ].contains(type);

  static bool supportsOrientationCorner(int type) =>
       type != NodeType.Window &&
       supportsOrientationHalf(type);

  static bool supportsOrientationColumn(int type) => const [
        Concrete,
        Brick,
        Bricks_Red,
        Bricks_Brown,
        Road,
        Metal,
        Wood,
        Grass,
  ].contains(type);

  static bool supportsOrientationDestroyed(int type) =>
      isDestroyable(type);

  static bool isDestroyable(int type) => const [
      Sunflower,
      Grass_Long,       
  ].contains(type);

  static bool isTransient(int value) => const [
        Empty,
        Grass_Long,
        Rain_Falling,
        Tree_Bottom,
        Tree_Top,
        Rain_Landing
      ].contains(value);

  static bool isRainOrEmpty(int value) =>
    value == Empty            ||
    isRain(value)              ;

  static bool isRain(int value) =>
    value == Rain_Falling    ||
    value == Rain_Landing     ;

  static bool blocksPerception(int value) =>
     supportsOrientationSolid(value);

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
       return NodeOrientation.Corner_North_East;
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

    if (NodeOrientation.slopeSymmetric.contains(orientation)){
      return supportsOrientationSlopeSymmetric(type);
    }

    if (orientation == NodeOrientation.Radial) {
      return supportsOrientationRadial(type);
    }

    if (NodeOrientation.isHalfVertical(orientation)) {
      return supportsOrientationHalfVertical(type);
    }

    if (NodeOrientation.isHalfVertical(orientation)) {
      return supportsOrientationHalfVertical(type);
    }

    if (NodeOrientation.isColumn(orientation)) {
      return supportsOrientationColumn(type);
    }

    // if (orientation == NodeOrientation.Destroyed){
    //   return supportsOrientationDestroyed(type);
    // }

    return false;
  }

  static String getName(int type) => const {
    Empty: 'Empty',
    Boundary: 'Boundary',
    Water: 'Water',
    Water_Flowing: 'Flowing Water',
    Torch: 'Torch',
    Tree_Bottom: 'Tree Bottom',
    Tree_Top: 'Tree Top',
    Grass_Long: 'Grass Long',
    Grass_Short: 'Grass Short',
    Rain_Falling: 'Rain Falling',
    Rain_Landing: 'Rain Landing',
    Fireplace: 'Fireplace',
    Soil: 'Soil',
    Concrete: 'Concrete',
    Metal: 'Metal',
    Bau_Haus: 'Bau Haus',
    Bau_Haus_Window: 'Bau Haus Window',
    Bau_Haus_Plain: 'Bau Hau Plain',
    Chimney: 'Chimney',
    Table: 'Table',
    Sunflower: 'Sunflower',
    Oven: 'Oven',
    Grass_Flowers: 'Grass Flowers',
    Brick: 'Brick',
    Wood: 'Wood',
    Grass: 'Grass',
    Window: 'Window',
    Wooden_Plank: 'Wooden Plank',
    Boulder: 'Boulder',
    Respawning: 'Respawning',
    Road: 'Road',
    Road_2: 'Road Paint',
    Shopping_Shelf: 'Shopping Shelf',
    Tile: 'Tile',
    Dust: 'Dust',
    Bookshelf: 'Bookshelf',
    Bricks_Red: 'Bricks (Red)',
    Bricks_Brown: 'Bricks (Brown)',
    Scaffold: 'Scaffold',
    Sandbag: 'Sandbag',
    Glass: 'Glass',
    Torch_Blue: 'Torch_Blue',
    Torch_Red: 'Torch_Red',
    Tree_Stump: 'Tree_Stump',
  }[type] ?? 'unknown($type)';

  static bool isLightSource(int type) => const [
      NodeType.Torch,
      NodeType.Torch_Blue,
      NodeType.Torch_Red,
      NodeType.Fireplace,
    ].contains(type);
}
