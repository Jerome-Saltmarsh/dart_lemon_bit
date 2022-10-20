
import 'package:gamestream_flutter/game_state.dart';

void setNodeType(int z, int row, int column, int type){
  if (z < 0)
    return;
  if (row < 0)
    return;
  if (column < 0)
    return;
  if (z >= GameState.nodesTotalZ)
    return;
  if (row >= GameState.nodesTotalRows)
    return;
  if (column >= GameState.nodesTotalColumns)
    return;

  GameState.nodesType[GameState.getNodeIndexZRC(z, row, column)] = type;
}