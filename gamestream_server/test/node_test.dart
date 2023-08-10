


import 'dart:typed_data';

import 'package:gamestream_server/isometric/src.dart';
import 'package:test/test.dart';

void main() {
  test('node test', () {
    final rows = 10;
    final columns = 12;
    final height = 3;
    final volume = rows * columns * height;

    final scene = Scene(
        name: ' ',
        types: Uint8List(volume),
        shapes: Uint8List(volume),
        height: height,
        rows: rows,
        columns: columns,
        gameObjects: [],
        spawnPoints: Uint16List(0),
        spawnPointTypes: Uint16List(0),
        spawnPointsPlayers: Uint16List(0),
    );

    final indexA = scene.getIndex(0, 2, 5);
    final indexB = scene.getIndex(0, 2, 6);
    expect(indexA + 1, indexB);


    expect(scene.getRow(indexA), 2);
    expect(scene.getColumn(indexA), 5);
    expect(scene.getZ(indexA), 0);
  });
}
