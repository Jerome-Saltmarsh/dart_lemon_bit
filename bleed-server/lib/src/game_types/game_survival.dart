import 'package:bleed_server/gamestream.dart';
import 'package:bleed_server/src/dark_age/dark_age_environment.dart';
import 'package:lemon_math/functions/random_item.dart';

class GameSurvival extends Game {

  @override
  int get gameType => GameType.Survival;

  GameSurvival({required super.scene})
      : super(environment: DarkAgeEnvironment(), time: DarkAgeTime()) {
    triggerSpawnPoints();
  }

  int getRandomStartingShirt() => randomItem(const[
    ItemType.Body_Shirt_Cyan,
    ItemType.Body_Shirt_Blue,
  ]);

  int getRandomStartingLegs() => randomItem(const[
    ItemType.Legs_Blue,
    ItemType.Legs_White,
    ItemType.Legs_Red,
    ItemType.Legs_Green,
  ]);

  @override
  void customOnPlayerRevived(Player player) {
    player.team = TeamType.Alone;
    player.inventoryClear();
    player.inventoryAddMax(itemType: ItemType.Resource_Round_9mm);
    player.bodyType = getRandomStartingShirt();
    player.legsType = getRandomStartingLegs();
    player.headType = ItemType.Empty;
    player.belt1_itemType = ItemType.Weapon_Handgun_Glock;
    player.belt1_quantity = ItemType.getMaxQuantity(ItemType.Weapon_Handgun_Glock);
    player.belt2_itemType = ItemType.Weapon_Melee_Knife;
    player.belt2_quantity = 1;
    player.belt3_itemType = ItemType.Weapon_Thrown_Grenade;
    player.belt3_quantity = 3;
    player.belt4_itemType = ItemType.Consumables_Apple;
    player.belt4_quantity = 3;
    player.belt5_itemType = ItemType.Weapon_Rifle_Blunderbuss;
    player.belt5_quantity = 10;
    player.equippedWeaponIndex = ItemType.Belt_1;
    player.refreshStats();
    moveToRandomPlayerSpawnPoint(player);
    player.health = player.maxHealth;
  }

  int getRandomItemType() => randomItem(const[
      ItemType.Resource_Round_9mm,
      ItemType.Resource_Round_9mm,
      ItemType.Resource_Round_9mm,
      ItemType.Resource_Round_Shotgun,
      ItemType.Resource_Round_Shotgun,
      ItemType.Resource_Round_Rifle,
      ItemType.Resource_Round_Rifle,
      ItemType.Resource_Round_50cal,
    ]);

  int getItemQuantityForItemType(int itemType) => const {
      ItemType.Resource_Round_9mm: 10,
      ItemType.Resource_Round_Shotgun: 3,
      ItemType.Resource_Round_Rifle: 15,
      ItemType.Resource_Round_50cal: 2,
  }[itemType] ?? 1;

  @override
  void customOnCharacterKilled(Character target, src) {
    if (target is AI) {
      final itemType = getRandomItemType();
      if (itemType == ItemType.Empty) return;
       spawnGameObjectItemAtPosition(
           position: target,
           type: itemType,
           quantity: getItemQuantityForItemType(itemType),
       );
    }
  }

  @override
  void customUpdate() {
    time.update();
    environment.update();
  }

}