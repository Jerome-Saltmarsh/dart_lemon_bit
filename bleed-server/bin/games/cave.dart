import '../classes/Character.dart';
import '../classes/Game.dart';
import '../classes/Npc.dart';
import '../classes/Player.dart';
import '../common/Quests.dart';
import '../instances/scenes.dart';

class WildernessWest01 extends Game {

  late Npc boss;

  WildernessWest01() : super(scenes.wildernessWest01, 64){
    boss = Npc(x: 0, y: 300, health: 100);
    zombies.add(boss);
  }

  @override
  void onPlayerKilled(Player player) {
    // TODO: implement onPlayerKilled
  }

  @override
  void update() {
    // TODO: implement update
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
