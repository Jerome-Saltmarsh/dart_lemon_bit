
import 'dart:typed_data';

import 'package:bleed_server/common/src.dart';
import 'package:bleed_server/isometric/src.dart';
import 'package:test/test.dart';

void main() {

  IsometricScene createScene({
    required int height,
    required int rows,
    required int columns,
  }) => IsometricScene(
      name: ' ',
      nodeTypes: Uint8List(height * rows * columns),
      nodeOrientations: Uint8List(height * rows * columns),
      gridHeight: height,
      gridRows: rows,
      gridColumns: columns,
      gameObjects: [],
      spawnPoints: Uint16List(0),
      spawnPointTypes: Uint16List(0),
      spawnPointsPlayers: Uint16List(0),
    );

  void testFindPath({
    required IsometricScene scene,
    required int start,
    required int end,
  }){

    var index = scene.findPath(start, end);
    expect(index, end, reason: 'end not found');
    expect(index, isNot(start), reason: 'no path was found');
    var length = 0;

    while (index != start){
      expect(length++, isNot(10000), reason: 'limit exceeded');
      expect(scene.path[index], isNot(IsometricScene.Not_Visited));
      expect(scene.path[index], isNot(index));
      index = scene.path[index];
    }

    expect(index, start);
    print('found: true, length: $length');
  }

  test('find-path-2D', () {
    final rows = 10;
    final columns = 10;
    final height = 2;

    final scene = createScene(height: height, rows: rows, columns: columns);

    assignGrassFloor(scene);
    scene.setNode(1, 2, 2, NodeType.Grass, NodeOrientation.Solid);
    scene.setNode(1, 3, 2, NodeType.Grass, NodeOrientation.Solid);

    testFindPath(
        scene: scene,
        start: scene.getIndex(1, 2, 5),
        end: scene.getIndex(1, 3, 1),
    );

  });

  test('find-path-3D-down', () {
    final rows = 10;
    final columns = 10;
    final height = 3;

    final scene = createScene(height: height, rows: rows, columns: columns);

    assignGrassFloor(scene);

    scene.setNode(1, 2, 2, NodeType.Grass, NodeOrientation.Solid);
    scene.setNode(1, 3, 2, NodeType.Grass, NodeOrientation.Solid);
    scene.setNode(1, 4, 2, NodeType.Grass, NodeOrientation.Solid);

    scene.setNode(1, 2, 3, NodeType.Grass, NodeOrientation.Solid);
    scene.setNode(1, 3, 3, NodeType.Grass, NodeOrientation.Solid);
    scene.setNode(1, 4, 3, NodeType.Grass, NodeOrientation.Solid);

    scene.setNode(1, 2, 4, NodeType.Grass, NodeOrientation.Solid);
    scene.setNode(1, 3, 4, NodeType.Grass, NodeOrientation.Slope_East);
    scene.setNode(1, 4, 4, NodeType.Grass, NodeOrientation.Solid);

    testFindPath(
        scene: scene,
        start: scene.getIndex(1, 8, 8),
        end: scene.getIndex(2, 3, 3),
    );
  });
}

void assignGrassFloor(IsometricScene scene) {
  for (var row = 0; row < scene.gridRows; row++){
    for (var column = 0; column < scene.gridColumns; column++){
      scene.setNode(0, row, column, NodeType.Grass, NodeOrientation.Solid);
    }
  }
}

