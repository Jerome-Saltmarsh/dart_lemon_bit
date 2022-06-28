import 'package:bleed_common/tile_size.dart';
import 'package:gamestream_flutter/isometric/classes/vector3.dart';
import 'package:gamestream_flutter/isometric/events/on_wind_changed.dart';
import 'package:gamestream_flutter/isometric/game_action.dart';
import 'package:gamestream_flutter/isometric/grid.dart';
import 'package:lemon_watch/watch.dart';
import 'package:lemon_math/library.dart';

final gridWind = <List<List<int>>>[];

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

final windParticles = <WindParticle>[
  // WindParticle(),
  // WindParticle(),
];


var windLine = 0;


var move = true;

void updateWindParticles(){
   // for (final windParticle in windParticles){
   //    windParticle.update();
   // }
   updateWindLine();
}

void updateWindLine() {
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
        gridWind[windLineZ][windLineRow][windLineColumn] += strength;
      }
      windLineRow++;
      windLineColumn++;
  }
}

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

void actionBreeze() {
  windAmbient.value++;
  runAction(duration: 120, action: endBreeze);
}

void endBreeze(){
  if (windAmbient.value <= Wind.Calm) return;
  windAmbient.value--;
}
