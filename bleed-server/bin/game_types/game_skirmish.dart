

import 'package:lemon_math/library.dart';

import '../classes/gameobject.dart';
import '../classes/library.dart';
import '../common/control_scheme.dart';
import '../common/library.dart';
import '../functions/move_player_to_crystal.dart';

/// a very simple game
/// the player picks one of five characters
/// each character has predetermined weapons
///
/// alternatively each player spawns with a default weapon and roams the map
/// to find equipment
/// i do not know which is better
///
/// weapon can be single handed or two handed
///
/// two single handed weapons may be equipped at the same time
///
/// these can also be used at the same time
///
/// a heavy weapon may only be used by both hands
///
/// like diablo 2 the player has two different weapon slots
///
/// these can be swapped by pressing
///
/// duel pistols may be wielded
///
/// or a sword and a shield
///
/// or a sword and a pistol
///
/// it may be better without the space key
/// [IDEAS]
/// [ ] player can jump
/// [ ] start losing health if energy gets too low
/// [ ] shield item
/// [ ] grenade item
/// [ ] accuracy decreased while running
/// [ ] enemies drop magic orbs required for powers
/// [ ] running backwards is slower
/// [ ] modify animations editor

/// [AQUARIUS]
/// Design character fish
/// Swim around and explore the acquarium
/// Meet other fish
/// Fish automatically swims towards the mouse
/// It also automatically starts sinking
/// Hold mouse down to swim up
/// [ ] right click to unleash the weapons special
/// [ ] weapon special gets charged whenever an enemy is hit or killed
/// [ ] unarmed has amount but automatically recharges
/// [ ] the lower the bar the less damage is also incurred
/// [ ] the weapon special can be unleashed before it is full but the effect is less

/// [RELEASE 1.10]
/// [ ] slime death animation 1
/// [ ] slime death animation 2
/// [ ] zombie death animation 1
/// [ ] zombie death animation 2
/// [ ] zombie death animation 3

/// [RELEASE 1.00]
/// [ ] build scene
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
/// [ ] fix see through house when inside
/// [ ] center camera on player on spawn
/// [ ] melee weapons run out of rounds but only on hit
/// [ ] custom websocket address
/// [ ] fix editor camera stutters on selected
/// [ ] spawn handgun, blade, machine-gun, bazooka, land-mine, smg, sniper-rifle, body-armour
/// [ ] multiple spawn points
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

  @override
  int get controlScheme => ControlScheme.schemeA;

  @override
  int get gameType => GameType.Skirmish;

  GameSkirmish({required Scene scene}) : super(scene) {

    final volume = scene.gridVolume;
    for (var i = 0; i < volume; i++){
        if (scene.nodeTypes[i] == NodeType.Spawn) {
          final instance = spawnZombieAtIndex(i);
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
    }
  }

  int getRandomItemType() => randomItem(const [
    GameObjectType.Weapon_Shotgun,
    GameObjectType.Weapon_Handgun,
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
    final player = Player(game: this, weapon: buildWeaponBlade(), team: 0);
    player.equippedPants = randomItem(PantsType.values);
    player.equippedArmour = randomItem(ArmourType.values);
    player.equippedHead = randomItem(HeadType.values);
    return player;
  }

  @override
  void customInitPlayer(Player player) {
    player.writeEnvironmentShade(Shade.Very_Dark);
    player.writeEnvironmentRain(Rain.Light);
    player.writeEnvironmentLightning(Lightning.Off);
    player.writeEnvironmentWind(Wind.Gentle);
    player.writeEnvironmentBreeze(false);
    movePlayerToCrystal(player);
  }

  @override
  void customOnCollisionBetweenPlayerAndGameObject(Player player, GameObject gameObject) {
    if (gameObject.type == GameObjectType.Weapon_Shotgun){
      deactivateGameObject(gameObject);
      final weapon = buildWeaponByType(AttackType.Shotgun);
      weapon.spawn = gameObject;
      playerSetWeapon(player, weapon);
    }

    if (gameObject.type == GameObjectType.Weapon_Handgun){
      deactivateGameObject(gameObject);
      final weapon = buildWeaponByType(AttackType.Handgun);
      weapon.spawn = gameObject;
      playerSetWeapon(player, weapon);
    }
  }

  @override
  void customOnPlayerRevived(Player player){
    movePlayerToCrystal(player);
  }

  @override
  void customOnPlayerWeaponRoundsExhausted(Player player, Weapon weapon){
    playerSetWeaponUnarmed(player);
  }

  @override
  void customOnPlayerWeaponChanged(Player player, Weapon newWeapon, Weapon previousWeapon){
    final previousWeaponSpawn = previousWeapon.spawn;
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