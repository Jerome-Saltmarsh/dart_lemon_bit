
import 'dart:convert';
import 'dart:typed_data';

import 'package:typedef/json.dart';

import '../classes/gameobject.dart';
import '../classes/library.dart';
import '../common/game_object_type.dart';
import '../common/node_type.dart';

Scene convertStringToScene(String value, String name) =>
  convertJsonToScene(jsonDecode(value), name);

Scene convertJsonToScene(Json json, String name) {
  final height = json.getInt('grid-z');
  final rows = json.getInt('grid-rows');
  final columns = json.getInt('grid-columns');
  final List jsonGameObjects = json['gameobjects'] ?? [];

  final gridNode = convertFlatGridToNodeGrid(json['grid'], height, rows, columns);

  return Scene(
    name: name,
    nodeOrientations: gridNode.nodeOrientations,
    nodeTypes: gridNode.nodeTypes,
    gridRows: rows,
    gridHeight: height,
    gridColumns: columns,
    gameObjects: jsonGameObjects.map(convertDynamicToGameObject).toList(),
  );
}

GameObject convertDynamicToGameObject(dynamic value) {
  if (value is Json) return convertJsonToGameObject(value);
  throw Exception("Cannot convert value to gameobject");
}

int? tryGetInt(Json json, String fieldName){
  final value = json[fieldName];
  if (value == null) return null;
  if (value is int) return value;
  if (value is String){
    return int.tryParse(value);
  }
  return null;
}

double? tryGetDouble(Json json, String fieldName){
  final value = json[fieldName];
  if (value == null) return null;
  if (value is double) return value;
  if (value is String){
    return double.tryParse(value);
  }
  return null;
}

const teamGood = 1;
const teamBad = 1;
const teamDefault = teamBad;

GameObject convertJsonToGameObject(Json json) {
    final type = json.getInt('type');
    final x = json.getDouble('x');
    final y = json.getDouble('y');
    final z = json.getDouble('z');

    if (GameObjectType.isStatic(type)) {
      return GameObjectStatic(
        x: x,
        y: y,
        z: z,
        type: type,
      );
    }

    switch (type) {
      case GameObjectType.Chicken:
        return GameObjectChicken(
          x: x,
          y: y,
          z: z,
        );
      case GameObjectType.Jellyfish:
        return GameObjectJellyfish(
          x: x,
          y: y,
          z: z,
        );
      case GameObjectType.Jellyfish_Red:
        return GameObjectJellyfishRed(
          x: x,
          y: y,
          z: z,
        );
      case GameObjectType.Butterfly:
        return GameObjectButterfly(
          x: x,
          y: y,
          z: z,
        );
      case GameObjectType.Loot:
        return GameObjectLoot(
          x: x,
          y: y,
          z: z,
          lootType: 0
        );
      case 17:
        return GameObjectLoot(
            x: x,
            y: y,
            z: z,
            lootType: 0
        );
      default:
        throw Exception("Could not create gameobject from type $type");
    }
}

class NodeGrid {
  final int height;
  final int rows;
  final int columns;
  late final int area;

  final Uint8List nodeTypes;
  final Uint8List nodeOrientations;

  NodeGrid({
    required this.nodeTypes,
    required this.nodeOrientations,
    required this.height,
    required this.rows,
    required this.columns,
  }) {
    area = rows * columns;
  }

  int getNodeIndex(int z, int row, int column){
    // assert (gridNodeIsInBounds(z, row, column));
    return (z * area) + (row * columns) + column;
  }
}

NodeGrid convertFlatGridToNodeGrid(List<dynamic> flatGrid, int height, int rows, int columns){
  final nodeVolume = height * rows * columns;
  final nodeTypes = Uint8List(nodeVolume);
  final nodeOrientations = Uint8List(nodeVolume);
  var nodeIndex = 0;

  for (var flatGridIndex = 0; flatGridIndex < flatGrid.length; flatGridIndex++){
    final nodeType = flatGrid[flatGridIndex];
    nodeTypes[nodeIndex] = nodeType;

    if (NodeType.isOriented(nodeType)){
      flatGridIndex++;
      final nodeOrientation = flatGrid[flatGridIndex];
      nodeOrientations[nodeIndex] =
      NodeType.supportsOrientation(nodeType, nodeOrientation)
          ? nodeOrientation
          : NodeType.getDefaultOrientation(nodeType);
      nodeIndex++;
      continue;
    }

    if (nodeType == NodeType.Spawn){
      flatGridIndex++;
      final spawnType = flatGrid[flatGridIndex];
      flatGridIndex++;
      final spawnAmount = flatGrid[flatGridIndex];
      flatGridIndex++;
      final spawnRadius = flatGrid[flatGridIndex];
    }
    nodeIndex++;
  }

  return NodeGrid(
      nodeTypes: nodeTypes,
      nodeOrientations: nodeOrientations,
      height: height,
      rows: rows,
      columns: columns,
  );
}


// List<List<List<Node>>> convertFlatGridToGrid(List<dynamic> flatGrid, int height, int rows, int columns){
//   var index = 0;
//
//   final nodeVolume = height * rows * columns;
//   final nodeTypes = Uint8List(nodeVolume);
//   final nodeOrientations = Uint8List(nodeVolume);
//   var nodeIndex = 0;
//
//   for (var flatGridIndex = 0; flatGridIndex < flatGrid.length; flatGridIndex++){
//      final nodeType = flatGrid[flatGridIndex];
//      nodeTypes[nodeIndex] = nodeType;
//
//      if (NodeType.isOriented(nodeType)){
//         flatGridIndex++;
//         final nodeOrientation = flatGrid[flatGridIndex];
//         nodeOrientations[nodeIndex] =
//           NodeType.supportsOrientation(nodeType, nodeOrientation)
//             ? nodeOrientation
//             : NodeType.getDefaultOrientation(nodeType);
//         nodeIndex++;
//         continue;
//      }
//
//      if (nodeType == NodeType.Spawn){
//         flatGridIndex++;
//         final spawnType = flatGrid[flatGridIndex];
//         flatGridIndex++;
//         final spawnAmount = flatGrid[flatGridIndex];
//         flatGridIndex++;
//         final spawnRadius = flatGrid[flatGridIndex];
//      }
//      nodeIndex++;
//   }
//
//   return List.generate(height, (zIndex) =>
//     List.generate(rows, (rowIndex) =>
//       List.generate(columns, (columnIndex){
//
//         final node = generateNode(flatGrid[index]);
//         if (node is NodeOriented){
//           index++;
//           node.orientation = flatGrid[index];
//
//           if (node.orientation == NodeOrientation.None) {
//              node.orientation = NodeType.getDefaultOrientation(node.type);
//           }
//         }
//         if (node is NodeSpawn) {
//            index++;
//            node.spawnType = flatGrid[index];
//            index++;
//            node.spawnAmount = flatGrid[index];
//            index++;
//            node.spawnRadius = (flatGrid[index] as int).toDouble();
//            node.indexZ = zIndex;
//            node.indexRow = rowIndex;
//            node.indexColumn = columnIndex;
//         }
//         index++;
//         return node;
//       }, growable: false)
//    , growable: false)
//   , growable: false);
// }
