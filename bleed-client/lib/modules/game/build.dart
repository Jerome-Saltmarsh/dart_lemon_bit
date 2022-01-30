
import 'package:bleed_client/common/GameStatus.dart';
import 'package:bleed_client/common/GameType.dart';
import 'package:bleed_client/flutterkit.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/ui/compose/hudUI.dart';
import 'package:bleed_client/ui/dialogs.dart';
import 'package:bleed_client/ui/state/hud.dart';
import 'package:bleed_client/ui/style.dart';
import 'package:bleed_client/ui/views.dart';
import 'package:flutter/cupertino.dart';
import 'package:lemon_watch/watch_builder.dart';

import '../../toString.dart';
import 'state.dart';

class GameBuild {

  final GameState state;
  GameBuild(this.state);

  Widget buildUIGame() {
    return WatchBuilder(game.player.uuid, (String uuid) {
      if (uuid.isEmpty) {
        return buildLayoutLoadingGame();
      }
      return WatchBuilder(state.status, (GameStatus gameStatus) {
        switch (gameStatus) {
          case GameStatus.Counting_Down:
            return buildDialog(
                width: style.dialogWidthMedium,
                height: style.dialogHeightMedium,
                child: WatchBuilder(game.countDownFramesRemaining, (int frames){
                  final seconds =  frames ~/ 30.0;
                  return Center(child: text("Starting in $seconds seconds"));
                }));
          case GameStatus.Awaiting_Players:
            return buildLayoutLobby() ;
          case GameStatus.In_Progress:
            switch (game.type.value) {
              case GameType.MMO:
                return buildHud.playerCharacterType();
              case GameType.Custom:
                return buildHud.playerCharacterType();
              case GameType.Moba:
                return buildHud.playerCharacterType();
              case GameType.BATTLE_ROYAL:
                return buildHud.playerCharacterType();
              case GameType.CUBE3D:
                return buildUI3DCube();
              default:
                return text(game.type.value);
            }
          case GameStatus.Finished:
            return buildDialogGameFinished();
          default:
            return text(enumString(gameStatus));
        }
      });
    });
  }
}