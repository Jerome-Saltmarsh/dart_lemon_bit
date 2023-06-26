


import 'dart:typed_data';

import 'package:bleed_server/isometric/src.dart';
import 'package:test/test.dart';

void main() {
  test('node test', () {
    final rows = 10;
    final columns = 12;
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

    final indexA = scene.getNodeIndex(0, 2, 5);
    final indexB = scene.getNodeIndex(0, 2, 6);
    expect(indexA + 1, indexB);


    expect(scene.getRow(indexA), 2);
    expect(scene.getColumn(indexA), 5);
    expect(scene.getZ(indexA), 0);
  });
}
