import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/game_state.dart';
import 'package:gamestream_flutter/isometric/nodes.dart';
import 'package:lemon_watch/watch.dart';




double get windLineRenderX {
  var windLineColumn = 0;
  var windLineRow = 0;
  if (GameState.windLine < GameState.nodesTotalRows){
    windLineColumn = 0;
    windLineRow = GameState.nodesTotalRows - GameState.windLine - 1;
  } else {
    windLineRow = 0;
    windLineColumn = GameState.windLine - GameState.nodesTotalRows + 1;
  }
  return (windLineRow - windLineColumn) * tileSizeHalf;
}

void applyGridLine(int index, int strength){
  if (index < 0) return;
  var windLineRow = 0;
  var windLineColumn = 0;
  if (index < GameState.nodesTotalRows){
    windLineColumn = 0;
    windLineRow = GameState.nodesTotalRows - index - 1;
  } else {
    windLineRow = 0;
    windLineColumn = index - GameState.nodesTotalRows + 1;
  }
  while (windLineRow < GameState.nodesTotalRows && windLineColumn < GameState.nodesTotalColumns){
    for (var windLineZ = 0; windLineZ < GameState.nodesTotalZ; windLineZ++){
      final index = getNodeIndexZRC(windLineZ, windLineRow, windLineColumn);
      GameState.nodesWind[index] += strength;
      // TODO refactor
      if (GameState.nodesWind[index] > windIndexStrong){
        GameState.nodesWind[index] = windIndexStrong;
      }
    }
    windLineRow++;
    windLineColumn++;
  }
}