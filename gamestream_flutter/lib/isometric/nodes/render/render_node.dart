
import 'package:bleed_common/library.dart';
import 'package:bleed_common/node_orientation.dart';
import 'package:bleed_common/node_size.dart';
import 'package:gamestream_flutter/isometric/animation_frame.dart';
import 'package:gamestream_flutter/isometric/constants/color_pitch_black.dart';
import 'package:gamestream_flutter/isometric/grid.dart';
import 'package:gamestream_flutter/isometric/grid_state.dart';
import 'package:gamestream_flutter/isometric/nodes/render/atlas_src.dart';
import 'package:gamestream_flutter/isometric/render/render_torch.dart';
import 'package:gamestream_flutter/isometric/watches/raining.dart';
import 'package:gamestream_flutter/isometric/watches/torches_ignited.dart';
import 'package:lemon_engine/render.dart';

const spriteWidth = 48.0;
const spriteHeight = 72.0;



/// remove objects from the render layer to reduce garbage collection
void renderNodeAt({
  required int row,
  required int column,
  required int z,
}){
  final index = (z * gridTotalArea) + (row * gridTotalColumns) + column;

  if (index >= gridNodeTotal) return;

  if (!gridNodeVisible[index]) {
    gridNodeVisible[index] = true;
    return;
  }

  final nodeType = gridNodeTypes[index];
  if (nodeType == NodeType.Empty) return;

  final dstX = projectX(row, column);
  final dstY = projectY(row, column, z);

  switch (nodeType) {
    case NodeType.Grass:
      return renderNodeTypeGrass(
          x: dstX,
          y: dstY,
          orientation: gridNodeOrientations[index],
          shade: gridNodeShade[index],
      );
    case NodeType.Brick_2:
      return renderNodeTypeBrick(
        x: dstX,
        y: dstY,
        orientation: gridNodeOrientations[index],
        shade: gridNodeShade[index],
      );
    case NodeType.Torch:
      if (!torchesIgnited.value) {
        return renderTorchOff(dstX, dstY);
      }
      if (gridNodeWind[index] == Wind.Calm){
        return renderTorchOn(dstX, dstY);
      }
      return renderTorchOnWindy(dstX, dstY);
    case NodeType.Water:
      return render(
        dstX: dstX,
        dstY: dstY + animationFrameWaterHeight,
        srcX: 7976,
        srcY: (((animationFrameWater + ((row + column) * 3)) % 10) * 72.0),
        srcWidth: 48,
        srcHeight: 72,
        anchorY: 0.3334,
        color: colorShades[gridNodeShade[index]],
      );
    case NodeType.Tree_Bottom:
      return render(
        dstX: dstX,
        dstY: dstY,
        srcX: 1478,
        srcY: 0,
        srcWidth: 62.0,
        srcHeight: 74.0,
        anchorY: 0.5,
        color: colorShades[gridNodeShade[index]],
      );
    case NodeType.Tree_Top:
      final f = raining.value ? animationFrame % 4 : -1;
      var shift = treeAnimation[((row - column) + animationFrame) % treeAnimation.length] * gridNodeWind[index];
      final nodeBelowShade = gridNodeShade[gridNodeIndexZRC(z > 0 ? z - 1 : z, row, column)];

      return render(
        dstX: dstX + (shift * 0.5),
        dstY: dstY,
        srcX: 1541,
        srcY: 74.0 + (74 * f),
        srcWidth: 62.0,
        srcHeight: 74.0,
        anchorY: 0.5,
        color: colorShades[nodeBelowShade],
      );
  }
}

void renderNodeTypeGrass({
  required double x,
  required double y,
  required int orientation,
  required int shade,
}) {
  switch (orientation) {
    case NodeOrientation.Solid:
      return renderStandardNode(
          dstX: x,
          dstY: y,
          srcX: AtlasSrc.Node_Grass,
          srcY: spriteHeight * shade,
      );
  }
}

void renderNodeTypeBrick({
  required double x,
  required double y,
  required int orientation,
  required int shade,
}) {
  switch (orientation) {
    case NodeOrientation.Solid:
      return renderStandardNode(
        dstX: x,
        dstY: y,
        srcX: AtlasSrc.Node_Brick,
        srcY: spriteHeight * shade,
      );
    case NodeOrientation.Slope_North:
      return renderStandardNode(
        dstX: x,
        dstY: y,
        srcX: AtlasSrc.Node_Brick_Slope_North,
        srcY: spriteHeight * shade,
      );
    case NodeOrientation.Slope_East:
      return renderStandardNode(
        dstX: x,
        dstY: y,
        srcX: AtlasSrc.Node_Brick_Slope_East,
        srcY: spriteHeight * shade,
      );
    case NodeOrientation.Slope_South:
      return renderStandardNode(
        dstX: x,
        dstY: y,
        srcX: AtlasSrc.Node_Brick_Slope_South,
        srcY: spriteHeight * shade,
      );
    case NodeOrientation.Slope_West:
      return renderStandardNode(
        dstX: x,
        dstY: y,
        srcX: AtlasSrc.Node_Brick_Slope_West,
        srcY: spriteHeight * shade,
      );
    case NodeOrientation.Half_North:
      return renderStandardNode(
        dstX: x - 17,
        dstY: y - 17,
        srcX: AtlasSrc.Node_Brick_Half_North,
        srcY: spriteHeight * shade,
      );
    case NodeOrientation.Half_East:
      return renderStandardNode(
        dstX: x + 17,
        dstY: y - 17,
        srcX: AtlasSrc.Node_Brick_Half_East,
        srcY: spriteHeight * shade,
      );
    case NodeOrientation.Half_South:
      return renderStandardNode(
        dstX: x,
        dstY: y,
        srcX: AtlasSrc.Node_Brick_Half_South,
        srcY: spriteHeight * shade,
      );
    case NodeOrientation.Half_West:
      return renderStandardNode(
        dstX: x,
        dstY: y,
        srcX: AtlasSrc.Node_Brick_Half_West,
        srcY: spriteHeight * shade,
      );
  }
}

void renderStandardNode({
  required double dstX,
  required double dstY,
  required double srcX,
  required double srcY,
  int color = 1,
}){
  render(
     dstX: dstX,
     dstY: dstY,
     srcX:  srcX,
     srcY: srcY,
     srcWidth: spriteWidth,
     srcHeight: spriteHeight,
     anchorY: 0.33,
  );
}

double projectX(int row, int column){
  return (row - column) * nodeSizeHalf;
}

double projectY(int row, int column, int z){
  return ((row + column) * nodeSizeHalf) - (z * nodeHeight);
}

