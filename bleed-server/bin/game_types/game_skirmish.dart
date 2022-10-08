

import 'package:lemon_math/library.dart';

import '../classes/gameobject.dart';
import '../classes/library.dart';
import '../common/control_scheme.dart';
import '../common/library.dart';
import '../functions/move_player_to_crystal.dart';

/// [IDEAS]
/// [ ] player can jump
/// [ ] start losing health if energy gets too low
/// [ ] shield item
/// [ ] grenade item
/// [ ] accuracy decreased while running
/// [ ] enemies drop magic orbs required for powers
/// [ ] running backwards is slower
/// [ ] modify animations editor
/// [ ] single handed weapons can be duel wielded like sword and shield
/// [ ] melee weapons run out and automatically recharges

/// [RELEASE 1.10]
/// [ ] slime death animation 1
/// [ ] slime death animation 2
/// [ ] zombie death animation 1
/// [ ] zombie death animation 2
/// [ ] zombie death animation 3

/// [RELEASE 1.00]
/// [ ] auto connect to firestorm on first visit
/// [ ] 3d model weapon sword
/// [ ] 3d model weapon staff
/// [ ] 3d model weapon assault rifle
/// [ ] 3d model weapon sniper rifle
/// [ ] 3d model weapon revolver
/// [ ] 3d model shield
/// [ ] 3d model weapon flame thrower
/// [ ] 3d model spinning wireframe gem
/// [ ] particle type darkness
/// [ ] draw punch sprite
/// [ ] design mouse cursor
/// [ ] spawn bazooka,
/// [ ] spawn land-mine
/// [ ] spawn body-armour,
/// [ ] spawn hammer
/// [ ] spawn pick-axe
/// [ ] spawn assault-rifle,
/// [ ] spawn smg,
/// [ ] fix see through house when inside
/// [ ] fix handgun fire animation
/// [ ] fix editor camera stutters on selected
/// [ ] fire-storm build scene
/// [ ] edit fix change canvas size (HARD)
/// [ ] spawn sniper-rifle,
/// [ ] melee weapons run out of capacity

/// 08-10-2022
/// [x] zombie make audio on target spotted
/// [x] animate gameobject weapons up and down
/// [x] gameobject weapon-blade,
/// [x] fix center camera on player on spawn
/// [x] client on no message from server received dialog
/// [x] fix camera editor pans back to player
/// [x] fix editor navigation buttons
/// [x] recycle client grid node buffer
/// 07-10-2022
/// [x] fix editor respawn
/// [x] multiple player spawn points
/// [x] custom region
/// [x] spawn handgun,
/// [x] respawn weapon on empty
/// [x] fix prevent rain on grass slope
/// [x] prevent turn while attacking
/// [x] fix render window west
/// [x] spawn weapons
/// [x] fix render fence
/// [x] fix revive player falling in water
/// [x] fix brick render
/// [x] fix bug player not striking zombie
/// [x] enemies respawn after time
/// [x] fix bug dark age nodes stop rendering
/// [x] fix player color flicker
/// [x] fix spawn node
/// [x] fix dark-age controls
/// [x] fix set node
/// [x] fix rain falling color
/// [x] grass with flowers
/// [x] NodeOrientation: Radial
/// [x] fix save scene
/// [x] refactor - remove node class from backend
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
    }

    if (gameObject.type == GameObjectType.Weapon_Handgun){
      deactivateGameObject(gameObject);
      final weapon = buildWeaponByType(AttackType.Handgun);
      weapon.spawn = gameObject;
      player.weaponSlot1 = weapon;
      playerSetWeapon(player, weapon);
    }

    if (gameObject.type == GameObjectType.Weapon_Blade){
      deactivateGameObject(gameObject);
      final weapon = buildWeaponByType(AttackType.Blade);
      weapon.spawn = gameObject;
      player.weaponSlot2 = weapon;
      // playerSetWeapon(player, weapon);
    }
  }

  @override
  void customOnPlayerRevived(Player player){
    movePlayerToCrystal(player);
  }

  @override
  void customOnPlayerWeaponRoundsExhausted(Player player, Weapon weapon){
    if (weapon == player.weaponSlot1){
      player.weaponSlot1 = player.weaponSlot2; // unarmed
    }
    playerSetWeaponUnarmed(player);
  }

  @override
  void customOnPlayerWeaponChanged(Player player, Weapon newWeapon, Weapon previousWeapon){
    reactiveWeaponGameObject(previousWeapon);
  }

  @override
  void customOnPlayerDisconnected(Player player) {
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