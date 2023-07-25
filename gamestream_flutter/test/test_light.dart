
import 'dart:typed_data';

import 'package:gamestream_flutter/common.dart';
import 'package:gamestream_flutter/gamestream/isometric/isometric.dart';
import 'package:test/test.dart';

void main() {

  test('light', () {

    final rows = 10;
    final columns = 10;
    final height = 10;
    final area = rows * columns;
    final volume = area * height;
    final types = Uint8List(volume);
    final orientations = Uint8List(volume);
    final alphas = Uint8ClampedList(volume);
    final scene = Isometric();

    scene.hsvAlphas = alphas;
    scene.nodeTypes = types;
    scene.nodeOrientations = orientations;
    scene.totalColumns = columns;
    scene.totalRows = rows;
    scene.totalZ = height;
    scene.totalNodes = volume;
    scene.area = area;
    scene.ambientStack = Uint16List(10000);
    scene.refreshGridMetrics();

    for (var row = 0; row < rows; row++){
      for (var column = 0; column < columns; column++){
        final index = scene.getIndexZRC(0, row, column);
        types[index] = NodeType.Grass;
        orientations[index] = NodeOrientation.Solid;
      }
    }

    final lightRow = 5;
    final lightColumn = 5;
    final lightZ = 1;
    final lightIndex = scene.getIndexZRC(lightZ, lightRow, lightColumn);

    final wallColumn = lightColumn - 2;

    for (var wallZ = 0; wallZ < height; wallZ++){
      for (var wallRow = 0; wallRow < rows; wallRow++){
        final wallIndex = scene.getIndexZRC(wallZ, wallRow, wallColumn);
        types[wallIndex] = NodeType.Brick;
        orientations[wallIndex] = NodeOrientation.Solid;
      }
    }

    // scene.shootLightTreeAmbient(
    //   row: lightRow,
    //   column: lightColumn,
    //   z: lightZ,
    //   interpolation: 2,
    //   alpha: 0,
    //   vx: -1,
    //   vz: 1,
    //   vy: 1,
    // );
    scene.shootLightTreeAmbient(
      row: lightRow,
      column: lightColumn,
      z: lightZ,
      brightness: 2,
      alpha: 0,
      vx: -1,
      vz: 1,
      vy: -1,
    );
    // scene.emitLightAmbientShadows(index: lightIndex, alpha: 1);
  });
}
