
import 'package:gamestream_flutter/isometric/enums/game_dialog.dart';
import 'package:gamestream_flutter/isometric/player.dart';

void actionGameDialogShowMap() {
  if (player.gameDialog.value == GameDialog.Map){
    player.gameDialog.value = null;
    return;
  }
  player.gameDialog.value = GameDialog.Map;
}
