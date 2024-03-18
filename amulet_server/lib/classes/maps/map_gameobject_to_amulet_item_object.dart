
import 'package:amulet_common/src.dart';
import 'package:amulet_server/isometric/classes/gameobject.dart';
import 'package:amulet_server/src.dart';

AmuletItemObject? mapGameObjectToAmuletItemObject(GameObject gameObject) {

  final amuletItem = gameObject.amuletItem;
  if (amuletItem == null){
    return null;
  }
  return AmuletItemObject(amuletItem: amuletItem, level: gameObject.level);
}