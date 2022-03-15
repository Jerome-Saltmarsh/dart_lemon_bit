import 'package:gamestream_flutter/common/Tile.dart';
import 'package:gamestream_flutter/common/enums/Shade.dart';
import 'package:gamestream_flutter/modules/isometric/enums.dart';
import 'package:gamestream_flutter/modules/isometric/state.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:lemon_math/Vector2.dart';

import 'utilities.dart';

class IsometricProperties {
  final IsometricState state;
  IsometricProperties(this.state);

  bool get dayTime => state.ambient.value == Shade.Bright;

  Tile get tileAtMouse {
    if (mouseRow < 0) return Tile.Boundary;
    if (mouseColumn < 0) return Tile.Boundary;
    if (mouseRow >= state.totalRows.value) return Tile.Boundary;
    if (mouseColumn >= state.totalColumns.value) return Tile.Boundary;
    return state.tiles[mouseRow][mouseColumn];
  }

  int get currentPhaseShade {
    return modules.isometric.map.phaseToShade(phase);
  }

  String get currentAmbientShadeName {
    return shadeName(currentPhaseShade);
  }

  Phase get phase {
     return modules.isometric.map.hourToPhase(state.hours.value);
  }

  Vector2 get mapCenter {
    final row = state.totalRows.value ~/ 2;
    final column = state.totalColumns.value ~/ 2;
    return getTilePosition(row: row, column: column);
  }

  int get totalActiveParticles {
    var totalParticles = 0;
    final particles = isometric.state.particles;
    final length = particles.length;
    for (var i = 0; i < length; i++) {
      if (!particles[i].active) continue;
      totalParticles++;
    }
    return totalParticles;
  }

  bool get boundaryAtMouse => tileAtMouse == Tile.Boundary;
}