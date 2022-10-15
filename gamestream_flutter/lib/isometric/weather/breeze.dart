import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/game_state.dart';
import 'package:gamestream_flutter/isometric/grid.dart';
import 'package:gamestream_flutter/isometric/nodes.dart';
import 'package:lemon_watch/watch.dart';

final weatherBreeze = Watch(false);

var windLine = 0;
var move = true;

void updateWindLine() {
  if (!weatherBreeze.value) return;

  move = !move;
  if (move){
    windLine++;
  }

  if (windLine >= nodesTotalColumns + nodesTotalRows) {
    windLine = 0;
  }

  applyGridLine(windLine, 1);
  applyGridLine(windLine - 1, 1);
  applyGridLine(windLine - 2, 1);
  applyGridLine(windLine - 3, 2);
  applyGridLine(windLine - 4, 2);
  applyGridLine(windLine - 5, 2);
  applyGridLine(windLine - 6, 2);
  applyGridLine(windLine - 7, 1);
  applyGridLine(windLine - 8, 1);
  applyGridLine(windLine - 9, 1);
  applyGridLine(windLine - 10, 1);
  applyGridLine(windLine - 11, 1);
  applyGridLine(windLine - 12, 1);
}

double get windLineRenderX {
  var windLineColumn = 0;
  var windLineRow = 0;
  if (windLine < nodesTotalRows){
    windLineColumn = 0;
    windLineRow = nodesTotalRows - windLine - 1;
  } else {
    windLineRow = 0;
    windLineColumn = windLine - nodesTotalRows + 1;
  }
  return (windLineRow - windLineColumn) * tileSizeHalf;
}

void applyGridLine(int index, int strength){
  if (index < 0) return;
  var windLineRow = 0;
  var windLineColumn = 0;
  if (index < nodesTotalRows){
    windLineColumn = 0;
    windLineRow = nodesTotalRows - index - 1;
  } else {
    windLineRow = 0;
    windLineColumn = index - nodesTotalRows + 1;
  }
  while (windLineRow < nodesTotalRows && windLineColumn < nodesTotalColumns){
    for (var windLineZ = 0; windLineZ < nodesTotalZ; windLineZ++){
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