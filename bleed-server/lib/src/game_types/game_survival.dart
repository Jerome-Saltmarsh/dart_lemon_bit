import 'package:bleed_server/gamestream.dart';
import 'package:bleed_server/src/dark_age/dark_age_environment.dart';

class GameSurvival extends Game {

  GameSurvival(Scene scene) : super(scene) {
    triggerSpawnPoints();
  }

  @override
  int get gameType => GameType.Survival;

  @override
  void customOnPlayerRevived(Player player) {
    player.inventoryAddMax(itemType: ItemType.Resource_Round_9mm);
    player.bodyType = ItemType.Body_Shirt_Cyan;
    player.legsType = ItemType.Legs_Blue;
    player.belt1_itemType = ItemType.Weapon_Handgun_Glock;
    player.belt1_quantity = ItemType.getMaxQuantity(ItemType.Weapon_Handgun_Glock);
    player.belt2_itemType = ItemType.Weapon_Melee_Knife;
    player.belt2_quantity = 1;
    player.belt3_itemType = ItemType.Weapon_Thrown_Grenade;
    player.belt3_quantity = 3;
    player.belt4_itemType = ItemType.Consumables_Apple;
    player.belt4_quantity = 3;
    player.equippedWeaponIndex = ItemType.Belt_1;
    player.refreshStats();
    moveToRandomPlayerSpawnPoint(player);
    player.health = player.maxHealth;
  }

  final environment = DarkAgeEnvironment(DarkAgeTime());
}