
import '../classes/gameobject.dart';
import '../classes/library.dart';
import '../classes/node.dart';
import '../common/control_scheme.dart';
import '../common/library.dart';
import '../common/spawn_type.dart';
import '../common/teams.dart';
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
class GameSkirmish extends Game {

  @override
  int get controlScheme => ControlScheme.schemeA;

  @override
  int get gameType => GameType.Skirmish;

  GameSkirmish({required Scene scene}) : super(scene) {
     foreachNodeSpawn(spawnZom);
  }

  void spawnZom(NodeSpawn node) {
     switch(node.spawnType){
       case SpawnType.Zombie:
         spawnZombieAtNodeSpawn(
           node: node,
           health: 5,
           team: Teams.evil,
           damage: 1,
           respawnDuration: 500,
         );
         break;
       case SpawnType.Random_Item:
         gameObjects.add(
           GameObjectShotgun(
               x: node.x,
               y: node.y,
               z: node.z,
           )
         );
         break;
     }
  }


  @override
  void customUpdate() {

  }

  @override
  int getTime() => 0;

  @override
  Player spawnPlayer() {
    return Player(game: this, weapon: buildWeaponUnarmed());
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
  void customOnCharacterKilled(Character target, src) {
    if (target is AI) {
       target.respawn = 500;
    }
  }
}