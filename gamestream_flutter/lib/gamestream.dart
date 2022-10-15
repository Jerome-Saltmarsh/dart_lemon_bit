import 'package:bleed_common/GameType.dart';
import 'package:gamestream_flutter/game_state.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_watch/watch.dart';

import 'isometric/game.dart';
import 'modules/modules.dart';

final gamestream = GameStream();

class GameStream {
  final gameType = Watch<int?>(null, onChanged: onChangedGameType);

  void onError(Object error, StackTrace stack){
    print(error.toString());
    print(stack);
    core.state.error.value = error.toString();
  }

  static void onChangedGameType(int? value){
    print("gamestream.onChangedGameType(${GameType.getName(value)})");
    if (value == null) {
      return;
    }
    game.edit.value = value == GameType.Editor;
    game.timeVisible.value = GameType.isTimed(value);
    game.mapVisible.value = value == GameType.Dark_Age;
    Engine.fullScreenEnter();
  }

  void clearGameState() {
    GameState.player.x = -1;
    GameState.player.y = -1;
    GameState.totalZombies = 0;
    GameState.totalPlayers = 0;
    GameState.totalProjectiles = 0;
    GameState.totalNpcs = 0;
    GameState.particleEmitters.clear();
    GameState.particles.clear();
    GameState.player.gameDialog.value = null;
    GameState.player.npcTalkOptions.value = [];
    GameState.player.npcTalk.value = null;
    Engine.zoom = 1;
    Engine.redrawCanvas();
  }
}