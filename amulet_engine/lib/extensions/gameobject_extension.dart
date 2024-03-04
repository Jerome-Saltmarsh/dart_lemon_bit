
import 'package:amulet_engine/common.dart';
import 'package:amulet_engine/isometric/classes/gameobject.dart';

extension GameObjectExtension on GameObject {

  AmuletItem? get amuletItem {
    if (itemType != ItemType.Amulet_Item) {
      return null;
    }
    return AmuletItem.values[subType];
  }

  bool get isAmuletItem => itemType == ItemType.Amulet_Item;

  bool get isObject => itemType == ItemType.Object;

  AmuletItemObject? get amuletItemObject{

    if (!isAmuletItem){
      return null;
    }

  }

}