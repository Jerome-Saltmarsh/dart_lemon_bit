
import '../classes/Game.dart';
import '../classes/Player.dart';
import '../classes/Structure.dart';
import '../common/SlotType.dart';
import '../engine.dart';

class GameSwarm extends Game {
  var level = 0;
  var timer = 200;
  var swarming = false;

  GameSwarm() : super(engine.scenes.skirmish);

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
     structures.add(Structure(x: 350, y: 2250, team: player.team, attackRate: 200));
     return player;
  }
}