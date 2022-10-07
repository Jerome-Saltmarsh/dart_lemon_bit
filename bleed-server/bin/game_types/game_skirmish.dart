

import 'package:lemon_math/library.dart';

import '../classes/gameobject.dart';
import '../classes/library.dart';
import '../common/attack_state.dart';
import '../common/control_scheme.dart';
import '../common/library.dart';
import '../common/node_size.dart';
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
/// [ ] melee weapons run out of rounds but only on hit
/// [ ] custom websocket address
/// [ ] multiple spawn points
/// [ ] spawn weapons
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
          spawnZombieAtIndex(i);
          continue;
        }
        if (scene.nodeTypes[i] == NodeType.Spawn_Weapon) {
          spawnGameObjectAtIndex(index: i, type: GameObjectType.Weapon_Shotgun);
          continue;
        }
    }
  }

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
      final diff = Direction.getDifference(player.aimDirection, player.faceDirection);
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
  void customOnCollisionBetweenColliders(Collider a, Collider b) {

  }

  @override
  void customOnCollisionBetweenPlayerAndOther(Player player, Collider other){
    if (other is GameObjectWeapon){
      deactivateGameObject(other);
      final weapon = buildWeaponByType(other.weaponType);
      weapon.spawn = other;
      playerSetWeapon(player, weapon);
    }
  }

  void playerSetWeapon(Player player, Weapon weapon){
    player.weapon.spawn = null;
    player.weapon = weapon;
    player.writePlayerWeaponType();
    player.writePlayerWeaponRounds();
    player.writePlayerWeaponCapacity();
    player.writePlayerEventItemEquipped(player.weapon.type);
  }

  @override
  void customOnCharacterKilled(Character target, src) {
    if (target is AI) {
       target.respawn = 500;
    }
  }

  @override
  void customOnPlayerRevived(Player player){
    movePlayerToCrystal(player);
  }

  @override
  void handlePlayerControlSchemeA({
    required Player player,
    required int direction,
    required bool perform1,
    required bool perform2,
    required bool perform3,
    required double mouseX,
    required double mouseY,
    required double screenLeft,
    required double screenTop,
    required double screenRight,
    required double screenBottom,
  }){
    player.framesSinceClientRequest = 0;
    player.screenLeft = screenLeft;
    player.screenTop = screenTop;
    player.screenRight = screenRight;
    player.screenBottom = screenBottom;
    player.mouse.x = mouseX;
    player.mouse.y = mouseY;

    if (player.deadOrBusy) return;

    playerRunInDirection(player, direction);
    playerUpdateAimTarget(player);

    final weapon = player.weapon;

    if (weapon.durationRemaining > 0) return;
    weapon.state = AttackState.Aiming;

    if (perform1) {
      playerUseWeapon(player, weapon);
      player.writePlayerWeaponRounds();

      if (weapon.requiresRounds) {
         if (weapon.rounds == 0) {
            playerSetWeapon(player, buildWeaponUnarmed());
         }
      }
    }
  }
}