
import 'package:gamestream_flutter/game.dart';

void onChangedPlayerMessage(String value){
  if (value.isNotEmpty) {
    Game.player.messageTimer = 200;
  } else {
    Game.player.messageTimer = 0;
  }
}