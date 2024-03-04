
import 'package:amulet_engine/isometric/classes/gameobject.dart';
import 'package:amulet_engine/json/map_json_to_amulet_item_object.dart';
import 'package:amulet_engine/src.dart';

AmuletItemObject? mapGameObjectToAmuletItemObject(GameObject gameObject) {
  final data = gameObject.data;
  if (data == null) {
    return null;
  }
  return mapJsonToAmuletItemObject(data);
}