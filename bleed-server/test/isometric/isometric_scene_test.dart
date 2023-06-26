
import 'dart:typed_data';

import 'package:bleed_server/common/src.dart';
import 'package:bleed_server/isometric/src.dart';
import 'package:test/test.dart';

void main() {
  test('find-path-2D', () {
    final rows = 8;
    final columns = 8;
    final height = 1;
    final volume = rows * columns * height;

    final scene = IsometricScene(
      name: ' ',
      nodeTypes: Uint8List(volume),
      nodeOrientations: Uint8List(volume),
      gridHeight: height,
      gridRows: rows,
      gridColumns: columns,
      gameObjects: [],
      spawnPoints: Uint16List(0),
      spawnPointTypes: Uint16List(0),
      spawnPointsPlayers: Uint16List(0),
    );

    scene.setNode(0, 2, 2, NodeType.Grass, NodeOrientation.Solid);
    scene.setNode(0, 3, 2, NodeType.Grass, NodeOrientation.Solid);

    final path = scene.findPath(scene.getIndex(0, 2, 5), scene.getIndex(0, 3, 1));

  });

  test('find-path-3D-down', () {
    final rows = 10;
    final columns = 10;
    final height = 3;
    final volume = rows * columns * height;

    final scene = IsometricScene(
      name: ' ',
      nodeTypes: Uint8List(volume),
      nodeOrientations: Uint8List(volume),
      gridHeight: height,
      gridRows: rows,
      gridColumns: columns,
      gameObjects: [],
      spawnPoints: Uint16List(0),
      spawnPointTypes: Uint16List(0),
      spawnPointsPlayers: Uint16List(0),
    );

    for (var row = 0; row < rows; row++){
      for (var column = 0; column < columns; column++){
        scene.setNode(0, row, column, NodeType.Grass, NodeOrientation.Solid);
      }
    }

    scene.setNode(1, 2, 2, NodeType.Grass, NodeOrientation.Solid);
    scene.setNode(1, 3, 2, NodeType.Grass, NodeOrientation.Solid);
    scene.setNode(1, 4, 2, NodeType.Grass, NodeOrientation.Solid);

    scene.setNode(1, 2, 3, NodeType.Grass, NodeOrientation.Solid);
    scene.setNode(1, 3, 3, NodeType.Grass, NodeOrientation.Solid);
    scene.setNode(1, 4, 3, NodeType.Grass, NodeOrientation.Slope_North);

    scene.setNode(1, 2, 4, NodeType.Grass, NodeOrientation.Solid);
    scene.setNode(1, 3, 4, NodeType.Grass, NodeOrientation.Solid);
    scene.setNode(1, 4, 4, NodeType.Grass, NodeOrientation.Solid);

    final start = scene.getIndex(1, 2, 9);
    final end = scene.getIndex(2, 3, 3);

    var index = scene.findPath(start, end);

    expect(index, isNot(start));

    var length = 0;

    while (index != start){
      expect(length++, isNot(1000));
      index = scene.path[index];
    }

    assert (index == start);

    print('found: true, length: $length');
  });
}
