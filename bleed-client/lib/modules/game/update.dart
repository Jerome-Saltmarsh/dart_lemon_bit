
import 'package:bleed_client/common/GameStatus.dart';
import 'package:bleed_client/common/GameType.dart';
import 'package:bleed_client/functions/cameraFollowPlayer.dart';
import 'package:bleed_client/input.dart';
import 'package:bleed_client/modules/modules.dart';
import 'package:bleed_client/send.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/update.dart';
import 'package:bleed_client/webSocket.dart';

class GameUpdate {

  void update() {
    if (!webSocket.connected) return;
    if (game.player.uuid.value.isEmpty) return;

    switch(game.type.value){
      case GameType.None:
        break;
      case GameType.Custom:
        _updateBleed();
        break;
      case GameType.MMO:
        _updateBleed();
        break;
      case GameType.Moba:
        _updateBleed();
        break;
      case GameType.BATTLE_ROYAL:
        _updateBleed();
        break;
      case GameType.CUBE3D:
        sendRequestUpdateCube3D();
        break;
      default:
        throw Exception("No update for ${game.type.value}");
    }
  }

  void _updateBleed(){
    if (game.status.value == GameStatus.Finished) return;

    game.framesSinceEvent++;
    readPlayerInput();
    isometric.update.updateParticles();
    isometric.update.deadZombieBlood();
    if (!panningCamera && game.player.alive.value) {
      cameraFollowPlayer();
    }
    updateParticleEmitters();
    sendRequestUpdatePlayer();
  }
}