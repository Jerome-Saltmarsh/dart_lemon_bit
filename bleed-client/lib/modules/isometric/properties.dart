import 'package:bleed_client/common/Tile.dart';
import 'package:bleed_client/common/enums/Shade.dart';
import 'package:bleed_client/modules/isometric/enums.dart';
import 'package:bleed_client/modules/isometric/scope.dart';
import 'package:bleed_client/modules/modules.dart';
import 'package:lemon_math/Vector2.dart';

import 'utilities.dart';

class IsometricProperties with IsometricScope {

  bool get dayTime => state.ambient.value.index == Shade.Bright.index;

  Tile get tileAtMouse {
    if (mouseRow < 0) return Tile.Boundary;
    if (mouseColumn < 0) return Tile.Boundary;
    if (mouseRow >= state.totalRows.value) return Tile.Boundary;
    if (mouseColumn >= state.totalColumns.value) return Tile.Boundary;
    return state.tiles[mouseRow][mouseColumn];
  }

  Shade get currentPhaseShade {
    return modules.isometric.map.phaseToShade(phase);
  }

  Phase get phase {
     return modules.isometric.map.hourToPhase(modules.isometric.state.hour.value);
  }

  Vector2 get mapCenter {
    final row = state.totalRows.value ~/ 2;
    final column = state.totalColumns.value ~/ 2;
    return getTilePosition(row: row, column: column);
  }

  int get totalActiveParticles {
    int totalParticles = 0;
    for (int i = 0; i < isometric.state.particles.length; i++) {
      if (isometric.state.particles[i].active) {
        totalParticles++;
      }
    }
    return totalParticles;
  }
}