
import '../classes/game.dart';
import '../classes/player.dart';
import '../classes/scene.dart';
import '../classes/weapon.dart';
import '../common/control_scheme.dart';
import '../common/library.dart';
import '../functions/move_player_to_crystal.dart';

class GameSkirmish extends Game {

  @override
  int get controlScheme => ControlScheme.schemeA;

  @override
  int get gameType => GameType.Skirmish;

  GameSkirmish({required Scene scene}) : super(scene);

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
    movePlayerToCrystal(player);
  }
}