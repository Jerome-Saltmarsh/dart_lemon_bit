
import 'package:bleed_common/library.dart';
import 'package:bleed_common/node_orientation.dart';
import 'package:bleed_common/node_size.dart';
import 'package:gamestream_flutter/isometric/grid.dart';
import 'package:gamestream_flutter/isometric/grid_state.dart';
import 'package:gamestream_flutter/isometric/nodes/render/render_atlas_standard_node.dart';
import 'package:gamestream_flutter/isometric/ui/maps/map_node_type_to_src.dart';
import 'package:lemon_engine/render.dart';

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
  final nodeOrientation = gridNodeOrientations[index];

  final dstX = projectX(row, column);
  final dstY = projectY(row, column, z);

  switch (nodeType) {
    case NodeType.Grass:
      return renderNodeTypeGrass(x: dstX, y: dstY, orientation: nodeOrientation);
  }
}

void renderNodeTypeGrass({
  required double x,
  required double y,
  required int orientation,
}) {
  switch (orientation) {
    case NodeOrientation.Solid:
      return renderStandardNode(dstX: x, dstY: y, srcX: 7158, srcY: 0);
  }
}

void renderStandardNode({
  required double dstX,
  required double dstY,
  required double srcX,
  required double srcY,
  int color = 1,
}){
  const spriteWidth = 48.0;
  const spriteHeight = 72.0;
  // const spriteWidthHalf = spriteWidth * 0.5;
  const spriteHeightThird = 24.0;

  render(
     dstX: dstX,
     dstY: dstY,
     srcX:  srcX,
     srcY: srcY,
     srcWidth: spriteWidth,
     srcHeight: spriteHeight,
     anchorY: spriteHeightThird,
  );

  // engineRenderSetSrc(
  //     x: srcX,
  //     y: srcY,
  //     width: spriteWidth,
  //     height: spriteHeight,
  // );
  //
  // engineRenderSetDstScale1Rotation0(
  //     x: dstX,
  //     y: dstY,
  //     anchorX: spriteWidthHalf,
  //     anchorY: spriteHeightThird,
  // );
  //
  // engineRenderIncrementBufferIndex();
}

double projectX(int row, int column){
  return (row - column) * nodeSizeHalf;
}

double projectY(int row, int column, int z){
  return ((row + column) * nodeSizeHalf) - (z * nodeHeight);
}

