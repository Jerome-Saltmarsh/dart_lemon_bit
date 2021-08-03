import 'audio.dart';
import 'common.dart';
import 'input.dart';
import 'keys.dart';
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

  for(int i = 0; i < bullets.length; i++){
    if(bulletEventsFired.containsKey(bullets[i][id])) continue;
    bulletEventsFired[bullets[i][id]] = true;
    playAudioPistolShot();
  }

  if (playerAssigned) {
    sendRequestUpdatePlayer();
  } else {
    sendCommandUpdate();
  }
}

void smoothing() {
  if (!smooth) return;
  if (fps < settingsSmoothingMinFPS) return;
  if (framesSinceEvent > smoothingFrames) return;

  for (dynamic character in players) {
    double speed = 2;
    if (character[state] != characterStateWalking) {
      continue;
    }
    switch (getDirection(character)) {
      case directionUp:
        character[y] -= speed;
        break;
      case directionUpRight:
        character[x] += speed * 0.5;
        character[y] -= speed * 0.5;
        break;
      case directionRight:
        character[x] += speed;
        break;
      case directionDownRight:
        character[x] += speed * 0.5;
        character[y] += speed * 0.5;
        break;
      case directionDown:
        character[y] += speed;
        break;
      case directionDownLeft:
        character[x] -= speed * 0.5;
        character[y] += speed * 0.5;
        break;
      case directionLeft:
        character[x] -= speed;
        break;
      case directionUpLeft:
        character[x] -= speed * 0.5;
        character[y] -= speed * 0.5;
        break;
    }
    break;
  }
}
