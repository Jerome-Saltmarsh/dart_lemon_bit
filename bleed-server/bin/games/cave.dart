import 'package:lemon_math/diff_over.dart';

import '../classes/Character.dart';
import '../classes/Game.dart';
import '../classes/Npc.dart';
import '../classes/Player.dart';
import '../common/Quests.dart';
import '../common/classes/Vector2.dart';
import '../instances/scenes.dart';
import '../values/world.dart';

class Cave extends Game {

  late Npc boss;

  Cave() : super(scenes.cave, 64){
    boss = Npc(x: 0, y: 300, health: 100);
    zombies.add(boss);
  }

  @override
  Player doSpawnPlayer() {
    // TODO: implement doSpawnPlayer
    throw UnimplementedError();
  }

  @override
  void onPlayerKilled(Player player) {
    // TODO: implement onPlayerKilled
  }

  @override
  void update() {
    // TODO: implement update

    // 318 324
    double radius = 10;
    for(int i = 0; i < players.length; i++){
      Player player = players[i];
      if (diffOver(player.x, 318, radius)) continue;
      if (diffOver(player.y, 324, radius)) continue;
      changeGame(player, world.town);
      i--;
    }
  }

  @override
  Vector2 getSpawnPositionFrom(Game from) {
    return Vector2(308, 338);
  }

  @override
  void onKilledBy(Character target, Character by) {
    if (target == boss && by is Player){
      if (by.questMain.index <= MainQuest.Kill_Zombie_Boss.index){
        by.questMain = MainQuest.Kill_Zombie_Boss_Talk_To_Smith;
      }
    }
  }
}
