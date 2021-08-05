import 'package:flutter_game_engine/bleed/connection.dart';

import 'input.dart';
import 'send.dart';
import 'state.dart';
import 'utils.dart';

void update(){
  DateTime now = DateTime.now();
  refreshDuration = now.difference(lastRefresh);
  lastRefresh = DateTime.now();
  framesSinceEvent++;
  controlCamera();
  readPlayerInput();

  if(connected){
    if (playerAssigned) {
      sendRequestUpdatePlayer();
    } else {
      sendCommandUpdate();
    }
  }
}
