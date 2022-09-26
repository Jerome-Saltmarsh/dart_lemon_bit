

import 'package:lemon_math/library.dart';

import '../classes/gameobject.dart';
import '../classes/library.dart';
import '../common/attack_state.dart';
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
///
/// TODO
/// [ ] 3d model weapon sword
/// [ ] 3d model weapon staff
/// [ ] 3d model weapon assault rifle
/// [ ] 3d model weapon sniper rifle
/// [ ] 3d model weapon revolver
/// [ ] 3d model weapon flame thrower
/// [ ] build scene
/// [ ] multiple spawn points
/// [ ] Fix bug player faces forward automatically on release arrow key
/// [x] Disable player chat
/// [x] Disable open map or quest dialog
/// [x] Players join same game (max 7)
/// [x] UI Weapon Information
/// [x] item acquired audio
/// [x] drop weapon on no ammo
///
class GameSkirmish extends Game {

  static const maxPlayers = 7;

  @override
  int get controlScheme => ControlScheme.schemeA;

  @override
  int get gameType => GameType.Skirmish;

  GameSkirmish({required Scene scene}) : super(scene) {
     foreachNodeSpawn(spawnNodeInstance);
  }

  @override
  void customUpdate() {

  }

  @override
  int getTime() => 0;

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
      playerSetWeapon(player, buildWeaponByType(other.weaponType));
    }
  }

  void playerSetWeapon(Player player, Weapon weapon){
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

    if (player.weapon.durationRemaining > 0) return;
    player.weapon.state = AttackState.Aiming;

    if (perform1) {
      playerUseWeapon(player, player.weapon);
      player.writePlayerWeaponRounds();

      if (player.weapon.requiresRounds) {
         if (player.weapon.rounds == 0) {
            playerSetWeapon(player, buildWeaponUnarmed());
         }
      }
    }
  }
}