import '../classes/Character.dart';
import '../classes/Game.dart';
import '../classes/Npc.dart';
import '../classes/Player.dart';
import '../classes/Weapon.dart';
import '../common/Quests.dart';
import '../common/WeaponType.dart';
import '../instances/scenes.dart';
import '../state.dart';

const int _framesPerZombieSpawn = 10;
const int _maxZombies = 20;

class WildernessWest01 extends Game {

  late Npc boss;

  WildernessWest01() : super(scenes.wildernessWest01){
    boss = Npc(x: 0, y: 300, health: 100, weapon: Weapon(type: WeaponType.Unarmed, damage: 1));
    // zombies.add(boss);
  }

  @override
  void update() {
    if (frame % _framesPerZombieSpawn != 0) return;
    if (zombieCount > _maxZombies) return;
    spawnRandomZombieLevel(1);
  }

  @override
  void onKilledBy(Character target, Character by) {
    if (target != boss) return;
    if (by is Player){
      _onBossKilledBy(by);
    }
  }

  void _onBossKilledBy(Player player){
    if (player.questMain.index <= MainQuest.Kill_Zombie_Boss.index){
      player.questMain = MainQuest.Kill_Zombie_Boss_Talk_To_Smith;
    }
  }
}
