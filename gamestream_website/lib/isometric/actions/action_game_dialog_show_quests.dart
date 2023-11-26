
import 'package:gamestream_flutter/isometric/enums/game_dialog.dart';
import 'package:gamestream_flutter/isometric/player.dart';

void actionGameDialogShowQuests() {
  if (player.gameDialog.value == GameDialog.Quests){
    player.gameDialog.value = null;
    return;
  }
  player.gameDialog.value = GameDialog.Quests;
}
