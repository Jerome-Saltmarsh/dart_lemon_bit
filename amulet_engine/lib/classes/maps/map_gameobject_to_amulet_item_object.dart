
import 'package:amulet_engine/isometric/classes/gameobject.dart';
import 'package:amulet_engine/src.dart';

AmuletItemObject? mapGameObjectToAmuletItemObject(GameObject gameObject) =>
    mapJsonToAmuletItemObject(gameObject.data);