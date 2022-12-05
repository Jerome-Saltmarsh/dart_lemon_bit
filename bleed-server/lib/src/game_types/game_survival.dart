import 'package:bleed_server/gamestream.dart';

class GameSurvival extends Game {

  GameSurvival(Scene scene) : super(scene);

  @override
  int get gameType => GameType.Survival;

  @override
  Player spawnPlayer() {
    return Player(game: this, weaponType: ItemType.Weapon_Melee_Knife);
  }
}