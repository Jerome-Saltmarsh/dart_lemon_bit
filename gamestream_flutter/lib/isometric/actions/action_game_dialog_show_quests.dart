
import 'package:bleed_common/GameType.dart';
import 'package:gamestream_flutter/control/state/game_type.dart';
import 'package:gamestream_flutter/isometric/enums/game_dialog.dart';
import 'package:gamestream_flutter/isometric/player.dart';

void actionGameDialogShowQuests() {
  if (gameType.value != GameType.Dark_Age) return;

  if (player.gameDialog.value == GameDialog.Quests){
    player.gameDialog.value = null;
    return;
  }
  player.gameDialog.value = GameDialog.Quests;
}
