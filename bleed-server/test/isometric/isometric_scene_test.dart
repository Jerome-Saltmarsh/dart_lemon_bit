


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

    final path = scene.findPath(scene.getNodeIndex(0, 2, 5), scene.getNodeIndex(0, 3, 1));

  });

  test('find-path-3D-down', () {
    final rows = 8;
    final columns = 8;
    final height = 2;
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
    scene.setNode(0, 3, 3, NodeType.Grass, NodeOrientation.Solid);
    scene.setNode(0, 2, 3, NodeType.Grass, NodeOrientation.Solid);

    final path = scene.findPath(scene.getNodeIndex(1, 2, 5), scene.getNodeIndex(0, 3, 1));

  });
}
