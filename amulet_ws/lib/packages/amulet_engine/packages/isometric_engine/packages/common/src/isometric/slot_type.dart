
import 'item_type.dart';

enum SlotType {
  Items,
  Treasures,
  Weapons,
  Equipped_Body,
  Equipped_Hand_Left,
  Equipped_Hand_Right,
  Equipped_Helm,
  Equipped_Legs,
  Equipped_Shoes;

  bool supportsItemType(int? itemType) {

    if (itemType == null){
      return true;
    }

    return switch (this){
        Equipped_Helm => itemType == ItemType.Helm,
        Equipped_Legs => itemType == ItemType.Legs,
        Equipped_Body => itemType == ItemType.Body,
        Equipped_Hand_Left => itemType == ItemType.Hand,
        Equipped_Hand_Right => itemType == ItemType.Hand,
        Treasures => itemType == ItemType.Treasure,
        Weapons => const [ItemType.Weapon, ItemType.Spell].contains(itemType),
        Equipped_Shoes => itemType == ItemType.Shoes,
        Items => true
      };
  }



}