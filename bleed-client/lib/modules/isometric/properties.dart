import 'package:bleed_client/common/Tile.dart';
import 'package:bleed_client/common/enums/Shade.dart';
import 'package:bleed_client/modules/isometric/enums.dart';
import 'package:bleed_client/modules/isometric/state.dart';
import 'package:bleed_client/modules/modules.dart';
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

  int getShadeAtPosition(double x, double y){
    return getShade(getRow(x, y), getColumn(x, y));
  }

  int getShade(int row, int column){
    if (row < 0) return Shade.Very_Dark;
    if (column < 0) return Shade.Very_Dark;
    if (row >= modules.isometric.state.totalRows.value){
      return Shade.Very_Dark;
    }
    if (column >= modules.isometric.state.totalColumns.value){
      return Shade.Very_Dark;
    }
    return modules.isometric.state.dynamicShading[row][column];
  }

  bool inDarkness(double x, double y){
    return isometric.properties.getShadeAtPosition(x, y) >= Shade.Very_Dark;
  }

  bool get boundaryAtMouse => tileAtMouse == Tile.Boundary;

}