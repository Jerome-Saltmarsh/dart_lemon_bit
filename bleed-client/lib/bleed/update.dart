

import 'common.dart';
import 'connection.dart';
import 'input.dart';
import 'send.dart';
import 'settings.dart';
import 'state.dart';
import 'utils.dart';

void update(){
  DateTime now = DateTime.now();
  refreshDuration = now.difference(lastRefresh);
  lastRefresh = DateTime.now();
  framesSinceEvent++;
  smoothing();
  controlCamera();
  readPlayerInput();

  if (playerAssigned) {
    sendRequestUpdatePlayer();
  } else {
    sendCommandUpdate();
  }
}

void smoothing() {
  if (!smooth) return;
  if (framesSinceEvent > smoothingFrames) return;

  for (dynamic character in players) {
    double speed = 2;
    if (character[0] != characterStateWalking) {
      continue;
    }
    switch (getDirection(character)) {
      case directionUp:
        character[3] -= speed;
        break;
      case directionUpRight:
        character[2] += speed * 0.5;
        character[3] -= speed * 0.5;
        break;
      case directionRight:
        character[2] += speed;
        break;
      case directionDownRight:
        character[2] += speed * 0.5;
        character[3] += speed * 0.5;
        break;
      case directionDown:
        character[3] += speed;
        break;
      case directionDownLeft:
        character[2] -= speed * 0.5;
        character[3] += speed * 0.5;
        break;
      case directionLeft:
        character[2] -= speed;
        break;
      case directionUpLeft:
        character[2] -= speed * 0.5;
        character[3] -= speed * 0.5;
        break;
    }
    break;
  }
}
