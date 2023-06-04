
import 'dart:typed_data';

import 'package:bleed_server/gamestream.dart';
import 'package:bleed_server/src/games/isometric/isometric_scene.dart';

IsometricScene generateEmptyScene({int height = 8, int rows = 50, int columns = 50}){
  final area = rows * columns;
  final total = height * area;
  final nodeTypes = Uint8List(total);
  final nodeOrientations = Uint8List(total);

  for (var i = 0; i < area; i++){
     nodeTypes[i] = NodeType.Grass;
     nodeOrientations[i] = NodeOrientation.Solid;
  }

  return IsometricScene(
    name: '',
    gameObjects: [],
    gridHeight: height,
    gridColumns: columns,
    gridRows: rows,
    nodeTypes: nodeTypes,
    nodeOrientations: nodeOrientations,
    spawnPoints: Uint16List(0),
    spawnPointTypes: Uint16List(0),
    spawnPointsPlayers:Uint16List(0),
  );
}