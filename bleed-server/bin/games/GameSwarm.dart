
import '../classes/DynamicObject.dart';
import '../classes/Game.dart';
import '../classes/Player.dart';
import '../classes/Structure.dart';
import '../common/DynamicObjectType.dart';
import '../common/SlotType.dart';
import '../engine.dart';

class GameSwarm extends Game {
  var level = 0;
  var timer = 200;
  var swarming = false;

  late Structure tower1;
  late Structure tower2;

  GameSwarm() : super(engine.scenes.skirmish) {
    dynamicObjects.add(DynamicObject(
        type: DynamicObjectType.Rock,
        x: 500,
        y: 2250,
        health: 50,
    ));
  }

  @override
  void update() {

    if (swarming) {
       if (timer % 100 == 0) {
          spawnRandomZombie(
            health: 1,
          );
       }
    }

    if (players.isNotEmpty) {
      final player = players[0];
      for (final zombie in zombies) {
          zombie.target = player;
      }
    }

    if (timer-- > 0) return;

    if (swarming) {
      timer = 300;
    } else {
      level++;
      timer = 1000;
    }
    swarming = !swarming;
  }

  @override
  int getTime() {
    return 12 * 60 * 60;
  }

  Player spawnPlayer() {
     final player = Player(game: this, weapon: SlotType.Bow_Wooden);
     player.x = 317;
     player.y = 2136;
     tower1 = Structure(x: 350, y: 2250, team: player.team, attackRate: 200, attackDamage: 1);
     tower2 = Structure(x: 450, y: 2250, team: player.team, attackRate: 200, attackDamage: 1);
     structures.add(tower1);
     structures.add(tower2);
     return player;
  }
}