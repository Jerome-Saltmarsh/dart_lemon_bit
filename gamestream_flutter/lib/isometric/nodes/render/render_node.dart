
import 'package:bleed_common/library.dart';
import 'package:bleed_common/node_size.dart';
import 'package:gamestream_flutter/isometric/grid.dart';
import 'package:gamestream_flutter/isometric/nodes/render/render_atlas_standard_node.dart';
import 'package:gamestream_flutter/isometric/ui/maps/map_node_type_to_src.dart';

/// remove objects from the render layer to reduce garbage collection
void renderNodeAt({
  required int row,
  required int column,
  required int z,
}){
  assert (nodeIsInBound(z, row, column));
  final type = grid[z][row][column].type;
  if (type == NodeType.Empty) return;

  final orientation = grid[z][row][column].orientation;


  if (type == NodeType.Boulder) {
     return renderAtlasStandardNode(
         z: z,
         row: row,
         column: column,
         srcX: mapNodeTypeToSrcX(type),
         srcY: 0,
     );
  }

  if (type == NodeType.Boulder) {
    return renderAtlasStandardNode(
      z: z,
      row: row,
      column: column,
      srcX: 0,
      srcY: 0,
    );
  }
}

double projectX(int row, int column){
  return (row - column) * nodeSizeHalf;
}

double projectY(int row, int column, int z){
  return ((row + column) * nodeSizeHalf) - (z * nodeHeight);
}

