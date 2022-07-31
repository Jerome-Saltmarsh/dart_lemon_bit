import 'package:bleed_common/tile_size.dart';
import 'package:gamestream_flutter/isometric/grid.dart';
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

  if (windLine >= gridTotalColumns + gridTotalRows) {
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
  if (windLine < gridTotalRows){
    windLineColumn = 0;
    windLineRow = gridTotalRows - windLine - 1;
  } else {
    windLineRow = 0;
    windLineColumn = windLine - gridTotalRows + 1;
  }
  return (windLineRow - windLineColumn) * tileSizeHalf;
}

void applyGridLine(int index, int strength){
  if (index < 0) return;
  var windLineRow = 0;
  var windLineColumn = 0;
  if (index < gridTotalRows){
    windLineColumn = 0;
    windLineRow = gridTotalRows - index - 1;
  } else {
    windLineRow = 0;
    windLineColumn = index - gridTotalRows + 1;
  }
  while (windLineRow < gridTotalRows && windLineColumn < gridTotalColumns){
    for (var windLineZ = 0; windLineZ < gridTotalZ; windLineZ++){
      grid[windLineZ][windLineRow][windLineColumn].wind += strength;
    }
    windLineRow++;
    windLineColumn++;
  }
}