
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

  switch (nodeType) {
    case NodeType.Grass:
      // return renderNodeTypeGrass(z, row, column, nodeOrientation);
      return;
  }
}

void renderNodeTypeGrass(int z, int row, int column, int orientation) {
  switch (orientation) {
    case NodeOrientation.Solid:
      break;
  }
}

void renderStandardNode({
  required int z,
  required int row,
  required int column,
  required double srcX,
  required double srcY,
  int color = 0,
}){
  const spriteWidth = 48.0;
  const spriteHeight = 72.0;
  const spriteWidthHalf = spriteWidth * 0.5;
  const spriteHeightThird = 24.0;

  engineRenderSetSrc(
      x: srcX,
      y: srcY,
      width: spriteWidth,
      height: spriteHeight,
  );

  engineRenderSetDstScale1Rotation0(
      x: projectX(row, column),
      y: projectY(row, column, z),
      anchorX: spriteWidthHalf,
      anchorY: spriteHeightThird,
  );

  engineRenderIncrementBufferIndex();
}

double projectX(int row, int column){
  return (row - column) * nodeSizeHalf;
}

double projectY(int row, int column, int z){
  return ((row + column) * nodeSizeHalf) - (z * nodeHeight);
}

