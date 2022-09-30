
import 'package:bleed_common/library.dart';
import 'package:bleed_common/node_orientation.dart';
import 'package:bleed_common/node_size.dart';
import 'package:gamestream_flutter/isometric/grid.dart';
import 'package:gamestream_flutter/isometric/grid_state.dart';
import 'package:lemon_engine/render.dart';

const spriteWidth = 48.0;
const spriteHeight = 72.0;

const atlasSrcX_Node_Grass = 7158.0;
const atlasSrcX_Node_Brick = 11377.0;

/// remove objects from the render layer to reduce garbage collection
void renderNodeAt({
  required int row,
  required int column,
  required int z,
}){
  final index = (z * gridTotalRows * gridTotalColumns) + (row * gridTotalColumns) + column;

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
          srcX: atlasSrcX_Node_Grass,
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
        srcX: atlasSrcX_Node_Brick,
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

