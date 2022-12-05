import 'package:bleed_server/gamestream.dart';

class GameSurvival extends Game {

  GameSurvival(Scene scene) : super(scene);

  @override
  int get gameType => GameType.Survival;

  @override
  Player spawnPlayer() {
    return Player(game: this, weaponType: ItemType.Weapon_Melee_Knife);
  }

  @override
  void customOnPlayerRevived(Player player) {
    player.inventoryAddMax(itemType: ItemType.Weapon_Melee_Knife);
    player.inventoryAddMax(itemType: ItemType.Resource_Round_9mm);
    player.inventoryAdd(itemType: ItemType.Consumables_Apple, itemQuantity: 2);
    player.inventoryAdd(itemType: ItemType.Weapon_Thrown_Grenade, itemQuantity: 3);
    player.bodyType = ItemType.Body_Shirt_Cyan;
    player.legsType = ItemType.Legs_Blue;
    player.belt1_itemType = ItemType.Weapon_Handgun_Glock;
    player.belt1_itemType = ItemType.getMaxQuantity(ItemType.Weapon_Handgun_Glock);
  }

}