

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

  }

  @override
  Player spawnPlayer() {
    final player = Player(
      game: this,
      team: 0,
      weapon: Weapon(
        type: AttackType.Bow,
        damage: 5,
        capacity: 1000,
        duration: 10,
        range: 200,
      ),
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
      player.writePlayerEventItemEquipped(weapon.type);
      return;
    }

    if (gameObject.type == GameObjectType.Weapon_Handgun){
      deactivateGameObject(gameObject, duration: configRespawnFramesWeapons);
      gameObject.type = getRandomItemType();
      final weapon = buildWeaponHandgun();
      weapon.spawn = gameObject;
      playerSetWeapon(player, weapon);
      player.writePlayerEventItemEquipped(weapon.type);
      player.writePlayerEventItemEquipped(weapon.type);
      return;
    }

    if (gameObject.type == GameObjectType.Weapon_Blade){
      deactivateGameObject(gameObject, duration: configRespawnFramesWeapons);
      gameObject.type = getRandomItemType();
      final weapon = buildWeaponBlade();
      weapon.spawn = gameObject;
      playerSetWeapon(player, weapon);
      player.writePlayerEventItemEquipped(weapon.type);
      player.writePlayerEventItemEquipped(weapon.type);
      return;
    }

    if (gameObject.type == GameObjectType.Weapon_Bow){
      deactivateGameObject(gameObject, duration: configRespawnFramesWeapons);
      gameObject.type = getRandomItemType();
      final weapon = buildWeaponBow();
      playerSetWeapon(player, weapon);
      weapon.spawn = gameObject;
      player.writePlayerEventItemEquipped(weapon.type);
      return;
    }

    if (gameObject.type == GameObjectType.Weapon_Staff){
      deactivateGameObject(gameObject, duration: configRespawnFramesWeapons);
      gameObject.type = getRandomItemType();
      final weapon = buildWeaponStaff();
      playerSetWeapon(player, weapon);
      weapon.spawn = gameObject;
      player.writePlayerEventItemEquipped(weapon.type);
      return;
    }
  }

  @override
  void customOnPlayerRevived(Player player){
    movePlayerToCrystal(player);
  }

  @override
  void customOnPlayerWeaponRoundsExhausted(Player player, Weapon weapon){

  }

  @override
  void customOnPlayerWeaponChanged(Player player, Weapon newWeapon, Weapon previousWeapon){
    // reactiveWeaponGameObject(previousWeapon);
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

  void customOnCharacterKilled(Character target, dynamic src) {
      spawnGameObjectAtXYZ(
        x: target.x,
        y: target.y,
        z: target.z,
        type: GameObjectType.Weapon_Shotgun,
      );
  }
}