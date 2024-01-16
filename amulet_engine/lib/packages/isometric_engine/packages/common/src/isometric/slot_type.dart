
import 'item_type.dart';

enum SlotType {
  Item,
  Weapon,
  Body,
  Helm,
  Shoes;

  bool supportsItemType(int? itemType) {

    if (itemType == null) {
      return true;
    }

    return switch (this){
        Weapon => itemType == ItemType.Weapon,
        Helm => itemType == ItemType.Helm,
        Body => itemType == ItemType.Armor,
        Shoes => itemType == ItemType.Shoes,
        Item => true
      };
  }
}