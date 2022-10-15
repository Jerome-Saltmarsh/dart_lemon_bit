import 'package:gamestream_flutter/game_state.dart';
import 'package:lemon_engine/engine.dart';


class GameStream {

  static void clearGameState() {
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