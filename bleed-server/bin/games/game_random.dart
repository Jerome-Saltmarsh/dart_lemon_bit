

import 'package:lemon_math/library.dart';

import '../classes/Game.dart';
import '../classes/Player.dart';
import '../common/library.dart';
import '../scene_generator.dart';

/// Spawn somewhere on the map, select one of several characters
/// Warrior
/// Wizard
/// Gunslinger
/// Archer
///
/// There's no goal except to explore the map, kill other players and
/// Find treasure
class GameRandom extends Game {
  var time = 12 * 60 * 60;
  final int maxPlayers;

  GameRandom({required this.maxPlayers}) : super(
      generateRandomScene(
        columns: 100,
        rows: 100,
        seed: random.nextInt(2000),
      ),
     gameType: GameType.RANDOM,
      status: GameStatus.In_Progress
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

  @override
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
      player.techTree.axe = 4;
      final spawnLocation = randomItem(scene.spawnPointPlayers);
      player.x = spawnLocation.x;
      player.y = spawnLocation.y;
      return player;
  }

  @override
  void onPlayerJoined(Player player){
    player.health = 0;
    player.writeByte(ServerResponse.Game_Status);
    player.writeByte(GameStatus.Select_Character.index);
  }
}