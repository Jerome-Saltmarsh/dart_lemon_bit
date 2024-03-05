
import 'package:amulet_engine/common.dart';
import 'package:amulet_engine/isometric/classes/gameobject.dart';
import 'package:amulet_engine/json/amulet_field.dart';
import 'package:lemon_json/src.dart';

extension GameObjectExtension on GameObject {

  AmuletItem? get amuletItem {
    if (itemType != ItemType.Amulet_Item) {
      return null;
    }
    return AmuletItem.values[subType];
  }

  bool get isAmuletItem => itemType == ItemType.Amulet_Item;

  bool get isObject => itemType == ItemType.Object;

  int? get level =>
      this.data?.tryGetInt(AmuletField.Level);
}