
import 'common.dart';
import 'maths.dart';
import 'utils.dart';

void updateCollisions(List<dynamic> characters) {
  for (int i = 0; i < characters.length; i++) {
    dynamic characterI = characters[i];
    if (isDead(characterI)) continue;
    for (int j = i + 1; j < characters.length; j++) {
      dynamic characterJ = characters[j];
      if (isDead(characterJ)) continue;
      double distance = distanceBetween(characterI, characterJ);
      if (distance < characterRadius2) {
        double overlap = characterRadius2 - distance;
        double halfOverlap = overlap * 0.5;
        double xDiff = characterI[keyPositionX] - characterJ[keyPositionX];
        double yDiff = characterI[keyPositionY] - characterJ[keyPositionY];
        double mag = magnitude(xDiff, yDiff);
        double ratio = 1.0 / mag;
        double xDiffNormalized = xDiff * ratio;
        double yDiffNormalized = yDiff * ratio;
        double targetX = xDiffNormalized * halfOverlap;
        double targetY = yDiffNormalized * halfOverlap;
        characterI[keyPositionX] += targetX;
        characterI[keyPositionY] += targetY;
        characterJ[keyPositionX] -= targetX;
        characterJ[keyPositionY] -= targetY;
      }
    }
  }
}
const double zombieSpeed = 0.75;
const double characterSpeed = 1.5;

double getSpeed(dynamic character) {
  if (isHuman(character)) {
    return characterSpeed;
  }
  return zombieSpeed;
}

void updateMovement(dynamic character){
  const double velocityFriction = 0.94;
  character[keyPositionX] += character[keyVelocityX];
  character[keyPositionY] += character[keyVelocityY];
  character[keyVelocityX] *= velocityFriction;
  character[keyVelocityY] *= velocityFriction;

  switch (character[keyState]) {
    case characterStateWalking:
      double speed = getSpeed(character);
      switch (character[keyDirection]) {
        case directionUp:
          character[keyPositionY] -= speed;
          break;
        case directionUpRight:
          character[keyPositionX] += speed * 0.5;
          character[keyPositionY] -= speed * 0.5;
          break;
        case directionRight:
          character[keyPositionX] += speed;
          break;
        case directionDownRight:
          character[keyPositionX] += speed * 0.5;
          character[keyPositionY] += speed * 0.5;
          break;
        case directionDown:
          character[keyPositionY] += speed;
          break;
        case directionDownLeft:
          character[keyPositionX] -= speed * 0.5;
          character[keyPositionY] += speed * 0.5;
          break;
        case directionLeft:
          character[keyPositionX] -= speed;
          break;
        case directionUpLeft:
          character[keyPositionX] -= speed * 0.5;
          character[keyPositionY] -= speed * 0.5;
          break;
      }
      break;
  }
}

