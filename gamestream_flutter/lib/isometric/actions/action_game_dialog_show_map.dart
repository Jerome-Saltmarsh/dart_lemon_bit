
import 'package:bleed_common/GameType.dart';
import 'package:gamestream_flutter/gamestream.dart';
import 'package:gamestream_flutter/isometric/enums/game_dialog.dart';
import 'package:gamestream_flutter/isometric/player.dart';

void actionGameDialogShowMap() {
  if (gamestream.gameType.value != GameType.Dark_Age) return;

  if (player.gameDialog.value == GameDialog.Map){
    player.gameDialog.value = null;
    return;
  }
  player.gameDialog.value = GameDialog.Map;
}
