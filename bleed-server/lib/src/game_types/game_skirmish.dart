

import 'package:bleed_server/gamestream.dart';
import 'package:bleed_server/src/classes/src/game_environment.dart';
import 'package:bleed_server/src/classes/src/game_time.dart';
import 'package:lemon_math/functions/random_item.dart';

class GameSkirmish extends Game {
  GameSkirmish({
    required super.scene,
  }) : super(
      gameType: GameType.Skirmish,
      time: GameTime(enabled: false, hour: 15, minute: 30),
      environment: GameEnvironment(),
      options: GameOptions(perks: false, inventory: false),
  );

  @override
  void customOnPlayerJoined(Player player) {
      moveToRandomPlayerSpawnPoint(player);

      player.headType = randomItem(const [
        ItemType.Head_Swat,
        ItemType.Head_Steel_Helm,
        ItemType.Head_Rogues_Hood,
        ItemType.Head_Wizards_Hat,
      ]);
  }
}