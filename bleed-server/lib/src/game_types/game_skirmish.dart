

import 'package:bleed_server/gamestream.dart';
import 'package:bleed_server/src/classes/src/game_environment.dart';
import 'package:bleed_server/src/classes/src/game_time.dart';

class GameSkirmish extends Game {
  GameSkirmish({
    required super.scene,
  }) : super(
      gameType: GameType.Skirmish,
      time: GameTime(enabled: false, hour: 15),
      environment: GameEnvironment(),
      options: GameOptions(perks: false, inventory: false),
  );

  @override
  void customOnPlayerJoined(Player player) {

  }
}