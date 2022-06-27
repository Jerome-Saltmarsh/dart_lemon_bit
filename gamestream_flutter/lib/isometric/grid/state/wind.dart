import 'package:gamestream_flutter/isometric/events/on_wind_changed.dart';
import 'package:gamestream_flutter/isometric/grid.dart';
import 'package:lemon_watch/watch.dart';

final gridWind = <List<List<int>>>[];
var windIsCalm = true;

final windAmbient = Watch(Wind.Calm, onChanged: onWindChanged);

set windIndex(int value){
  assert(value >= 0);
  windAmbient.value = value % 3;
}

void toggleWind(){
  windAmbient.value = (windAmbient.value + 1) % 3;
}

void gridWindResetToAmbient(){
  _ensureGridCorrectMetrics();
  final ambientValue = windAmbient.value;
  gridForEachNode((z, row, column){
    gridWind[z][row][column] = ambientValue;
  });
}

void _ensureGridCorrectMetrics(){
  if (gridWind.length == gridTotalZ &&
      gridWind[0].length == gridTotalRows &&
      gridWind[0][0].length == gridTotalColumns
  ) return;
  gridWind.clear();
  final value = windAmbient.value;
  for (var indexZ = 0; indexZ < gridTotalZ; indexZ++){
    final z = <List<int>>[];
    gridWind.add(z);
    for (var indexRow = 0; indexRow < gridTotalRows; indexRow++){
      final row = <int>[];
      z.add(row);
      for (var indexColumn = 0; indexColumn < gridTotalColumns; indexColumn++){
        row.add(value);
      }
    }
  }
}

class Wind {
  static const Calm = 0;
  static const Gentle = 1;
  static const Strong = 2;
}