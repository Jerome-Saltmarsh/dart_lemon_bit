

import 'package:lemon_math/library.dart';

import '../classes/Game.dart';
import '../classes/Player.dart';
import '../common/SlotType.dart';
import '../scene_generator.dart';

class GameRandom extends Game {
  var time = 12 * 60 * 60;
  final int maxPlayers;

  GameRandom({required this.maxPlayers}) : super(
      generateRandomScene(
        columns: 100,
        rows: 100,
        seed: random.nextInt(2000),
      )
  );

  bool get full => players.length >= maxPlayers;
  bool get empty => players.length <= 0;

  @override
  void update() {
    time = (time + 1) % Duration.secondsPerDay;
    if (time % 180 == 0 && numberOfAliveZombies < 30){
      spawnRandomZombie();
    }
  }

  @override
  int getTime() {
    return time;
  }

  Player spawnPlayer() {
      final player = Player(
        game: this,
        weapon: SlotType.Empty,
        x: 500,
        y: 500,
      );
      player.techTree.bow = 2;
      player.techTree.pickaxe = 2;
      player.techTree.hammer = 2;
      final spawnLocation = randomItem(scene.spawnPointPlayers);
      player.x = spawnLocation.x;
      player.y = spawnLocation.y;
      return player;
  }
}