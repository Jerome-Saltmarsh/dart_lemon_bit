

import 'package:bleed_common/node_type.dart';
import 'package:gamestream_flutter/isometric/classes/node.dart';
import 'package:gamestream_flutter/isometric/grid.dart';

void rainOff(){
  gridForEach(
      where: NodeType.isRain,
      apply: assignEmpty,
  );
}


void assignEmpty(int z, int row, int column, int type){
  grid[z][row][column] = Node.empty;
}