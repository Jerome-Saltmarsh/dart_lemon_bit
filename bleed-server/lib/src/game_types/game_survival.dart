import 'package:bleed_server/gamestream.dart';
import 'package:bleed_server/src/classes/src/node_collider.dart';
import 'package:bleed_server/src/dark_age/dark_age_environment.dart';
import 'package:lemon_math/functions/random_item.dart';

class GameSurvival extends Game {

  GameSurvival({required super.scene}) : super(
      environment: DarkAgeEnvironment(),
      time: DarkAgeTime(),
      gameType: GameType.Survival,
  ) {
    triggerSpawnPoints();

    final totalNodes = scene.gridVolume;
    for (var i = 0; i < totalNodes; i++){
       if (scene.nodeTypes[i] != NodeType.Vendor) continue;
       gameObjects.add(
           InteractableCollider(
               x: scene.convertNodeIndexToPositionX(i),
               y: scene.convertNodeIndexToPositionY(i),
               z: scene.convertNodeIndexToPositionZ(i),
           )
       );
    }
  }

  int getRandomStartingShirt() => randomItem(const[
    ItemType.Body_Shirt_Cyan,
    ItemType.Body_Shirt_Blue,
  ]);

  int getRandomStartingLegs() => randomItem(const[
    ItemType.Legs_Blue,
    // ItemType.Legs_White,
    // ItemType.Legs_Red,
    // ItemType.Legs_Green,
  ]);

  @override
  void customOnPlayerRevived(Player player) {
    player.team = TeamType.Alone;
    player.inventoryClear();
    player.inventoryAddMax(itemType: ItemType.Resource_Gun_Powder);
    player.inventoryAdd(itemType: ItemType.Weapon_Melee_Axe);
    player.inventoryAdd(itemType: ItemType.Weapon_Melee_Pickaxe);
    player.inventoryAdd(itemType: ItemType.Weapon_Melee_Hammer);
    player.inventoryAdd(itemType: ItemType.Weapon_Melee_Crowbar);
    player.inventoryAdd(itemType: ItemType.Weapon_Melee_Sword);
    player.inventoryAdd(itemType: ItemType.Weapon_Melee_Staff);

    player.inventoryAdd(itemType: ItemType.Weapon_Melee_Staff);
    player.bodyType = getRandomStartingShirt();
    player.legsType = getRandomStartingLegs();
    player.headType = ItemType.Empty;
    player.belt1_itemType = ItemType.Weapon_Handgun_Flint_Lock_Old;
    player.belt1_quantity = ItemType.getMaxQuantity(ItemType.Weapon_Handgun_Flint_Lock_Old);
    player.belt2_itemType = ItemType.Weapon_Melee_Knife;
    player.belt2_quantity = 1;
    player.belt3_itemType = ItemType.Weapon_Thrown_Grenade;
    player.belt3_quantity = 3;
    player.belt4_itemType = ItemType.Consumables_Apple;
    player.belt4_quantity = 3;
    player.belt5_itemType = ItemType.Weapon_Rifle_Blunderbuss;
    player.belt5_quantity = ItemType.getMaxQuantity(ItemType.Weapon_Rifle_Blunderbuss);
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
      ItemType.Resource_Scrap_Metal,
      ItemType.Resource_Gold,
      ItemType.Resource_Gun_Powder,
      ItemType.Weapon_Thrown_Grenade,
      ItemType.Consumables_Apple,
    ]);

  int getItemQuantityForItemType(int itemType) => const {
      ItemType.Resource_Round_9mm: 10,
      ItemType.Resource_Round_Shotgun: 3,
      ItemType.Resource_Round_Rifle: 15,
      ItemType.Resource_Round_50cal: 2,
      ItemType.Resource_Scrap_Metal: 1,
      ItemType.Resource_Gold: 1,
      ItemType.Resource_Gun_Powder: 2,
      ItemType.Consumables_Apple: 2,
  }[itemType] ?? 1;

  @override
  void customOnCharacterKilled(Character target, src) {
    if (target is AI) {
      spawnRandomGameObjectAtPosition(target);
    }
  }

  void spawnRandomGameObjectAtPosition(Position3 value) {
    final itemType = getRandomItemType();
    if (itemType == ItemType.Empty) return;
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
  void onPlayerInteractedWithGameObject(Player player, GameObject gameObject) {
    player.setStoreItems(const [
        ItemType.Weapon_Thrown_Grenade,
        ItemType.Weapon_Handgun_Flint_Lock_Old,
        ItemType.Weapon_Handgun_Flint_Lock,
        ItemType.Weapon_Handgun_Flint_Lock_Superior,
        ItemType.Weapon_Handgun_Glock,
        ItemType.Weapon_Rifle_Arquebus,
        ItemType.Weapon_Rifle_Blunderbuss,
        ItemType.Weapon_Rifle_Jager,
        ItemType.Weapon_Rifle_Musket,
        ItemType.Weapon_Rifle_AK_47,
        ItemType.Weapon_Rifle_M4,
        ItemType.Weapon_Rifle_Sniper,
    ]);
  }

  @override
  void customOnHitApplied(Character src, Collider target) {
     if (target is GameObject) {
        if (target.type == ItemType.GameObjects_Barrel) {
           deactivateGameObject(target);
           spawnRandomGameObjectAtPosition(target);
           final x = target.x;
           final y = target.y;
           final z = target.z;
           performJob(1000, () {
               spawnGameObject(x: x, y: y, z: z, type: ItemType.GameObjects_Barrel)
                ..physical = true
                ..collidable = true
                ..team = TeamType.Alone
                ..moveOnCollision = false;
           });
        }
     }
  }

  @override
  void customOnAIRespawned(AI ai) {
    ai.maxHealth = getCharacterTypeHealth(ai.characterType);
    ai.health = ai.maxHealth;
  }

  int getCharacterTypeHealth(int characterType){
    return const {
       CharacterType.Zombie: 10,
       CharacterType.Dog: 6,
       CharacterType.Template: 8,
    }[characterType] ?? 10;
  }
}