
import 'dart:math';

import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/isometric/grid.dart';
import 'package:gamestream_flutter/isometric/grid/state/wind.dart';
import 'package:gamestream_flutter/isometric/particles.dart';
import 'package:lemon_math/library.dart';

var _next = 0;

void updateGenerateLeaves(){
   if (_next-- > 0) return;
   _next = 50;
   gridForEachOfType(GridNodeType.Tree_Top, (z, row, column, type) {
      if (gridWind[z][row][column] == Wind.Calm) return;
      final chance = random.nextDouble();
      if (chance < 0.85) return;
      spawnParticleLeaf(x: row * tileSize, y: column * tileSize, z: z * tileSize, zv: 0, angle: pi, speed: 1);
   });
}