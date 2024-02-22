



import 'dart:typed_data';

import 'package:amulet_engine/common.dart';
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
   final deactivationTimer = gameObjectJson.tryGetInt('deactivation_timer') ?? -1;
   final id = gameObjectJson.getInt('id');
   final team = gameObjectJson.getInt('team');

   var health = 0;

   switch (itemType){
     case ItemType.Object:
       if (const [
         GameObjectType.Wooden_Chest,
         GameObjectType.Crate_Wooden,
         GameObjectType.Barrel,
       ].contains(subType)){
         health = 1;
       }
       break;
   }

   final isAmuletItem = itemType == ItemType.Amulet_Item;

   return GameObject(
       x: x,
       y: y,
       z: z,
       team: team,
       itemType: itemType,
       subType: subType,
       id: id,
       health: health,
       deactivationTimer: deactivationTimer,
       interactable: isAmuletItem,
   )
     ..physical = !isAmuletItem;
}

