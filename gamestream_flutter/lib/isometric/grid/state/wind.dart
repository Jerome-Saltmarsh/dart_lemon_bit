import 'package:bleed_common/wind.dart';
import 'package:gamestream_flutter/isometric/classes/vector3.dart';
import 'package:gamestream_flutter/isometric/events/on_wind_changed.dart';
import 'package:gamestream_flutter/isometric/grid.dart';
import 'package:lemon_watch/watch.dart';
import 'package:lemon_math/library.dart';

final gridWind = <List<List<int>>>[];

final windAmbient = Watch(Wind.Calm, onChanged: onWindChanged);

void gridWindResetToAmbient(){
  _ensureGridCorrectMetrics();
  final ambientIndex = windAmbient.value.index;
  gridForEachNode((z, row, column){
    gridWind[z][row][column] = ambientIndex;
  });
}

void _ensureGridCorrectMetrics(){
  if (gridWind.length == gridTotalZ &&
      gridWind.isNotEmpty &&
      gridWind[0].isNotEmpty &&
      gridWind[0].length == gridTotalRows &&
      gridWind[0][0].isNotEmpty &&
      gridWind[0][0].length == gridTotalColumns
  ) return;

  gridWind.clear();
  final value = windAmbient.value.index;
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

final windParticles = <WindParticle>[
  // WindParticle(),
  // WindParticle(),
];



class WindParticle extends Vector3 {

  var enabled = true;
  var speed = 6;

  void update(){
    // if (!enabled) return;
    x -= speed;
    y += speed;

    if (x < 0 || y >= gridColumnLength) {

      final i = randomInt(0, gridTotalRows + gridTotalColumns);
      if (i < gridTotalRows){
        indexRow = i;
        indexColumn = 1;
      } else {
        indexRow = gridTotalRows - 1;
        indexColumn = (i - gridTotalColumns);
      }
    }

    gridWind[1][indexRow][indexColumn]++;

    for (var z = 0; z < 3; z++){
       for (var r = 0; r < 3; r++) {
         for (var c = 0; c < 3; c++){

         }
       }
    }
  }

  WindParticle() {
    indexZ = 1;
  }
}

