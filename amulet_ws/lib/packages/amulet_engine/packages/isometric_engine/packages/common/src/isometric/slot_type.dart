
import 'item_type.dart';

enum SlotType {
  Item,
  Treasure,
  Weapons,
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
        Body => itemType == ItemType.Body,
        Hand_Left => itemType == ItemType.Hand,
        Hand_Right => itemType == ItemType.Hand,
        Treasure => itemType == ItemType.Treasure,
        Weapons => const [ItemType.Weapon, ItemType.Spell].contains(itemType),
        Shoes => itemType == ItemType.Shoes,
        Item => true
      };
  }
}