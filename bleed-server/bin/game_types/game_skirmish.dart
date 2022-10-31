

import 'package:lemon_math/library.dart';

import '../classes/gameobject.dart';
import '../classes/library.dart';
import '../common/library.dart';
import '../functions/move_player_to_crystal.dart';


class GameSkirmish extends Game {
  static const configAIRespawnFrames = 500;
  static const configRespawnFramesWeapons = 500;
  var configMaxPlayers = 7;
  var configZombieHealth = 5;
  var configZombieSpeed = 5.0;

  List<int> playerSpawnPoints = [];

  @override
  int get gameType => GameType.Skirmish;

  GameSkirmish({required Scene scene}) : super(scene) {

    final volume = scene.gridVolume;
    for (var i = 0; i < volume; i++){
        if (scene.nodeTypes[i] == NodeType.Spawn) {
          final instance = spawnZombieAtIndex(i);
          instance.maxHealth = configZombieHealth;
          instance.health = configZombieHealth;
          instance.respawn = configAIRespawnFrames;
          instance.maxSpeed = configZombieSpeed;
          continue;
        }
        if (scene.nodeTypes[i] == NodeType.Spawn_Weapon) {
          spawnGameObjectAtIndex(
              index: i,
              type: getRandomItemType(),
          );
          continue;
        }
        if (scene.nodeTypes[i] == NodeType.Spawn_Player) {
          playerSpawnPoints.add(i);
          continue;
        }
    }
  }

  int getRandomItemType() => randomItem(const [
    GameObjectType.Weapon_Shotgun,
    GameObjectType.Weapon_Handgun,
    GameObjectType.Weapon_Blade,
    GameObjectType.Weapon_Bow,
    GameObjectType.Weapon_Staff,
  ]);

  @override
  void customUpdate() {
    for (final character in characters) {
      if (character.alive) {
        continue;
      }
      if (character is AI) {
          if
          (character.respawn-- <= 0)
            respawnAI(character);
      }
    }
  }

  @override
  void customOnPlayerWeaponReady(Player player){
    // if (player.weapon == player.weaponSlot2){
    //   playerSetWeapon(player, player.weaponSlot1);
    // }
  }

  void respawnAI(AI ai){
    ai.respawn = configAIRespawnFrames;
    ai.health = ai.maxHealth;
    ai.state = CharacterState.Spawning;
    ai.collidable = true;
    ai.stateDurationRemaining = 30;
    moveV3ToNodeIndex(ai, ai.spawnNodeIndex);
  }

  @override
  void customUpdatePlayer(Player player) {
    if (player.idling){
      final diff = Direction.getDifference(player.lookDirection, player.faceDirection);
      if (diff >= 2){
        player.faceAngle += piQuarter;
      } else if (diff <= -3) {
        player.faceAngle -= piQuarter;
      }
    }
  }

  @override
  Player spawnPlayer() {
    final player = Player(
      game: this,
      team: 0,
      weapon: Weapon(
        type: AttackType.Staff,
        damage: 5,
        capacity: 1000,
        duration: 10,
        range: 200,
      ),
    );
    player.weaponSlot1 = Weapon(
      type: AttackType.Staff,
      damage: 5,
      capacity: 1000,
      duration: 10,
      range: 200,
    );
    player.equippedLegs = randomItem(LegType.values);
    player.equippedArmour = randomItem(BodyType.values);
    player.equippedHead = randomItem(HeadType.values);
    return player;
  }

  @override
  void customInitPlayer(Player player) {
    player.writeEnvironmentShade(Shade.Very_Very_Dark);
    player.writeEnvironmentRain(Rain.Light);
    player.writeEnvironmentLightning(Lightning.Off);
    player.writeEnvironmentWind(Wind.Gentle);
    player.writeEnvironmentBreeze(false);
    // player.writePlayerMessage("press W,A,S,D to run and LEFT CLICK to punch");
    if
    (playerSpawnPoints.isNotEmpty) {
      moveV3ToNodeIndex(player, randomItem(playerSpawnPoints));
    }
  }

  @override
  void customOnCollisionBetweenPlayerAndGameObject(Player player, GameObject gameObject) {
    if (gameObject.type == GameObjectType.Weapon_Shotgun){
      deactivateGameObject(gameObject, duration: configRespawnFramesWeapons);
      gameObject.type = getRandomItemType();
      final weapon = buildWeaponShotgun();
      playerSetWeapon(player, weapon);
      weapon.spawn = gameObject;
      player.weaponSlot1 = weapon;
      player.writePlayerEventItemEquipped(weapon.type);
      player.writePlayerMessage("left click to fire shotgun");
      return;
    }

    if (gameObject.type == GameObjectType.Weapon_Handgun){
      deactivateGameObject(gameObject, duration: configRespawnFramesWeapons);
      gameObject.type = getRandomItemType();
      final weapon = buildWeaponHandgun();
      weapon.spawn = gameObject;
      player.weaponSlot1 = weapon;
      playerSetWeapon(player, weapon);
      player.writePlayerEventItemEquipped(weapon.type);
      player.writePlayerEventItemEquipped(weapon.type);
      player.writePlayerMessage("left click to fire handgun");
      return;
    }

    if (gameObject.type == GameObjectType.Weapon_Blade){
      deactivateGameObject(gameObject, duration: configRespawnFramesWeapons);
      gameObject.type = getRandomItemType();
      final weapon = buildWeaponBlade();
      if (player.weapon == player.weaponSlot2){
        playerSetWeapon(player, weapon);
      }
      weapon.spawn = gameObject;
      player.weaponSlot2 = weapon;
      player.writePlayerEventItemEquipped(weapon.type);
      player.writePlayerMessage("right click to use sword");
      return;
    }

    if (gameObject.type == GameObjectType.Weapon_Bow){
      deactivateGameObject(gameObject, duration: configRespawnFramesWeapons);
      gameObject.type = getRandomItemType();
      final weapon = buildWeaponBow();
      playerSetWeapon(player, weapon);
      weapon.spawn = gameObject;
      player.weaponSlot1 = weapon;
      player.writePlayerEventItemEquipped(weapon.type);
      player.writePlayerMessage("left click to use bow");
      return;
    }

    if (gameObject.type == GameObjectType.Weapon_Staff){
      deactivateGameObject(gameObject, duration: configRespawnFramesWeapons);
      gameObject.type = getRandomItemType();
      final weapon = buildWeaponStaff();
      playerSetWeapon(player, weapon);
      weapon.spawn = gameObject;
      player.weaponSlot1 = weapon;
      player.writePlayerEventItemEquipped(weapon.type);
      player.writePlayerMessage("left click to use staff");
      return;
    }
  }

  @override
  void customOnPlayerRevived(Player player){
    movePlayerToCrystal(player);
  }

  @override
  void customOnPlayerWeaponRoundsExhausted(Player player, Weapon weapon){
    if (weapon == player.weaponSlot1){
      player.weaponSlot1 = player.weaponSlot3; // unarmed
      playerSetWeapon(player, player.weaponSlot2);
    }
    if (weapon == player.weaponSlot2){
      player.weaponSlot2 = player.weaponSlot3; // unarmed
      playerSetWeapon(player, player.weaponSlot1);
    }
  }

  @override
  void customOnPlayerWeaponChanged(Player player, Weapon newWeapon, Weapon previousWeapon){
    // reactiveWeaponGameObject(previousWeapon);
  }

  /// safe to overridable
  void customOnPlayerDeath(Player player) {
    reactivatePlayerWeapons(player);
    player.weapon = buildWeaponUnarmed();
    player.weaponSlot1 = player.weapon;
    player.weaponSlot2 = player.weapon;
    player.weaponSlot3 = player.weapon;
  }

  @override
  void customOnPlayerDisconnected(Player player) {

  }

  void reactivatePlayerWeapons(Player player){
  }

  void reactiveWeaponGameObject(Weapon weapon){
    final previousWeaponSpawn = weapon.spawn;
    if (previousWeaponSpawn is GameObject) {
      reactivateGameObject(previousWeaponSpawn);
    }
  }

  reactivateGameObject(GameObject gameObject){
    gameObject.active = true;
    gameObject.collidable = true;
    gameObject.type = getRandomItemType();
  }
}