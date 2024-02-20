



import 'dart:typed_data';

import 'package:amulet_engine/classes/amulet_gameobject.dart';
import 'package:amulet_engine/common.dart';
import 'package:amulet_engine/common/src/isometric/item_type.dart';
import 'package:amulet_engine/isometric/classes/gameobject.dart';
import 'package:amulet_engine/isometric/classes/scene.dart';
import 'package:amulet_engine/isometric/instances/decoder.dart';
import 'package:lemon_json/src.dart';

Scene readSceneFromJson(Json json){

  Uint8List decode(String fieldName) =>
      Uint8List.fromList(
          decoder.decodeBytes(
              json.getListInt(fieldName)
          )
      );

  return Scene(
      name: json.getString('name'),
      nodeTypes: decode('node_types'),
      nodeOrientations: decode('node_orientations'),
      variations: decode('variations'),
      height: json.getInt('height'),
      rows: json.getInt('rows'),
      columns: json.getInt('columns'),
      marks: json.getListInt('marks'),
      keys: json.getMapStringInt('keys'),
      locations: json.getMapStringInt('locations'),
      gameObjects: readGameObjectsFromJson(json),
  );
}

List<GameObject> readGameObjectsFromJson(Json json) =>
    json.getObjects('gameobjects')
      .map(readGameObjectFromJson)
      .toList(growable: true);

GameObject readGameObjectFromJson(Json gameObjectJson){
   final x = gameObjectJson.getDouble('x');
   final y = gameObjectJson.getDouble('y');
   final z = gameObjectJson.getDouble('z');
   final itemType = gameObjectJson.getInt('item_type');
   final subType = gameObjectJson.getInt('sub_type');
   final deactivateTimer = gameObjectJson.getInt('deactive_timer');
   final frameSpawned = gameObjectJson.getInt('frame_spawned');
   final id = gameObjectJson.getInt('id');
   final team = gameObjectJson.getInt('team');

   if (itemType == ItemType.Object){
     return GameObject(
         x: x,
         y: y,
         z: z,
         team: team,
         itemType: itemType,
         subType: subType,
         id: id,
     )
       ..persistable = true
       ..frameSpawned = frameSpawned;
   }

   if (itemType == ItemType.Amulet_Item){
     return AmuletGameObject(
       x: x,
       y: y,
       z: z,
       id: id,
       amuletItem: AmuletItem.values[subType],
       frameSpawned: frameSpawned,
       deactivationTimer: deactivateTimer,
     )
       ..persistable = true;
   }

   throw Exception('cannot parse gameobject item_type $itemType');
}

