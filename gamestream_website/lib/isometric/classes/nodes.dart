import 'package:bleed_common/grid_node_type.dart';
import 'package:bleed_common/wind.dart';
import 'package:gamestream_flutter/isometric/animation_frame.dart';
import 'package:gamestream_flutter/isometric/particle_emitters.dart';
import 'package:gamestream_flutter/isometric/render/render_torch.dart';
import 'package:gamestream_flutter/isometric/variables/src_x_rain_landing.dart';
import 'package:gamestream_flutter/isometric/watches/torches_ignited.dart';
import 'package:lemon_engine/render.dart';

import '../constants/color_pitch_black.dart';
import '../variables/src_x_rain_falling.dart';
import 'node.dart';


class NodeBricks extends GridNodeColorRamp {

  NodeBricks(int row, int column, int z) : super(row: row, column: column, z: z);

  @override
  int get type => GridNodeType.Bricks;

  @override
  double get srcX => 7104;

  @override
  bool get isRainable => true;
}

class NodeGrass extends Node {

  NodeGrass(int row, int column, int z) : super(row, column, z);

  @override
  void handleRender() => renderSrcX(7158);

  @override
  int get type => GridNodeType.Grass;

  @override
  bool get isRainable => true;
}

class NodeGrassSlopeNorth extends GridNodeColorRamp {

  NodeGrassSlopeNorth(int row, int column, int z) : super(row: row, column: column, z: z);


  @override
  int get type => GridNodeType.Grass_Slope_North;

  @override
  double get srcX => 7925;
}

class NodeGrassSlopeEast extends GridNodeColorRamp {
  NodeGrassSlopeEast(int row, int column, int z) : super(row: row, column: column, z: z);

  @override
  int get type => GridNodeType.Grass_Slope_East;

  @override
  double get srcX => 7877;
}

class NodeGrassSlopeSouth extends GridNodeColorRamp {

  NodeGrassSlopeSouth(int row, int column, int z) : super(row: row, column: column, z: z);

  @override
  int get type => GridNodeType.Grass_Slope_South;

  @override
  double get srcX => 7829;
}

class NodeGrassSlopeWest extends GridNodeColorRamp {

  NodeGrassSlopeWest(int row, int column, int z) : super(row: row, column: column, z: z);

  @override
  int get type => GridNodeType.Grass_Slope_West;

  @override
  double get srcX => 7781;
}

class NodeGrassSlopeTop extends GridNodeColorRamp {
  NodeGrassSlopeTop(int row, int column, int z) : super(row: row, column: column, z: z);

  @override
  int get type => GridNodeType.Grass_Slope_Top;

  @override
  double get srcX => 8536;
}

class NodeGrassSlopeRight extends GridNodeColorRamp {
  NodeGrassSlopeRight(int row, int column, int z) : super(row: row, column: column, z: z);

  @override
  int get type => GridNodeType.Grass_Slope_Right;

  @override
  double get srcX => 8488;
}

class NodeGrassSlopeBottom extends GridNodeColorRamp {
  NodeGrassSlopeBottom(int row, int column, int z) : super(row: row, column: column, z: z);

  @override
  int get type => GridNodeType.Grass_Slope_Bottom;

  @override
  double get srcX => 8440;
}

class NodeGrassSlopeLeft extends GridNodeColorRamp {
  NodeGrassSlopeLeft(int row, int column, int z) : super(row: row, column: column, z: z);

  @override
  int get type => GridNodeType.Grass_Slope_Left;

  @override
  double get srcX => 8392;
}

class NodeGrassLong extends Node {

  late int rowMinusColumn;

  NodeGrassLong(int row, int column, int z) : super(row, column, z) {
    rowMinusColumn = row - column;
  }

  @override
  bool get blocksPerception => false;

  @override
  void handleRender() {

    switch (wind) {
      case windIndexCalm:
        return renderSrcX(10118);
      case windIndexGentle:
        return renderSrcX(10240 + ((((rowMinusColumn) + animationFrameGrass) % 6) * 48));
      default:
        return renderSrcX(10240 + ((((rowMinusColumn) + animationFrameGrass) % 6) * 48));
    }
  }
  @override
  int get type => GridNodeType.Grass_Long;
}


class NodeRainFalling extends Node {
  NodeRainFalling(int row, int column, int z) : super(row, column, z);

  @override
  bool get blocksPerception => false;

  @override
  void handleRender() {
    return render(
      dstX: dstX - rainPosition,
      dstY: dstY + animationFrameRain,
      srcX: srcXRainFalling,
      srcY: 72.0 * animationFrameRain,
      srcWidth: 48,
      srcHeight: 72,
      anchorY: 0.3334,
      color: colorShades[shade],
    );
  }
  @override
  int get type => GridNodeType.Rain_Falling;

  @override
  bool get isEmpty => true;

}

class NodeRainLanding extends Node {

  NodeRainLanding(int row, int column, int z) : super(row, column, z);

  @override
  bool get blocksPerception => false;

  @override
  void handleRender() {
    return render(
      dstX: dstX,
      dstY: dstY,
      srcX: srcXRainLanding,
      srcY: 72.0 * animationFrameRain,
      srcWidth: 48,
      srcHeight: 72,
      anchorY: 0.3334,
      color: colorShades[shade],
    );
  }
  @override
  int get type => GridNodeType.Rain_Landing;

  @override
  bool get isEmpty => true;
}

class NodeWood extends GridNodeColorRamp {
  NodeWood(int row, int column, int z) : super(row: row, column: column, z: z);

  @override
  int get type => GridNodeType.Wood;

  @override
  double get srcX => 8887;
}

class NodeSoil extends GridNodeColorRamp {
  NodeSoil(int row, int column, int z) : super(row: row, column: column, z: z);

  @override
  int get type => GridNodeType.Soil;

  @override
  double get srcX => 8320;

  @override
  bool get isRainable => true;
}

class NodeRoofHayNorth extends GridNodeColorRamp {
  NodeRoofHayNorth(int row, int column, int z) : super(row: row, column: column, z: z);

  @override
  int get type => GridNodeType.Roof_Tile_North;

  @override
  double get srcX => 9415;
}

class NodeRoofHaySouth extends GridNodeColorRamp {
  NodeRoofHaySouth(int row, int column, int z) : super(row: row, column: column, z: z);

  @override
  int get type => GridNodeType.Roof_Tile_South;

  @override
  double get srcX => 9463;
}

class NodeWoodHalfRow1 extends GridNodeColorRamp {
  NodeWoodHalfRow1(int row, int column, int z) : super(row: row, column: column, z: z);

  @override
  int get type => GridNodeType.Wood_Half_Row_1;

  @override
  double get srcX => 8935;
}

class NodeWoodHalfRow2 extends GridNodeColorRamp {
  NodeWoodHalfRow2(int row, int column, int z) : super(row: row, column: column, z: z) {
    dstX += 16;
    dstY -= 16;
  }

  @override
  int get type => GridNodeType.Wood_Half_Row_1;

  @override
  double get srcX => 8935;
}

class NodeWoodHalfColumn1 extends GridNodeColorRamp {
  NodeWoodHalfColumn1(int row, int column, int z) : super(row: row, column: column, z: z);

  @override
  int get type => GridNodeType.Wood_Half_Column_1;

  @override
  double get srcX => 8983;
}

class NodeWoodHalfColumn2 extends GridNodeColorRamp {
  NodeWoodHalfColumn2(int row, int column, int z) : super(row: row, column: column, z: z) {
    dstX -= 16;
    dstY -= 16;
  }

  @override
  int get type => GridNodeType.Wood_Half_Column_2;

  @override
  double get srcX => 8983;
}

class NodeWoodCornerBottom extends GridNodeColorRamp {
  NodeWoodCornerBottom(int row, int column, int z) : super(row: row, column: column, z: z);

  @override
  int get type => GridNodeType.Wood_Corner_Bottom;

  @override
  double get srcX => 9175;
}

class NodeWoodCornerLeft extends GridNodeColorRamp {
  NodeWoodCornerLeft(int row, int column, int z) : super(row: row, column: column, z: z);

  @override
  int get type => GridNodeType.Wood_Corner_Left;

  @override
  double get srcX => 9031;
}

class NodeWoodCornerTop extends GridNodeColorRamp {
  NodeWoodCornerTop(int row, int column, int z) : super(row: row, column: column, z: z);

  @override
  int get type => GridNodeType.Wood_Corner_Top;

  @override
  double get srcX => 9079;
}

class NodeWoodCornerRight extends GridNodeColorRamp {
  NodeWoodCornerRight(int row, int column, int z) : super(row: row, column: column, z: z);

  @override
  int get type => GridNodeType.Wood_Corner_Right;

  @override
  double get srcX => 9127;
}

class NodeWater extends Node {

  late int frame;

  NodeWater(int row, int column, int z) : super(row, column, z) {
    frame = (row + column);
  }

  @override
  void handleRender() {
    return render(
      dstX: dstX,
      dstY: dstY + animationFrameWaterHeight,
      srcX: 7976,
      srcY: (((animationFrameWater + frame) % 6) * 72.0),
      srcWidth: 48,
      srcHeight: 72,
      anchorY: 0.3334,
      color: colorShades[shade],
    );
  }
  @override
  int get type => GridNodeType.Water;

  @override
  bool get isRainable => true;
}

class NodeWaterFlowing extends Node {
  NodeWaterFlowing(int row, int column, int z) : super(row, column, z);

  @override
  void handleRender() {
    return render(
      dstX: dstX,
      dstY: dstY + animationFrameWaterHeight,
      srcX: 8096 + animationFrameWaterSrcX,
      srcY: 0,
      srcWidth: 48,
      srcHeight: 72,
      anchorY: 0.3334,
      color: colorShades[shade],
    );
  }
  @override
  int get type => GridNodeType.Water_Flowing;

  @override
  bool get isRainable => true;
}

class NodeStone extends GridNodeColorRamp {
  NodeStone(int row, int column, int z) : super(row: row, column: column, z: z);

  @override
  int get type => GridNodeType.Stone;

  @override
  double get srcX => 9831;
}

class NodeTorch extends Node {
  NodeTorch(int row, int column, int z) : super(row, column, z);

  @override
  void handleRender() {
    if (!torchesIgnited.value) {
      return renderTorchOff(dstX, dstY);
    }
    if (wind == Wind.Calm){
      return renderTorchOn(dstX, dstY);
    }
    return renderTorchOnWindy(dstX, dstY);
  }
  @override
  int get type => GridNodeType.Torch;

  @override
  bool get emitsLight => true;
}

class NodeTreeBottom extends Node {
  NodeTreeBottom(int row, int column, int z) : super(row, column, z);

  @override
  bool get blocksPerception => false;

  @override
  void handleRender() {
    return render(
      dstX: dstX,
      dstY: dstY,
      srcX: 1478,
      srcY: 0,
      srcWidth: 62.0,
      srcHeight: 74.0,
      anchorY: 0.5,
      color: colorShades[shade],
    );
  }
  @override
  int get type => GridNodeType.Tree_Bottom;
}

class NodeTreeTop extends Node {

  late int rowMinusColumn;
  late Node bottom;

  NodeTreeTop(int row, int column, int z) : super(row, column, z) {
    rowMinusColumn = row - column;
    bottom = Node.empty;
  }

  @override
  bool get blocksPerception => false;

  @override
  void handleRender() {
    animationFrameTreePosition = treeAnimation[(rowMinusColumn + animationFrame) % treeAnimation.length] * wind;
    return render(
      dstX: dstX + (animationFrameTreePosition * 0.5),
      dstY: dstY,
      srcX: 1541,
      srcY: 0,
      srcWidth: 62.0,
      srcHeight: 74.0,
      anchorY: 0.5,
      color: colorShades[bottom.shade],
    );

  }
  @override
  int get type => GridNodeType.Tree_Top;
}


class NodeFireplace extends Node {

  late int rowPlusColumn;

  NodeFireplace(int row, int column, int z) : super(row, column, z) {
    rowPlusColumn = row + column;
  }

  @override
  void handleRender() {
    return render(
      dstX: dstX,
      dstY: dstY,
      srcX: 6469,
      srcY: (((rowPlusColumn + (animationFrameTorch)) % 6) * 72),
      srcWidth: 48,
      srcHeight: 72,
      anchorY: 0.3334,
    );
  }
  @override
  int get type => GridNodeType.Fireplace;

  @override
  bool get emitsLight => true;
}

class GidNodeRoofHayNorth extends GridNodeColorRamp {
  GidNodeRoofHayNorth({required int row, required int column, required int z}) : super(row: row, column: column, z: z);

  @override
  int get type => GridNodeType.Roof_Hay_North;

  @override
  double get srcX => 9552;
}

class GidNodeRoofHaySouth extends GridNodeColorRamp {
  GidNodeRoofHaySouth({required int row, required int column, required int z}) : super(row: row, column: column, z: z);

  @override
  int get type => GridNodeType.Roof_Hay_South;

  @override
  double get srcX => 9600;
}


class NodeStairsNorth extends GridNodeColorRamp {
  NodeStairsNorth(int row, int column, int z) : super(row: row, column: column, z: z);

  @override
  int get type => GridNodeType.Stairs_North;

  @override
  double get srcX => 7494;
}

class NodeStairsEast extends GridNodeColorRamp {
  NodeStairsEast(int row, int column, int z) : super(row: row, column: column, z: z);

  @override
  int get type => GridNodeType.Stairs_East;

  @override
  double get srcX => 7542;
}

class NodeStairsSouth extends GridNodeColorRamp {
  NodeStairsSouth(int row, int column, int z) : super(row: row, column: column, z: z);

  @override
  int get type => GridNodeType.Stairs_South;

  @override
  double get srcX => 7398;
}

class NodeStairsWest extends GridNodeColorRamp {
  NodeStairsWest(int row, int column, int z) : super(row: row, column: column, z: z);

  @override
  int get type => GridNodeType.Stairs_West;

  @override
  double get srcX => 7446;
}

class NodeBrickTop extends GridNodeColorRamp {
  NodeBrickTop(int row, int column, int z) : super(row: row, column: column, z: z);

  @override
  int get type => GridNodeType.Brick_Top;

  @override
  double get srcX => 8621;
}

class NodeTileNorth extends GridNodeColorRamp {
  NodeTileNorth(int row, int column, int z) : super(row: row, column: column, z: z);

  @override
  int get type => GridNodeType.Roof_Tile_North;

  @override
  double get srcX => 9415;
}

class NodeTileSouth extends GridNodeColorRamp {
  NodeTileSouth(int row, int column, int z) : super(row: row, column: column, z: z);

  @override
  int get type => GridNodeType.Roof_Tile_South;

  @override
  double get srcX => 9463;
}

class NodeGrassEdgeTop extends GridNodeColorRamp {
  NodeGrassEdgeTop(int row, int column, int z) : super(row: row, column: column, z: z);

  @override
  double get srcX => 10042;

  @override
  int get type => GridNodeType.Grass_Edge_Top;
}

class NodeGrassEdgeRight extends GridNodeColorRamp {
  NodeGrassEdgeRight(int row, int column, int z) : super(row: row, column: column, z: z);

  @override
  double get srcX => 9994;

  @override
  int get type => GridNodeType.Grass_Edge_Right;
}

class NodeGrassEdgeBottom extends GridNodeColorRamp {
  NodeGrassEdgeBottom(int row, int column, int z) : super(row: row, column: column, z: z);

  @override
  double get srcX => 9946;

  @override
  int get type => GridNodeType.Grass_Edge_Bottom;
}

class NodeGrassEdgeLeft extends GridNodeColorRamp {
  NodeGrassEdgeLeft(int row, int column, int z) : super(row: row, column: column, z: z);

  @override
  double get srcX => 9898;

  @override
  int get type => GridNodeType.Grass_Edge_Left;
}

class NodeBauHaus extends GridNodeShaded {
  NodeBauHaus(int row, int column, int z) : super(row: row, column: column, z: z);

  @override
  double get srcX => 10545;

  @override
  int get type => GridNodeType.Bau_Haus;
}

class NodeBauHausRoofNorth extends GridNodeShaded {
  NodeBauHausRoofNorth(int row, int column, int z) : super(row: row, column: column, z: z);

  @override
  double get srcX => 10641;

  @override
  int get type => GridNodeType.Bau_Haus_Roof_North;
}

class NodeBauHausRoofSouth extends GridNodeShaded {
  NodeBauHausRoofSouth(int row, int column, int z): super(row: row, column: column, z: z);

  @override
  double get srcX => 10593;

  @override
  int get type => GridNodeType.Bau_Haus_Roof_South;
}


class NodeBauHausWindow extends GridNodeColorRamp {
  NodeBauHausWindow(int row, int column, int z) : super(row: row, column: column, z: z);

  @override
  double get srcX => 10689;

  @override
  int get type => GridNodeType.Bau_Haus_Window;
}

class NodeBauHausPlain extends GridNodeColorRamp {
  NodeBauHausPlain(int row, int column, int z) : super(row: row, column: column, z: z);

  @override
  double get srcX => 10738;

  @override
  int get type => GridNodeType.Bau_Haus_Plain;
}

class NodeBauHausChimney extends GridNodeColorRamp {
  NodeBauHausChimney(int row, int column, int z) : super(row: row, column: column, z: z) {
    addSmokeEmitter(z + 1, row, column);
  }

  @override
  double get srcX => 10787;

  @override
  int get type => GridNodeType.Chimney;
}


class NodeBedTop extends GridNodeShaded {

  NodeBedTop(int row, int column, int z) : super(row: row, column: column, z: z);

  @override
  int get type => GridNodeType.Bed_Top;

  @override
  double get srcX => 10885;

  @override
  bool get isRainable => true;
}

class NodeBedBottom extends GridNodeShaded {

  NodeBedBottom(int row, int column, int z) : super(row: row, column: column, z: z);

  @override
  int get type => GridNodeType.Bed_Bottom;

  @override
  double get srcX => 10836;

  @override
  bool get isRainable => true;
}

class NodeTable extends GridNodeShaded {

  NodeTable(int row, int column, int z) : super(row: row, column: column, z: z);

  @override
  int get type => GridNodeType.Table;

  @override
  double get srcX => 7639;

  @override
  bool get isRainable => true;
}

class NodeSunflower extends GridNodeShaded {

  NodeSunflower(int row, int column, int z) : super(row: row, column: column, z: z);

  @override
  int get type => GridNodeType.Sunflower;

  @override
  double get srcX => 10934;

  @override
  bool get isRainable => true;
}

class NodeOven extends GridNodeShaded {

  NodeOven(int row, int column, int z) : super(row: row, column: column, z: z);

  @override
  int get type => GridNodeType.Oven;

  @override
  double get srcX => 10984;

  @override
  bool get isRainable => true;

  @override
  bool get emitsLight => true;
}