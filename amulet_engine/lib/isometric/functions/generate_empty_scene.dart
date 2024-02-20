import 'dart:typed_data';

import 'package:amulet_engine/common/src.dart';
import 'package:amulet_engine/isometric/classes/scene.dart';


Scene generateEmptyScene({
  int height = 8,
  int rows = 50,
  int columns = 50,
  String name = '',
}) {
  final area = rows * columns;
  final total = height * area;
  final nodeTypes = Uint8List(total);
  final nodeOrientations = Uint8List(total);
  final variations = Uint8List(total);

  for (var i = 0; i < area; i++) {
    nodeTypes[i] = NodeType.Grass;
    nodeOrientations[i] = NodeOrientation.Solid;
  }

  return Scene(
    name: name,
    gameObjects: [],
    height: height,
    columns: columns,
    rows: rows,
    nodeTypes: nodeTypes,
    nodeOrientations: nodeOrientations,
    marks: [],
    variations: variations,
  );
}
