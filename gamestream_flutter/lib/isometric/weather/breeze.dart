import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/game.dart';

double get windLineRenderX {
  var windLineColumn = 0;
  var windLineRow = 0;
  if (Game.windLine < Game.nodesTotalRows){
    windLineColumn = 0;
    windLineRow = Game.nodesTotalRows - Game.windLine - 1;
  } else {
    windLineRow = 0;
    windLineColumn = Game.windLine - Game.nodesTotalRows + 1;
  }
  return (windLineRow - windLineColumn) * tileSizeHalf;
}
