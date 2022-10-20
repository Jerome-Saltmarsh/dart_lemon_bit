
import 'package:bleed_common/GameType.dart';
import 'package:gamestream_flutter/game_state.dart';
import 'package:gamestream_flutter/isometric/enums/game_dialog.dart';

void actionGameDialogShowQuests() {
  if (GameState.gameType.value != GameType.Dark_Age) return;

  if (GameState.player.gameDialog.value == GameDialog.Quests){
    GameState.player.gameDialog.value = null;
    return;
  }
  GameState.player.gameDialog.value = GameDialog.Quests;
}
