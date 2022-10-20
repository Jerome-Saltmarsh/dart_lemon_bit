import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/game_state.dart';

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
