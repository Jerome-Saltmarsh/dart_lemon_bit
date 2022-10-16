
import 'package:bleed_common/GameType.dart';
import 'package:gamestream_flutter/game.dart';
import 'package:gamestream_flutter/isometric/enums/game_dialog.dart';

void actionGameDialogShowQuests() {
  if (Game.gameType.value != GameType.Dark_Age) return;

  if (Game.player.gameDialog.value == GameDialog.Quests){
    Game.player.gameDialog.value = null;
    return;
  }
  Game.player.gameDialog.value = GameDialog.Quests;
}
