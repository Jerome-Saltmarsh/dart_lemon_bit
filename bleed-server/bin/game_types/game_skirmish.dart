

import 'package:lemon_math/library.dart';

import '../classes/gameobject.dart';
import '../classes/library.dart';
import '../common/control_scheme.dart';
import '../common/library.dart';
import '../functions/move_player_to_crystal.dart';


class GameSkirmish extends Game {

  static const configAIRespawnFrames = 500;
  var configMaxPlayers = 7;
  var configZombieHealth = 5;

  List<int> playerSpawnPoints = [];

  @override
  int get controlScheme => ControlScheme.schemeA;

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
  ]);

  @override
  void customUpdate() {
    for (final character in characters) {
      if (character.alive) continue;
      if (character is AI) {
        if (character.respawn-- <= 0)
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
    final player = Player(game: this, weapon: buildWeaponUnarmed(), team: 0);
    player.equippedPants = randomItem(PantsType.values);
    player.equippedArmour = randomItem(ArmourType.values);
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
    player.writePlayerMessage("Press W,A,S,D to run");
    // movePlayerToCrystal(player);
    if (playerSpawnPoints.isNotEmpty){
      moveV3ToNodeIndex(player, randomItem(playerSpawnPoints));
    }
    player.writePlayerPosition();
    player.writePlayerEvent(PlayerEvent.Player_Moved);
  }

  @override
  void customOnCollisionBetweenPlayerAndGameObject(Player player, GameObject gameObject) {
    if (gameObject.type == GameObjectType.Weapon_Shotgun){
      deactivateGameObject(gameObject);
      final weapon = buildWeaponByType(AttackType.Shotgun);
      weapon.spawn = gameObject;
      player.weaponSlot1 = weapon;
      playerSetWeapon(player, weapon);
      player.writePlayerEventItemEquipped(weapon.type);
      player.writePlayerMessage("left click to fire shotgun");
    }

    if (gameObject.type == GameObjectType.Weapon_Handgun){
      deactivateGameObject(gameObject);
      final weapon = buildWeaponByType(AttackType.Handgun);
      weapon.spawn = gameObject;
      player.weaponSlot1 = weapon;
      playerSetWeapon(player, weapon);
      player.writePlayerEventItemEquipped(weapon.type);
      player.writePlayerEventItemEquipped(weapon.type);
      player.writePlayerMessage("left click to fire handgun");
    }

    if (gameObject.type == GameObjectType.Weapon_Blade){
      deactivateGameObject(gameObject);
      final weapon = buildWeaponByType(AttackType.Blade);
      weapon.spawn = gameObject;
      player.weaponSlot2 = weapon;
      player.writePlayerEventItemEquipped(weapon.type);
      player.writePlayerMessage("right click to use sword");
    }
  }

  @override
  void customOnPlayerRevived(Player player){
    movePlayerToCrystal(player);
  }

  @override
  void customOnPlayerWeaponRoundsExhausted(Player player, Weapon weapon){
    reactiveWeaponGameObject(weapon);
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
    reactivatePlayerWeapons(player);
  }

  void reactivatePlayerWeapons(Player player){
    reactiveWeaponGameObject(player.weaponSlot1);
    reactiveWeaponGameObject(player.weaponSlot2);
    reactiveWeaponGameObject(player.weaponSlot3);
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