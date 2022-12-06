
import 'package:bleed_server/gamestream.dart';
import 'package:lemon_math/library.dart';

class GamePractice extends Game {
  static const configAIRespawnFrames = 500;
  static const configRespawnFramesWeapons = 500;
  var configMaxPlayers = 7;
  var configZombieHealth = 5;
  var configZombieSpeed = 5.0;

  @override
  int get gameType => GameType.Practice;

  GamePractice({required Scene scene}) : super(scene) {
    triggerSpawnPoints();
  }

  int getRandomItemType() => 0;

  // void respawnAI(AI ai){
    // ai.respawn = configAIRespawnFrames;
    // ai.health = ai.maxHealth;
    // ai.state = CharacterState.Spawning;
    // ai.collidable = true;
    // ai.stateDurationRemaining = 30;
    // moveV3ToNodeIndex(ai, ai.spawnNodeIndex);
  // }

  @override
  void customUpdatePlayer(Player player) {

  }

  @override
  Player spawnPlayer() {
    final player = Player(
      game: this,
      team: 0,
      weaponType: ItemType.Weapon_Handgun_Flint_Lock_Old,
    );
    player.legsType = ItemType.Legs_Brown;
    player.bodyType = ItemType.Body_Tunic_Padded;
    player.headType = ItemType.Head_Wizards_Hat;
    return player;
  }

  @override
  void customInitPlayer(Player player) {
    player.writeEnvironmentShade(Shade.Very_Very_Dark);
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
  }

  @override
  void customOnPlayerWeaponChanged(Player player, int newWeapon, int previousWeapon){

  }

  @override
  void customOnPlayerDisconnected(Player player) {

  }

  void reactivatePlayerWeapons(Player player){
  }

  reactivateGameObject(GameObject gameObject){
    gameObject.active = true;
    gameObject.collidable = true;
    gameObject.type = getRandomItemType();
  }

  void customOnCharacterKilled(Character target, dynamic src) {

  }
}