
import 'package:gamestream_flutter/game.dart';

void setGridType(int z, int row, int column, int type){
  if (z < 0)
    return;
  if (row < 0)
    return;
  if (column < 0)
    return;
  if (z >= Game.nodesTotalZ)
    return;
  if (row >= Game.nodesTotalRows)
    return;
  if (column >= Game.nodesTotalColumns)
    return;

  Game.nodesType[Game.getNodeIndexZRC(z, row, column)] = type;
}