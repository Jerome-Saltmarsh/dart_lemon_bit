import 'package:bleed_server/gamestream.dart';
import 'package:bleed_server/src/dark_age/dark_age_environment.dart';
import 'package:lemon_math/functions/random_item.dart';

class GameSurvival extends Game {

  GameSurvival({required super.scene}) : super(
      environment: DarkAgeEnvironment(),
      time: DarkAgeTime(),
      gameType: GameType.Survival,
  ) {
    triggerSpawnPoints();
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
    player.inventoryAddMax(itemType: ItemType.Resource_Round_Rifle);
    player.inventoryAdd(itemType: ItemType.Weapon_Melee_Axe);
    player.inventoryAdd(itemType: ItemType.Weapon_Melee_Pickaxe);
    player.inventoryAdd(itemType: ItemType.Weapon_Melee_Hammer);
    player.inventoryAdd(itemType: ItemType.Weapon_Melee_Crowbar);
    player.inventoryAdd(itemType: ItemType.Weapon_Melee_Sword);
    player.inventoryAdd(itemType: ItemType.Weapon_Melee_Staff);
    player.inventoryAdd(itemType: ItemType.Consumables_Potion_Blue);
    player.inventoryAdd(itemType: ItemType.Consumables_Potion_Red);
    player.inventoryAdd(itemType: ItemType.Legs_Blue);
    player.inventoryAdd(itemType: ItemType.Legs_Swat);
    player.inventoryAdd(itemType: ItemType.Legs_Red);
    player.inventoryAdd(itemType: ItemType.Legs_Green);
    player.inventoryAdd(itemType: ItemType.Legs_Brown);
    player.inventoryAdd(itemType: ItemType.Legs_White);
    player.bodyType = ItemType.Body_Tunic_Padded;
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
    player.belt5_itemType = ItemType.Weapon_Rifle_Jager;
    player.belt5_quantity = ItemType.getMaxQuantity(ItemType.Weapon_Rifle_Jager);
    player.belt6_itemType = ItemType.Weapon_Rifle_AK_47;
    player.belt6_quantity = ItemType.getMaxQuantity(ItemType.Weapon_Rifle_AK_47);
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
        ItemType.Weapon_Ranged_Bow,
    ]);
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
        getNewGameScript(timer: 300)
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
        ItemType.Weapon_Handgun_Glock,
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
