
import 'package:gamestream_flutter/game_state.dart';

void onChangedPlayerMessage(String value){
  if (value.isNotEmpty) {
    GameState.player.messageTimer = 200;
  } else {
    GameState.player.messageTimer = 0;
  }
}