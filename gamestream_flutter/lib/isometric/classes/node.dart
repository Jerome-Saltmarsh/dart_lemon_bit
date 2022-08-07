
import 'package:bleed_common/Shade.dart';
import 'package:lemon_math/library.dart';
import 'package:bleed_common/grid_node_type.dart';
import 'package:bleed_common/tile_size.dart';
import 'package:bleed_common/wind.dart';
import 'package:gamestream_flutter/isometric/animation_frame.dart';
import 'package:gamestream_flutter/isometric/render/render_torch.dart';
import 'package:gamestream_flutter/isometric/variables/src_x_rain_landing.dart';
import 'package:gamestream_flutter/isometric/watches/torches_ignited.dart';
import 'package:lemon_engine/actions/render_atlas.dart';
import 'package:lemon_engine/render.dart';

import '../constants/color_pitch_black.dart';
import '../render/render_grid_node.dart';
import '../variables/src_x_rain_falling.dart';

abstract class Node {
  var bake = 0;
  var shade = 0;
  var _wind = 0;
  var dstX = 0.0;
  var dstY = 0.0;

  set wind (int value){
     _wind = clamp(value, 0, windIndexStrong);
  }

  void applyLight(int value){
    assert (value >= 0);
    assert (value <= Shade.Pitch_Black);
    if (shade <= value) return;
    shade = value;
  }

  int get wind => _wind;

  late double order;

  Node(int row, int column, int z) {
     dstX = (row - column) * tileSizeHalf;
     dstY = ((row + column) * tileSizeHalf) - (z * tileHeight);
     order = ((row + column) * tileSize);
  }

  int get type;
  String get name => GridNodeType.getName(type);
  bool get isEmpty => false;
  bool get isRainable => false;
  bool get renderable => true;
  bool get blocksPerception => true;

  void resetShadeToBake(){
    shade = bake;
  }

  static final boundary = NodeBoundary();
  static final empty = NodeEmpty();

  // void performRender(){
  //   // if (dstX < screen.left - tileSize) {
  //   //   offscreenNodes++;
  //   //   offscreenNodesLeft++;
  //   //   return;
  //   // }
  //   // if (dstX > screen.right + tileSize) {
  //   //   offscreenNodes++;
  //   //   offscreenNodesRight++;
  //   //   return;
  //   // }
  //   // if (dstY < screen.top - tileSize) {
  //   //   offscreenNodes++;
  //   //   offscreenNodesTop++;
  //   //   return;
  //   // }
  //   // if (dstY > screen.bottom + tileSize) {
  //   //   offscreenNodes++;
  //   //   offscreenNodesBottom++;
  //   //   return;
  //   // }
  //   // onscreenNodes++;
  //   handleRender();
  // }

  void handleRender();

  void renderSrcX(double srcX){
    const spriteWidth = 48.0;
    const spriteHeight = 72.0;
    const spriteWidthHalf = 24.0;
    const spriteHeightThird = 24.0;

    var srcY = shade * spriteHeight;

    if (transparent){
      srcY += 432;
    }

    src[bufferIndex] = srcX;
    dst[bufferIndex] = 1;
    colors[renderIndex] = 0;

    bufferIndex++;

    src[bufferIndex] = srcY;
    dst[bufferIndex] = 0;

    bufferIndex++;

    src[bufferIndex] = srcX + spriteWidth;
    dst[bufferIndex] = dstX - spriteWidthHalf;

    bufferIndex++;

    src[bufferIndex] = srcY + spriteHeight;
    dst[bufferIndex] = dstY - spriteHeightThird;

    bufferIndex++;
    renderIndex++;

    if (bufferIndex < buffers) return;
    bufferIndex = 0;
    renderIndex = 0;
    renderAtlas();
  }
}

class NodeBoundary extends Node {
  NodeBoundary() : super(0, 0, 0);

  @override
  void handleRender() {
     throw Exception("Cannot render boundary");
  }

  @override
  bool get renderable => false;

  @override
  int get type => GridNodeType.Boundary;

  @override
  bool get blocksPerception => false;
}

class NodeEmpty extends Node {
  NodeEmpty() : super(0, 0, 0);

  @override
  void handleRender() {

  }

  @override
  void resetShadeToBake(){

  }

  @override
  bool get blocksPerception => false;

  @override
  bool get renderable => false;

  @override
  int get type => GridNodeType.Empty;

  @override
  bool get isEmpty => true;
}

abstract class GridNodeBasic extends Node {

  GridNodeBasic({
    required int row,
    required int column,
    required int z,
  }) : super(row, column, z);

  @override
  void handleRender() => renderSrcX(srcX);

  double get srcX;
}

class NodeBricks extends GridNodeBasic {

  NodeBricks(int row, int column, int z) : super(row: row, column: column, z: z);

  @override
  int get type => GridNodeType.Bricks;

  @override
  double get srcX => 7104;

  @override
  bool get isRainable => true;
}

class NodeGrass extends Node {

  late int rowMinusColumn;

  NodeGrass(int row, int column, int z) : super(row, column, z) {
    rowMinusColumn = row - column;
  }

  @override
  void handleRender() {
    renderSrcX(7158);
    // if (wind == windIndexCalm) return renderSrcX(5267);
    // return renderSrcX(5267 + ((((rowMinusColumn) + animationFrameGrassShort) % 6) * 48));
  }
  @override
  int get type => GridNodeType.Grass;

  @override
  bool get isRainable => true;
}

class NodeGrassSlopeNorth extends GridNodeBasic {

  NodeGrassSlopeNorth(int row, int column, int z) : super(row: row, column: column, z: z);


  @override
  int get type => GridNodeType.Grass_Slope_North;

  @override
  double get srcX => 7925;
}

class NodeGrassSlopeEast extends GridNodeBasic {
  NodeGrassSlopeEast(int row, int column, int z) : super(row: row, column: column, z: z);

  @override
  int get type => GridNodeType.Grass_Slope_East;

  @override
  double get srcX => 7877;
}

class NodeGrassSlopeSouth extends GridNodeBasic {

  NodeGrassSlopeSouth(int row, int column, int z) : super(row: row, column: column, z: z);

  @override
  int get type => GridNodeType.Grass_Slope_South;

  @override
  double get srcX => 7829;
}

class NodeGrassSlopeWest extends GridNodeBasic {

  NodeGrassSlopeWest(int row, int column, int z) : super(row: row, column: column, z: z);

  @override
  int get type => GridNodeType.Grass_Slope_West;

  @override
  double get srcX => 7781;
}

class NodeGrassSlopeTop extends GridNodeBasic {
  NodeGrassSlopeTop(int row, int column, int z) : super(row: row, column: column, z: z);

  @override
  int get type => GridNodeType.Grass_Slope_Top;

  @override
  double get srcX => 8536;
}

class NodeGrassSlopeRight extends GridNodeBasic {
  NodeGrassSlopeRight(int row, int column, int z) : super(row: row, column: column, z: z);

  @override
  int get type => GridNodeType.Grass_Slope_Right;

  @override
  double get srcX => 8488;
}

class NodeGrassSlopeBottom extends GridNodeBasic {
  NodeGrassSlopeBottom(int row, int column, int z) : super(row: row, column: column, z: z);

  @override
  int get type => GridNodeType.Grass_Slope_Bottom;

  @override
  double get srcX => 8440;
}

class NodeGrassSlopeLeft extends GridNodeBasic {
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

class NodeWood extends GridNodeBasic {
  NodeWood(int row, int column, int z) : super(row: row, column: column, z: z);

  @override
  int get type => GridNodeType.Wood;

  @override
  double get srcX => 8887;
}

class NodeSoil extends GridNodeBasic {
  NodeSoil(int row, int column, int z) : super(row: row, column: column, z: z);

  @override
  int get type => GridNodeType.Soil;

  @override
  double get srcX => 8320;

  @override
  bool get isRainable => true;
}

class NodeRoofHayNorth extends GridNodeBasic {
  NodeRoofHayNorth(int row, int column, int z) : super(row: row, column: column, z: z);

  @override
  int get type => GridNodeType.Roof_Tile_North;

  @override
  double get srcX => 9415;
}

class NodeRoofHaySouth extends GridNodeBasic {
  NodeRoofHaySouth(int row, int column, int z) : super(row: row, column: column, z: z);

  @override
  int get type => GridNodeType.Roof_Tile_South;

  @override
  double get srcX => 9463;
}

class NodeWoodHalfRow1 extends GridNodeBasic {
  NodeWoodHalfRow1(int row, int column, int z) : super(row: row, column: column, z: z);

  @override
  int get type => GridNodeType.Wood_Half_Row_1;

  @override
  double get srcX => 8935;
}

class NodeWoodHalfRow2 extends GridNodeBasic {
  NodeWoodHalfRow2(int row, int column, int z) : super(row: row, column: column, z: z) {
      dstX += 16;
      dstY -= 16;
  }

  @override
  int get type => GridNodeType.Wood_Half_Row_1;

  @override
  double get srcX => 8935;
}

class NodeWoodHalfColumn1 extends GridNodeBasic {
  NodeWoodHalfColumn1(int row, int column, int z) : super(row: row, column: column, z: z);

  @override
  int get type => GridNodeType.Wood_Half_Column_1;

  @override
  double get srcX => 8983;
}

class NodeWoodHalfColumn2 extends GridNodeBasic {
  NodeWoodHalfColumn2(int row, int column, int z) : super(row: row, column: column, z: z) {
      dstX -= 16;
      dstY -= 16;
  }

  @override
  int get type => GridNodeType.Wood_Half_Column_2;

  @override
  double get srcX => 8983;
}

class NodeWoodCornerBottom extends GridNodeBasic {
  NodeWoodCornerBottom(int row, int column, int z) : super(row: row, column: column, z: z);

  @override
  int get type => GridNodeType.Wood_Corner_Bottom;

  @override
  double get srcX => 9175;
}

class NodeWoodCornerLeft extends GridNodeBasic {
  NodeWoodCornerLeft(int row, int column, int z) : super(row: row, column: column, z: z);

  @override
  int get type => GridNodeType.Wood_Corner_Left;

  @override
  double get srcX => 9031;
}

class NodeWoodCornerTop extends GridNodeBasic {
  NodeWoodCornerTop(int row, int column, int z) : super(row: row, column: column, z: z);

  @override
  int get type => GridNodeType.Wood_Corner_Top;

  @override
  double get srcX => 9079;
}

class NodeWoodCornerRight extends GridNodeBasic {
  NodeWoodCornerRight(int row, int column, int z) : super(row: row, column: column, z: z);

  @override
  int get type => GridNodeType.Wood_Corner_Right;

  @override
  double get srcX => 9127;
}

class NodeWater extends Node {
  NodeWater(int row, int column, int z) : super(row, column, z);

  @override
  void handleRender() {
    return render(
      dstX: dstX,
      dstY: dstY + animationFrameWaterHeight,
      srcX: 7206 + animationFrameWaterSrcX,
      srcY: 72.0 * shade,
      srcWidth: 48,
      srcHeight: 72,
      anchorY: 0.3334,
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
      srcY: 72.0 * shade,
      srcWidth: 48,
      srcHeight: 72,
      anchorY: 0.3334,
    );
  }
  @override
  int get type => GridNodeType.Water_Flowing;

  @override
  bool get isRainable => true;
}

class NodeStone extends GridNodeBasic {
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
      srcY: 74.0 * shade,
      srcWidth: 62.0,
      srcHeight: 74.0,
      anchorY: 0.5,
    );
  }
  @override
  int get type => GridNodeType.Tree_Bottom;
}

class NodeTreeTop extends Node {

  late int rowMinusColumn;

  NodeTreeTop(int row, int column, int z) : super(row, column, z) {
    rowMinusColumn = row - column;
  }

  @override
  bool get blocksPerception => false;

  @override
  void handleRender() {
    animationFrameTreePosition = treeAnimation[(rowMinusColumn + animationFrame) % treeAnimation.length] * wind;
    return render(
      dstX: dstX + (animationFrameTreePosition * 0.5),
      dstY: dstY,
      srcX: 1540,
      srcY: 74.0 * shade,
      srcWidth: 62.0,
      srcHeight: 74.0,
      anchorY: 0.5,
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
}

class GidNodeRoofHayNorth extends GridNodeBasic {
  GidNodeRoofHayNorth({required int row, required int column, required int z}) : super(row: row, column: column, z: z);

  @override
  int get type => GridNodeType.Roof_Hay_North;

  @override
  double get srcX => 9552;
}

class GidNodeRoofHaySouth extends GridNodeBasic {
  GidNodeRoofHaySouth({required int row, required int column, required int z}) : super(row: row, column: column, z: z);

  @override
  int get type => GridNodeType.Roof_Hay_South;

  @override
  double get srcX => 9600;
}


class NodeStairsNorth extends GridNodeBasic {
  NodeStairsNorth(int row, int column, int z) : super(row: row, column: column, z: z);

  @override
  int get type => GridNodeType.Stairs_North;

  @override
  double get srcX => 7494;
}

class NodeStairsEast extends GridNodeBasic {
  NodeStairsEast(int row, int column, int z) : super(row: row, column: column, z: z);

  @override
  int get type => GridNodeType.Stairs_East;

  @override
  double get srcX => 7542;
}

class NodeStairsSouth extends GridNodeBasic {
  NodeStairsSouth(int row, int column, int z) : super(row: row, column: column, z: z);

  @override
  int get type => GridNodeType.Stairs_South;

  @override
  double get srcX => 7398;
}

class NodeStairsWest extends GridNodeBasic {
  NodeStairsWest(int row, int column, int z) : super(row: row, column: column, z: z);

  @override
  int get type => GridNodeType.Stairs_West;

  @override
  double get srcX => 7446;
}

class NodeBrickTop extends GridNodeBasic {
  NodeBrickTop(int row, int column, int z) : super(row: row, column: column, z: z);

  @override
  int get type => GridNodeType.Brick_Top;

  @override
  double get srcX => 8621;
}

class NodeTileNorth extends GridNodeBasic {
  NodeTileNorth(int row, int column, int z) : super(row: row, column: column, z: z);

  @override
  int get type => GridNodeType.Roof_Tile_North;

  @override
  double get srcX => 9415;
}

class NodeTileSouth extends GridNodeBasic {
  NodeTileSouth(int row, int column, int z) : super(row: row, column: column, z: z);

  @override
  int get type => GridNodeType.Roof_Tile_South;

  @override
  double get srcX => 9463;
}

class NodeGrassEdgeTop extends GridNodeBasic {
  NodeGrassEdgeTop(int row, int column, int z) : super(row: row, column: column, z: z);

  @override
  double get srcX => 10042;

  @override
  int get type => GridNodeType.Grass_Edge_Top;
}

class NodeGrassEdgeRight extends GridNodeBasic {
  NodeGrassEdgeRight(int row, int column, int z) : super(row: row, column: column, z: z);

  @override
  double get srcX => 9994;

  @override
  int get type => GridNodeType.Grass_Edge_Right;
}

class NodeGrassEdgeBottom extends GridNodeBasic {
  NodeGrassEdgeBottom(int row, int column, int z) : super(row: row, column: column, z: z);

  @override
  double get srcX => 9946;

  @override
  int get type => GridNodeType.Grass_Edge_Bottom;
}

class NodeGrassEdgeLeft extends GridNodeBasic {
  NodeGrassEdgeLeft(int row, int column, int z) : super(row: row, column: column, z: z);

  @override
  double get srcX => 9898;

  @override
  int get type => GridNodeType.Grass_Edge_Left;
}