
import 'item_type.dart';

enum SlotType {
  Item,
  Weapon,
  Body,
  Hand_Left,
  Hand_Right,
  Helm,
  Legs,
  Shoes;

  bool supportsItemType(int? itemType) {

    if (itemType == null) {
      return true;
    }

    return switch (this){
        Weapon => itemType == ItemType.Weapon,
        Helm => itemType == ItemType.Helm,
        Legs => itemType == ItemType.Legs,
        Body => itemType == ItemType.Armor,
        Hand_Left => itemType == ItemType.Hand,
        Hand_Right => itemType == ItemType.Hand,
        Shoes => itemType == ItemType.Shoes,
        Item => true
      };
  }
}