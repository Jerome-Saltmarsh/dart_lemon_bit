
import 'package:amulet_engine/isometric/classes/gameobject.dart';
import 'package:amulet_engine/src.dart';

AmuletItemObject? mapGameObjectToAmuletItemObject(GameObject gameObject) {

  final amuletItem = gameObject.amuletItem;
  if (amuletItem == null){
    return null;
  }
  return AmuletItemObject(amuletItem: amuletItem, level: gameObject.level);
}