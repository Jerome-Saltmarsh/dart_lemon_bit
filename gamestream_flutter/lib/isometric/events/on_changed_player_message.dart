
import 'package:gamestream_flutter/isometric/player.dart';

void onChangedPlayerMessage(String value){
  if (value.isNotEmpty) {
    player.messageTimer = 200;
  } else {
    player.messageTimer = 0;
  }
}