import 'package:bleed_server/gamestream.dart';
import 'package:bleed_server/src/classes/src/game_environment.dart';
import 'package:bleed_server/src/classes/src/game_time.dart';
import 'package:lemon_math/functions/random_bool.dart';
import 'package:lemon_math/functions/random_item.dart';

class GameSurvival extends Game {

  GameSurvival({required super.scene}) : super(
      environment: GameEnvironment(),
      time: GameTime(),
      gameType: GameType.Survival,
      options: GameOptions(perks: true, inventory: true, items: false),
  ) {
    triggerSpawnPoints();
  }

  int getRandomStartingShirt() => randomItem(const[
    ItemType.Body_Shirt_Cyan,
    ItemType.Body_Shirt_Blue,
  ]);

  int getRandomStartingLegs() => randomItem(const[
    ItemType.Legs_Blue,
    ItemType.Legs_White,
    // ItemType.Legs_Red,
    // ItemType.Legs_Green,
  ]);

  @override
  void customOnPlayerRevived(Player player) {
    player.team = TeamType.Alone;
    player.inventoryClear();
    player.inventoryAddMax(itemType: ItemType.Resource_Gun_Powder);
    player.inventoryAddMax(itemType: ItemType.Resource_Round_Rifle);
    player.inventoryAddMax(itemType: ItemType.Resource_Round_Shotgun);
    player.inventoryAdd(itemType: ItemType.Consumables_Potion_Blue);
    player.inventoryAdd(itemType: ItemType.Consumables_Potion_Red);
    player.inventoryAdd(itemType: ItemType.Weapon_Thrown_Grenade, itemQuantity: 3);
    player.bodyType = getRandomStartingShirt();
    player.legsType = getRandomStartingLegs();
    player.headType = ItemType.Empty;
    player.belt1_itemType = ItemType.Weapon_Ranged_Shotgun;
    player.belt1_quantity = ItemType.getMaxQuantity(ItemType.Weapon_Ranged_Shotgun);
    player.belt2_itemType = ItemType.Weapon_Melee_Knife;
    player.belt2_quantity = 1;
    player.belt3_itemType = ItemType.Weapon_Melee_Crowbar;
    player.belt3_quantity = 1;
    player.belt4_itemType = ItemType.Consumables_Apple;
    player.belt4_quantity = 3;
    player.belt5_itemType = ItemType.Weapon_Ranged_Rifle;
    player.belt5_quantity = ItemType.getMaxQuantity(ItemType.Weapon_Ranged_Rifle);
    player.belt6_itemType = ItemType.Weapon_Ranged_Machine_Gun;
    player.belt6_quantity = ItemType.getMaxQuantity(ItemType.Weapon_Ranged_Machine_Gun);
    player.equippedWeaponIndex = ItemType.Belt_1;
    player.refreshStats();
    moveToRandomPlayerSpawnPoint(player);
    player.health = player.maxHealth;
  }

  int getRandomItemType() => randomItem(const[
      ItemType.Resource_Round_9mm,
      ItemType.Resource_Round_Shotgun,
      ItemType.Resource_Round_Rifle,
      ItemType.Resource_Round_50cal,
      ItemType.Weapon_Thrown_Grenade,
      ItemType.Consumables_Apple,
    ]);

  int getItemQuantityForItemType(int itemType) => const {
      ItemType.Resource_Round_9mm: 4,
      ItemType.Resource_Round_Shotgun: 2,
      ItemType.Resource_Round_Rifle: 8,
      ItemType.Resource_Round_50cal: 2,
      ItemType.Resource_Scrap_Metal: 1,
      ItemType.Resource_Gold: 1,
      ItemType.Resource_Credit: 5,
      ItemType.Resource_Gun_Powder: 2,
      ItemType.Consumables_Apple: 2,
  }[itemType] ?? 1;

  @override
  void customOnCharacterKilled(Character target, src) {
    if (target is AI) {
      spawnRandomGameObjectAtPosition(target);
    }

    if (src is Player) {
      src.credits += 10;
    }
  }

  void spawnRandomGameObjectAtPosition(Position3 value) {
    if (randomBool()) return;
    final itemType = getRandomItemType();
    spawnGameObjectItemAtPosition(
      position: value,
      type: itemType,
      quantity: getItemQuantityForItemType(itemType),
    );
  }

  @override
  void customUpdate() {
    time.update();
    environment.update();
  }

  @override
  void customOnPlayerInteractedWithGameObject(Player player, GameObject gameObject) {

    if (gameObject.type == ItemType.GameObjects_Vending_Machine){
      player.setStoreItems(const [
        ItemType.Weapon_Thrown_Grenade,
        ItemType.Weapon_Ranged_Handgun,
        ItemType.Weapon_Ranged_Musket,
        ItemType.Weapon_Ranged_Machine_Gun,
        ItemType.Weapon_Ranged_Sniper_Rifle,
        ItemType.Weapon_Ranged_Bow,
      ]);
    }

    if (gameObject.type == ItemType.GameObjects_Vending_Upgrades) {
      final items = <int>[];
      for (var i = 0; i < player.inventory.length; i++){
          final itemType = player.inventory[i];
          final itemTypeUpgrade = ItemType.getUpgrade(itemType);
          if (itemTypeUpgrade == ItemType.Empty) continue;
          items.add(itemTypeUpgrade);
      }
      final belt1Upgrade = ItemType.getUpgrade(player.belt1_itemType);
      if (belt1Upgrade != ItemType.Empty){
        items.add(belt1Upgrade);
      }
      final belt2Upgrade = ItemType.getUpgrade(player.belt2_itemType);
      if (belt2Upgrade != ItemType.Empty){
        items.add(belt2Upgrade);
      }
      final belt3Upgrade = ItemType.getUpgrade(player.belt3_itemType);
      if (belt3Upgrade != ItemType.Empty){
        items.add(belt3Upgrade);
      }
      final belt4Upgrade = ItemType.getUpgrade(player.belt4_itemType);
      if (belt4Upgrade != ItemType.Empty){
        items.add(belt4Upgrade);
      }
      final belt5Upgrade = ItemType.getUpgrade(player.belt5_itemType);
      if (belt5Upgrade != ItemType.Empty){
        items.add(belt5Upgrade);
      }
      final belt6Upgrade = ItemType.getUpgrade(player.belt6_itemType);
      if (belt6Upgrade != ItemType.Empty){
        items.add(belt6Upgrade);
      }
      player.setStoreItems(items);
    }
  }

  @override
  void customOnHitApplied({
    required Character srcCharacter,
    required Collider target,
    required int damage,
    required double angle,
    required int hitType,
    required double force,
  }) {
    if (target is GameObject) {
      if (hitType != HitType.Melee) {
        if (target.type == ItemType.GameObjects_Barrel_Explosive) {
          deactivateCollider(target);
          createExplosion(target: target, srcCharacter: srcCharacter);
        }
      }

      if (DestroyableGameObjects.contains(target.type)) {
        deactivateCollider(target);
        dispatchGameEventGameObjectDestroyed(target);
        performScript(timer: 300)
          ..writeSpawnGameObject(
              type: target.type,
              x: target.x,
              y: target.y,
              z: target.z,
          );
        spawnGameObjectItem(
            x: target.x,
            y: target.y,
            z: target.z,
            type: ItemType.Resource_Scrap_Metal,
        );
      }
    }
  }

  static const DestroyableGameObjects = [
    ItemType.GameObjects_Toilet,
    ItemType.GameObjects_Crate_Wooden,
  ];

  @override
  void customOnCollisionBetweenPlayerAndGameObject(Player player, GameObject gameObject) {
    if (gameObject.type == ItemType.Resource_Credit){
       deactivateCollider(gameObject);
       player.credits += 5;
    }
  }

  @override
  void customOnAIRespawned(AI ai) {
    ai.characterType = randomItem(const[
       CharacterType.Template,
       CharacterType.Zombie,
       CharacterType.Dog,
    ]);
    ai.maxHealth = getCharacterTypeHealth(ai.characterType);
    ai.health = ai.maxHealth;

    if (ai.characterTypeTemplate){
      ai.weaponType = randomItem(const[
        ItemType.Empty,
        ItemType.Weapon_Ranged_Handgun,
        ItemType.Weapon_Melee_Crowbar,
      ]);
      ai.headType = randomItem(const[
        ItemType.Empty,
        ItemType.Head_Rogues_Hood,
        ItemType.Head_Wizards_Hat,
        ItemType.Head_Swat,
      ]);
      ai.bodyType = randomItem(const[
        ItemType.Empty,
        ItemType.Body_Shirt_Blue,
        ItemType.Body_Shirt_Cyan,
        ItemType.Body_Tunic_Padded,
        ItemType.Body_Swat,
      ]);
      ai.legsType = randomItem(const[
        ItemType.Legs_Green,
        ItemType.Legs_Red,
        ItemType.Legs_Swat,
        ItemType.Legs_Blue,
      ]);
    }
  }

  int getCharacterTypeHealth(int characterType) => const {
       CharacterType.Zombie: 10,
       CharacterType.Dog: 6,
       CharacterType.Template: 8,
    }[characterType] ?? 10;

  @override
  void customOnColliderDeactivated(Collider collider) {
    if (collider is GameObject){
      if (ItemType.isTypeBarrel(collider.type)){
        performJob(200, (){
          collider.x = collider.startX;
          collider.y = collider.startY;
          collider.z = collider.startZ;
          activateCollider(collider);
        });
      }
    }
  }

}
