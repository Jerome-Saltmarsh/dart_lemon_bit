
import 'package:typedef/json.dart';

import '../classes/enemy_spawn.dart';
import '../classes/gameobject.dart';
import '../classes/library.dart';
import '../classes/node.dart';
import '../common/game_object_type.dart';
import '../isometric/generate_node.dart';

Scene convertJsonToScene(Json json, String name) {
  final height = json.getInt('grid-z');
  final rows = json.getInt('grid-rows');
  final columns = json.getInt('grid-columns');
  var enemySpawns = <EnemySpawn>[];
  final List jsonGameObjects = json['gameobjects'] ?? [];

  return Scene(
    name: name,
    grid: convertFlatGridToGrid(json['grid'], height, rows, columns),
    gameObjects: jsonGameObjects.map(convertJsonToGameObject).toList(),
    enemySpawns: enemySpawns,
  );
}

GameObject convertJsonToGameObject(dynamic json){
  if (json is Json){
    final type = json.getInt('type');
    final x = json.getDouble('x');
    final y = json.getDouble('y');
    final z = json.getDouble('z');
    switch (type){
      case GameObjectType.Flower:
        return GameObjectFlower(
          x: x,
          y: y,
          z: z,
        );
      case GameObjectType.Crystal:
        return GameObjectCrystal(
          x: x,
          y: y,
          z: z,
        );
      case GameObjectType.Chicken:
        return GameObjectChicken(
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
      case GameObjectType.Stick:
        return GameObjectStick(
          x: x,
          y: y,
          z: z,
        );
      case GameObjectType.Rock:
        return GameObjectRock(
          x: x,
          y: y,
          z: z,
        );
      default:
        throw Exception("Could not create gameobject from type $type");
    }
  }
  throw Exception();
}

List<List<List<Node>>> convertFlatGridToGrid(List<dynamic> flatGrid, int height, int rows, int columns){
  var index = 0;
  final List<List<List<Node>>> grid = List.generate(height, (zIndex) {
    return List.generate(rows, (rowIndex){
      return List.generate(columns, (columnIndex){
        final node = generateNode(flatGrid[index]);
        index++;
        return node;
      });
    });
  });
  return grid;
}
