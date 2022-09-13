import 'package:bleed_common/node_orientation.dart';
import 'package:gamestream_flutter/isometric/grid.dart';
import 'package:gamestream_flutter/isometric/watches/raining.dart';
import 'package:lemon_math/library.dart';
import 'package:bleed_common/node_type.dart';
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


const srcYIndex0 = 0.0;
const srcYIndex1 = 73.0;
const srcYIndex2 = srcYIndex1 * 2;
const srcYIndex3 = srcYIndex1 * 3;
const srcYIndex4 = srcYIndex1 * 4;
const srcYIndex5 = srcYIndex1 * 5;
const srcYIndex6 = srcYIndex1 * 6;
const srcYIndex7 = srcYIndex1 * 7;
const srcYIndex8 = srcYIndex1 * 8;
const srcYIndex9 = srcYIndex1 * 9;
const srcYIndex10 = srcYIndex1 * 10;

const spriteWidth = 48.0;
const spriteHeight = 72.0;

const spriteWidthPadded = spriteWidth + 1;
const spriteHeightPadded = spriteHeight + 1;

const srcIndexX0 = spriteWidthPadded * 0;
const srcIndexX1 = spriteWidthPadded * 1;
const srcIndexX2 = spriteWidthPadded * 2;
const srcIndexX3 = spriteWidthPadded * 3;
const srcIndexX4 = spriteWidthPadded * 4;
const srcIndexX5 = spriteWidthPadded * 5;
const srcIndexX6 = spriteWidthPadded * 6;
const srcIndexX7 = spriteWidthPadded * 7;

class NodeGrassFlowers extends Node {

  NodeGrassFlowers(int row, int column, int z) : super(row, column, z);

  @override
  void handleRender() => renderShadeManual(9782);

  @override
  int get type => NodeType.Grass_Flowers;
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
        return renderShadeManual(10118);
      // case windIndexGentle:
      //   return renderShadeManual(10240 + ((((rowMinusColumn) + animationFrameGrass) % 6) * 48));
      // case windIndexStrong:
      //   return render(
      //       dstX: dstX,
      //       dstY: dstY + 24,
      //       srcX: 8672,
      //       srcY: (((rowMinusColumn) + animationFrameGrass) % 6) * 72,
      //       srcWidth: 72,
      //       srcHeight: 72,
      //   );
      default:
        return renderShadeManual(10240 + ((((rowMinusColumn) + animationFrameGrass) % 6) * 48));
    }
  }
  @override
  int get type => NodeType.Grass_Long;
}


class NodeRainFalling extends Node {

  late int frame;

  NodeRainFalling(int row, int column, int z) : super(row, column, z) {
    frame = randomInt(0, 5);
  }

  @override
  bool get blocksPerception => false;

  @override
  void handleRender() {
    return render(
      dstX: dstX - rainPosition,
      dstY: dstY + animationFrameRain,
      srcX: srcXRainFalling,
      srcY: 72.0 * ((animationFrameRain + frame) % 6),
      srcWidth: 48,
      srcHeight: 72,
      anchorY: 0.3334,
      color: colorShades[shade],
    );
  }
  @override
  int get type => NodeType.Rain_Falling;

  @override
  bool get isEmpty => true;

}

class NodeRainLanding extends Node {
  late int frame;
  late bool onWater;

  NodeRainLanding(int row, int column, int z) : super(row, column, z) {
    frame = (row + column) * 2;
    onWater = getNode(z - 1, row, column).type == NodeType.Water;
  }

  @override
  bool get blocksPerception => false;

  @override
  void handleRender() {
    if (onWater){
      return render(
        dstX: dstX,
        dstY: dstY,
        srcX: 9280,
        srcY: 72.0 * ((animationFrameRain + frame) % 10),
        srcWidth: 48,
        srcHeight: 72,
        anchorY: 0.3334,
        color: colorShades[shade],
      );
    }

    return render(
      dstX: dstX,
      dstY: dstY,
      srcX: srcXRainLanding,
      srcY: 72.0 * ((animationFrameRain + frame) % 6),
      srcWidth: 48,
      srcHeight: 72,
      anchorY: 0.3334,
      color: colorShades[shade],
    );
  }
  @override
  int get type => NodeType.Rain_Landing;

  @override
  bool get isEmpty => true;
}

class NodeSoil extends NodeShadeManual {
  NodeSoil(int row, int column, int z) : super(row: row, column: column, z: z);

  @override
  int get type => NodeType.Soil;

  @override
  double get srcX => 8320;
}

class NodeRoofHayNorth extends NodeShadeManual {
  NodeRoofHayNorth(int row, int column, int z) : super(row: row, column: column, z: z);

  @override
  int get type => NodeType.Roof_Tile_North;

  @override
  double get srcX => 9415;
}


class NodeRoofHaySouth extends NodeShadeManual {
  NodeRoofHaySouth(int row, int column, int z) : super(row: row, column: column, z: z);

  @override
  int get type => NodeType.Roof_Tile_South;

  @override
  double get srcX => 9463;
}

class NodeWater extends Node {

  late int frame;

  NodeWater(int row, int column, int z) : super(row, column, z) {
    frame = (row + column) * 3;
  }

  @override
  void handleRender() {
    return render(
      dstX: dstX,
      dstY: dstY + animationFrameWaterHeight,
      srcX: 7976,
      srcY: (((animationFrameWater + frame) % 10) * 72.0),
      srcWidth: 48,
      srcHeight: 72,
      anchorY: 0.3334,
      color: colorShades[shade],
    );
  }
  @override
  int get type => NodeType.Water;

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
  int get type => NodeType.Water_Flowing;

  @override
  bool get isRainable => true;
}

class NodeStone extends NodeShadeManual {
  NodeStone(int row, int column, int z) : super(row: row, column: column, z: z);

  @override
  int get type => NodeType.Stone;

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
  int get type => NodeType.Torch;

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
  int get type => NodeType.Tree_Bottom;
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

    final f = raining.value ? animationFrame % 4 : -1;

    animationFrameTreePosition = treeAnimation[(rowMinusColumn + animationFrame) % treeAnimation.length] * wind;
    return render(
      dstX: dstX + (animationFrameTreePosition * 0.5),
      dstY: dstY,
      srcX: 1541,
      srcY: 74.0 + (74 * f),
      srcWidth: 62.0,
      srcHeight: 74.0,
      anchorY: 0.5,
      color: colorShades[bottom.shade],
    );

  }
  @override
  int get type => NodeType.Tree_Top;
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
  int get type => NodeType.Fireplace;

  @override
  bool get emitsLight => true;
}

class GidNodeRoofHayNorth extends NodeShadeManual {
  GidNodeRoofHayNorth({required int row, required int column, required int z}) : super(row: row, column: column, z: z);

  @override
  int get type => NodeType.Roof_Hay_North;

  @override
  double get srcX => 9552;
}

class GidNodeRoofHaySouth extends NodeShadeManual {
  GidNodeRoofHaySouth({required int row, required int column, required int z}) : super(row: row, column: column, z: z);

  @override
  int get type => NodeType.Roof_Hay_South;

  @override
  double get srcX => 9600;
}

class NodeBrickTop extends NodeShadeManual {
  NodeBrickTop(int row, int column, int z) : super(row: row, column: column, z: z);

  @override
  int get type => NodeType.Brick_Top;

  @override
  double get srcX => 8621;

  @override
  bool get isStone => true;
}

class NodeTileNorth extends NodeShadeManual {
  NodeTileNorth(int row, int column, int z) : super(row: row, column: column, z: z);

  @override
  int get type => NodeType.Roof_Tile_North;

  @override
  double get srcX => 9415;
}

class NodeTileSouth extends NodeShadeManual {
  NodeTileSouth(int row, int column, int z) : super(row: row, column: column, z: z);

  @override
  int get type => NodeType.Roof_Tile_South;

  @override
  double get srcX => 9463;
}

class NodeBauHaus extends Node {
  NodeBauHaus(int row, int column, int z) : super(row, column, z);

  @override
  int get type => NodeType.Bau_Haus_2;

  @override
  void handleRender() {
    const srcX = 11720.0;
    if (orientation == NodeOrientation.Solid)
      return renderShadeAuto(srcX, srcYIndex0);
    if (orientation == NodeOrientation.Half_South)
      return renderShadeAuto(srcX, srcYIndex1);
    if (orientation == NodeOrientation.Half_North){
      dstX -= 17;
      dstY -= 17;
      renderShadeAuto(srcX, srcYIndex1);
      dstX += 17;
      dstY += 17;
      return;
    }
    if (orientation == NodeOrientation.Half_West)
      return renderShadeAuto(srcX, srcYIndex2);
    if (orientation == NodeOrientation.Half_East){
      dstX += 17;
      dstY -= 17;
      renderShadeAuto(srcX, srcYIndex2);
      dstX -= 17;
      dstY += 17;
      return;
    }
    if (orientation == NodeOrientation.Corner_Top)
      return renderShadeAuto(srcX, srcYIndex3);
    if (orientation == NodeOrientation.Corner_Right)
      return renderShadeAuto(srcX, srcYIndex4);
    if (orientation == NodeOrientation.Corner_Bottom)
      return renderShadeAuto(srcX, srcYIndex5);
    if (orientation == NodeOrientation.Corner_Left)
      return renderShadeAuto(srcX, srcYIndex6);
    if (orientation == NodeOrientation.Slope_North)
      return renderShadeAuto(11228, 0);
    if (orientation == NodeOrientation.Slope_East)
      return renderShadeAuto(11228, 73);
    if (orientation == NodeOrientation.Slope_South)
      return renderShadeAuto(11228, 146);
    if (orientation == NodeOrientation.Slope_West)
      return renderShadeAuto(11228, 219);
    if (orientation == NodeOrientation.Slope_Inner_North_East)
      return renderShadeAuto(11228, 292);
    if (orientation == NodeOrientation.Slope_Inner_South_East)
      return renderShadeAuto(11228, 365);
    if (orientation == NodeOrientation.Slope_Inner_South_West)
      return renderShadeAuto(11228, 438);
    if (orientation == NodeOrientation.Slope_Inner_North_West)
      return renderShadeAuto(11228, 511);
  }
}

class NodeBauHausWindow extends NodeShadeManual {
  NodeBauHausWindow(int row, int column, int z) : super(row: row, column: column, z: z);

  @override
  double get srcX => 10689;

  @override
  int get type => NodeType.Bau_Haus_Window;
}

class NodeBauHausChimney extends NodeShadeManual {
  NodeBauHausChimney(int row, int column, int z) : super(row: row, column: column, z: z) {
    addSmokeEmitter(z + 1, row, column);
  }

  @override
  double get srcX => 10787;

  @override
  int get type => NodeType.Chimney;
}


class NodeBedTop extends NodeShadeAuto {

  NodeBedTop(int row, int column, int z) : super(row: row, column: column, z: z);

  @override
  int get type => NodeType.Bed_Top;

  @override
  double get srcX => 10885;

  @override
  bool get isRainable => true;
}

class NodeBedBottom extends NodeShadeAuto {

  NodeBedBottom(int row, int column, int z) : super(row: row, column: column, z: z);

  @override
  int get type => NodeType.Bed_Bottom;

  @override
  double get srcX => 10836;

  @override
  bool get isRainable => true;
}

class NodeTable extends NodeShadeAuto {

  NodeTable(int row, int column, int z) : super(row: row, column: column, z: z);

  @override
  int get type => NodeType.Table;

  @override
  double get srcX => 7639;

  @override
  bool get isRainable => true;
}

class NodeSunflower extends NodeShadeAuto {

  NodeSunflower(int row, int column, int z) : super(row: row, column: column, z: z);

  @override
  int get type => NodeType.Sunflower;

  @override
  double get srcX => 10934;

  @override
  bool get isRainable => true;
}

class NodeOven extends NodeShadeAuto {

  NodeOven(int row, int column, int z) : super(row: row, column: column, z: z);

  @override
  int get type => NodeType.Oven;

  @override
  double get srcX => 10984;

  @override
  bool get isRainable => true;

  @override
  bool get emitsLight => true;
}

class NodeBoulder extends NodeShadeAuto {

  NodeBoulder(int row, int column, int z) : super(row: row, column: column, z: z);

  @override
  int get type => NodeType.Boulder;

  @override
  double get srcX => 11769;

  @override
  bool get isRainable => false;

  @override
  bool get emitsLight => false;
}

class NodeBricks2 extends Node {
  NodeBricks2(int row, int column, int z) : super(row, column, z);

  @override
  int get type => NodeType.Brick_2;

  @override
  bool get isStone => true;

  @override
  bool get isRainable => orientation == NodeOrientation.Solid;

  @override
  void handleRender() {
    const srcX = 11377.0;

    if (orientation == NodeOrientation.Solid)
      return renderShadeManual(srcX + srcIndexX0);
    if (orientation == NodeOrientation.Slope_North)
       return renderShadeManual(7394);
    if (orientation == NodeOrientation.Slope_East)
      return renderShadeManual(7443);
    if (orientation == NodeOrientation.Slope_South)
      return renderShadeManual(7492);
    if (orientation == NodeOrientation.Slope_West)
      return renderShadeManual(7541);
    if (orientation == NodeOrientation.Half_West)
      return renderShadeManual(srcX + srcIndexX1);
    if (orientation == NodeOrientation.Half_South)
      return renderShadeManual(srcX + srcIndexX2);
    if (orientation == NodeOrientation.Half_East){
      dstX += 17;
      dstY -= 17;
      renderShadeManual(srcX + srcIndexX1);
      dstX -= 17;
      dstY += 17;
      return;
    }
    if (orientation == NodeOrientation.Half_North){
      dstX -= 17;
      dstY -= 17;
      renderShadeManual(srcX + srcIndexX2);
      dstX += 17;
      dstY += 17;
      return;
    }

    if (orientation == NodeOrientation.Corner_Top)
      return renderShadeManual(srcX + srcIndexX3);
    if (orientation == NodeOrientation.Corner_Right)
      return renderShadeManual(srcX + srcIndexX4);
    if (orientation == NodeOrientation.Corner_Bottom)
      return renderShadeManual(srcX + srcIndexX5);
    if (orientation == NodeOrientation.Corner_Left)
      return renderShadeManual(srcX + srcIndexX6);

    throw Exception("Cannot render brick orientation ${NodeOrientation.getName(orientation)}");
  }
}


class NodeWood2 extends Node {
  NodeWood2(int row, int column, int z) : super(row, column, z) ;

  @override
  int get type => NodeType.Wood_2;

  @override
  bool get isWood => true;

  @override
  void handleRender() {
    if (orientation == NodeOrientation.Solid)
      return renderShadeManual(8886);
    if (orientation == NodeOrientation.Slope_North)
      return renderShadeManual(11179);
    if (orientation == NodeOrientation.Slope_East)
      return renderShadeManual(11130);
    if (orientation == NodeOrientation.Slope_South)
      return renderShadeManual(11082);
    if (orientation == NodeOrientation.Slope_West)
      return renderShadeManual(11032);
    if (orientation == NodeOrientation.Half_North){
      dstX -= 17;
      dstY -= 17;
      renderShadeManual(8983);
      dstX += 17;
      dstY += 17;
      return;
    }
    if (orientation == NodeOrientation.Half_East) {
      dstX += 17;
      dstY -= 17;
      renderShadeManual(8935);
      dstX -= 17;
      dstY += 17;
      return;
    }
    if (orientation == NodeOrientation.Half_West)
      return renderShadeManual(8935);
    if (orientation == NodeOrientation.Half_South) {
      return renderShadeManual(8983);
    }
    if (orientation == NodeOrientation.Corner_Top)
      return renderShadeManual(9082);
    if (orientation == NodeOrientation.Corner_Right)
      return renderShadeManual(9131);
    if (orientation == NodeOrientation.Corner_Bottom)
      return renderShadeManual(9180);
    if (orientation == NodeOrientation.Corner_Left)
      return renderShadeManual(9033);
    throw Exception("Cannot render NodeWood2 orientation $orientation");
  }
}

class NodeCottageRoof extends Node {
  NodeCottageRoof(int row, int column, int z) : super(row, column, z);

  @override
  int get type => NodeType.Cottage_Roof;

  @override
  void handleRender() {
    if (orientation == NodeOrientation.Slope_North)
      return renderShadeAuto(11228, 0);
    if (orientation == NodeOrientation.Slope_East)
      return renderShadeAuto(11228, 73);
    if (orientation == NodeOrientation.Slope_South)
      return renderShadeAuto(11228, 146);
    if (orientation == NodeOrientation.Slope_West)
      return renderShadeAuto(11228, 219);
    if (orientation == NodeOrientation.Slope_Inner_North_East)
      return renderShadeAuto(11228, 292);
    if (orientation == NodeOrientation.Slope_Inner_South_East)
      return renderShadeAuto(11228, 365);
    if (orientation == NodeOrientation.Slope_Inner_South_West)
      return renderShadeAuto(11228, 438);
    if (orientation == NodeOrientation.Slope_Inner_North_West)
      return renderShadeAuto(11228, 511);
  }
}

class NodeGrass2 extends Node {

  var variation = false;

  NodeGrass2(int row, int column, int z) : super(row, column, z) {
    variation = randomBool();
  }

  @override
  int get type => NodeType.Grass;

  @override
  void handleRender() {
    if (orientation == NodeOrientation.Solid)
      return renderShadeManual(variation ? 7158 : 9782);
    if (orientation == NodeOrientation.Slope_North)
      return renderShadeManual(7925);
    if (orientation == NodeOrientation.Slope_East)
      return renderShadeManual(7877);
    if (orientation == NodeOrientation.Slope_South)
      return renderShadeManual(7829);
    if (orientation == NodeOrientation.Slope_West)
      return renderShadeManual(7781);
    if (orientation == NodeOrientation.Slope_Inner_North_East)
      return renderShadeManual(9946); // correct
    if (orientation == NodeOrientation.Slope_Inner_South_East)
      return renderShadeManual(9898); // correct
    if (orientation == NodeOrientation.Slope_Inner_South_West)
      return renderShadeManual(10042);
    if (orientation == NodeOrientation.Slope_Inner_North_West)
      return renderShadeManual(9994); // correct
    if (orientation == NodeOrientation.Slope_Outer_North_East)
      return renderShadeManual(8440);
    if (orientation == NodeOrientation.Slope_Outer_South_East)
      return renderShadeManual(8392);
    if (orientation == NodeOrientation.Slope_Outer_South_West)
      return renderShadeManual(8536 );
    if (orientation == NodeOrientation.Slope_Outer_North_West)
      return renderShadeManual(8488);
  }
}

class NodeBauHausPlain extends Node {
  NodeBauHausPlain(int row, int column, int z) : super(row, column, z);

  @override
  int get type => NodeType.Bau_Haus_Plain;

  @override
  void handleRender() {
    if (orientation == NodeOrientation.Solid) {
       return renderShadeAuto(10738, 0);
    }
  }
}

class NodePlain extends Node {
  NodePlain(int row, int column, int z) : super(row, column, z);

  @override
  int get type => NodeType.Plain;

  @override
  void handleRender() {
    const srcX = 11277.0;

    if (orientation == NodeOrientation.Solid)
      return renderShadeAuto(srcX, srcYIndex0);
    if (orientation == NodeOrientation.Half_North) {
      dstX -= 17;
      dstY -= 17;
      renderShadeAuto(srcX, srcYIndex1);
      dstX += 17;
      dstY += 17;
      return;
    }
    if (orientation == NodeOrientation.Half_East) {
      dstX += 17;
      dstY -= 17;
      renderShadeAuto(srcX, srcYIndex2);
      dstX -= 17;
      dstY += 17;
      return;
    }
    if (orientation == NodeOrientation.Half_South)
      return renderShadeAuto(srcX, srcYIndex1);
    if (orientation == NodeOrientation.Half_West)
      return renderShadeAuto(srcX, srcYIndex2);
    if (orientation == NodeOrientation.Corner_Left)
      return renderShadeAuto(srcX, srcYIndex3);
    if (orientation == NodeOrientation.Corner_Bottom)
      return renderShadeAuto(srcX, srcYIndex4);
    if (orientation == NodeOrientation.Corner_Right)
      return renderShadeAuto(srcX, srcYIndex5);
    if (orientation == NodeOrientation.Corner_Top)
      return renderShadeAuto(srcX, srcYIndex6);
  }
}

class NodeWindow extends Node {
  NodeWindow(int row, int column, int z) : super(row, column, z);

  @override
  int get type => NodeType.Window;

  @override
  void handleRender() {
    const srcX = 11328.0;

    if (orientation == NodeOrientation.Half_North)
      return renderShadeAuto(srcX, srcYIndex0);
    if (orientation == NodeOrientation.Half_East)
      return renderShadeAuto(srcX, srcYIndex1);
    if (orientation == NodeOrientation.Half_South)
      return renderShadeAuto(srcX, srcYIndex2);
    if (orientation == NodeOrientation.Half_West)
      return renderShadeAuto(srcX, srcYIndex3);
  }
}

class NodeWoodenPlank extends Node {
  NodeWoodenPlank(int row, int column, int z) : super(row, column, z);

  @override
  int get type => NodeType.Wooden_Plank;

  @override
  bool get isWood => true;

  @override
  void handleRender() {
    const srcX = 7688.0;

    if (orientation == NodeOrientation.Half_West)
      return renderShadeAuto(srcX, srcYIndex1);

    if (orientation == NodeOrientation.Half_East){
      dstX += 17;
      dstY -= 17;
      renderShadeAuto(srcX, srcYIndex1);
      dstX -= 17;
      dstY += 17;
      return;
    }

    if (orientation == NodeOrientation.Half_South)
      return renderShadeAuto(srcX, srcYIndex2);

    if (orientation == NodeOrientation.Half_North){
      dstX -= 17;
      dstY -= 17;
      renderShadeAuto(srcX, srcYIndex2);
      dstX += 17;
      dstY += 17;
      return;
    }

    if (orientation == NodeOrientation.Corner_Top)
      return renderShadeAuto(srcX, srcYIndex3);
    if (orientation == NodeOrientation.Corner_Right)
      return renderShadeAuto(srcX, srcYIndex4);
    if (orientation == NodeOrientation.Corner_Bottom)
      return renderShadeAuto(srcX, srcYIndex5);
    if (orientation == NodeOrientation.Corner_Left)
      return renderShadeAuto(srcX, srcYIndex5);
    return renderShadeAuto(7688, 0);  }
}

class NodeSpawning extends Node {

  NodeSpawning(int row, int column, int z) : super(row, column, z);

  @override
  void handleRender() => renderStandardNode(8752, 0);

  @override
  int get type => NodeType.Respawning;
}
