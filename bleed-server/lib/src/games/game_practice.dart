
import 'package:bleed_server/gamestream.dart';
import 'package:bleed_server/src/classes/src/game_environment.dart';
import 'package:bleed_server/src/classes/src/game_time.dart';
import 'package:bleed_server/src/constants/frames_per_second.dart';
import 'package:lemon_math/library.dart';

class GamePractice extends Game {
  var configMaxPlayers = 7;
  var configZombieHealth = 5;
  var configZombieSpeed = 5.0;

  GamePractice({required super.scene}) : super(
      environment: GameEnvironment(),
      time: GameTime(
        hour: 12,
        minute: 30,
      ),
      gameType: GameType.Practice,
      options: GameOptions(
          perks: false,
          inventory: true,
          items: false,
      ),
  ) {
    aiRespawnDuration = framesPerSecond * 60;
    triggerSpawnPoints();
  }

  @override
  void customInitPlayer(Player player) {
    player.writeEnvironmentRain(RainType.Light);
    player.writeEnvironmentLightning(LightningType.Off);
    player.writeEnvironmentWind(WindType.Gentle);
    player.writeEnvironmentBreeze(false);
  }

  @override
  void customOnCollisionBetweenPlayerAndGameObject(Player player, GameObject gameObject) {

  }

  @override
  void customOnPlayerRevived(Player player){
    moveToRandomPlayerSpawnPoint(player);
    player.inventoryClear();
    player.inventoryAddMax(itemType: ItemType.Weapon_Ranged_Shotgun);
    player.inventoryAdd(itemType: ItemType.Resource_Gun_Powder, itemQuantity: 100);
    player.inventoryAdd(itemType: ItemType.Resource_Round_9mm, itemQuantity: 100);
    player.inventoryAdd(itemType: ItemType.Resource_Round_Rifle, itemQuantity: 100);
    player.inventoryAdd(itemType: ItemType.Resource_Round_Shotgun, itemQuantity: 100);
    player.inventoryAdd(itemType: ItemType.Resource_Round_50cal, itemQuantity: 100);
    player.inventoryAdd(itemType: ItemType.Resource_Rocket, itemQuantity: 100);
    player.inventoryAddMax(itemType: ItemType.Trinket_Ring_of_Damage);
    player.inventoryAddMax(itemType: ItemType.Trinket_Ring_of_Health);
    player.inventoryAddMax(itemType: ItemType.Weapon_Melee_Sword);
    player.inventoryAddMax(itemType: ItemType.Weapon_Rifle_Arquebus);
    player.inventoryAddMax(itemType: ItemType.Weapon_Rifle_Jager);
    player.inventoryAddMax(itemType: ItemType.Weapon_Rifle_Musket);
    player.inventoryAddMax(itemType: ItemType.Weapon_Rifle_Sniper);
    player.inventoryAddMax(itemType: ItemType.Weapon_Handgun_Glock);
    player.inventoryAddMax(itemType: ItemType.Weapon_Handgun_Desert_Eagle);
    player.inventoryAddMax(itemType: ItemType.Weapon_Rifle_AK_47);
    player.inventoryAddMax(itemType: ItemType.Weapon_Rifle_M4);
    player.inventoryAddMax(itemType: ItemType.Weapon_Melee_Knife);
    player.inventoryAdd(itemType: ItemType.Weapon_Thrown_Grenade, itemQuantity: 10);
    player.inventoryAdd(itemType: ItemType.Weapon_Flamethrower, itemQuantity: 500);
    player.inventoryAdd(itemType: ItemType.Weapon_Special_Bazooka, itemQuantity: 500);
    player.inventoryAdd(itemType: ItemType.Weapon_Smg_Mp5, itemQuantity: 200);
    player.inventoryAdd(itemType: ItemType.Weapon_Special_Minigun, itemQuantity: 1000);
    player.inventoryAdd(itemType: ItemType.Weapon_Handgun_Revolver, itemQuantity: 1000);
    player.headType = randomItem(ItemType.HeadTypes);
    player.bodyType = randomItem(ItemType.BodyTypes);
    player.legsType = randomItem(ItemType.LegTypes);
    player.inventorySet(index: ItemType.Belt_1, itemType: ItemType.Weapon_Rifle_AK_47, itemQuantity: ItemType.getMaxQuantity(ItemType.Weapon_Rifle_AK_47));
    player.inventorySet(index: ItemType.Belt_2, itemType: ItemType.Weapon_Rifle_Sniper, itemQuantity: ItemType.getMaxQuantity(ItemType.Weapon_Rifle_Sniper));
    player.inventorySet(index: ItemType.Belt_3, itemType: ItemType.Weapon_Handgun_Glock, itemQuantity: ItemType.getMaxQuantity(ItemType.Weapon_Handgun_Glock));
    player.inventorySet(index: ItemType.Belt_4, itemType: ItemType.Weapon_Thrown_Grenade, itemQuantity: 10);
    player.inventorySet(index: ItemType.Belt_5, itemType: ItemType.Weapon_Melee_Knife, itemQuantity: 1);
    player.inventorySet(index: ItemType.Belt_6, itemType: ItemType.Consumables_Apple, itemQuantity: 3);
    player.equippedWeaponIndex = ItemType.Belt_1;
    player.inventoryDirty = true;
    player.refreshStats();
    player.health = player.maxHealth;
    player.team = TeamType.Alone;
  }

  @override
  void customOnPlayerWeaponChanged(Player player, int newWeapon, int previousWeapon){

  }

  @override
  void customOnPlayerDisconnected(Player player) {

  }

  void reactivatePlayerWeapons(Player player){
  }

  /// @override
  void customOnAIRespawned(AI ai){
     ai.characterType = randomItem(const [
       CharacterType.Dog,
       CharacterType.Zombie,
       CharacterType.Template,
     ]);
     if (ai.characterType == CharacterType.Template){
       ai.weaponType = randomItem(const [
         ItemType.Weapon_Handgun_Glock,
         ItemType.Weapon_Ranged_Bow,
         ItemType.Weapon_Melee_Sword,
         ItemType.Weapon_Smg_Mp5,
       ]);
     } else {
       ai.weaponType = ItemType.Empty;
     }
  }

  @override
  void customUpdate() {
    environment.update();
  }
}