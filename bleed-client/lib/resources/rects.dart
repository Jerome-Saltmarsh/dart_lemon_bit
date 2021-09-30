import 'dart:ui';

import 'package:bleed_client/resources/rects_utils.dart';
import 'package:bleed_client/resources/rects_zombie.dart';

import '../common.dart';
import '../keys.dart';

RectsZombie _zombie = RectsZombie();

Rect mapZombieSpriteRect(dynamic character) {
  switch (character[stateIndex]) {
    case characterStateIdle:
      return _getZombieIdleRect(character);
    case characterStateWalking:
      return _getZombieWalkingRect(character);
    case characterStateDead:
      return _getZombieDeadRect(character);
    case characterStateStriking:
      return _getZombieStrikingRect(character);
  }
  throw Exception("Could not get character sprite rect");
}

Rect _getZombieIdleRect(dynamic character) {
  switch (character[direction]) {
    case directionUp:
      return _zombie.idle.up;
    case directionUpRight:
      return _zombie.idle.upRight;
    case directionRight:
      return _zombie.idle.right;
    case directionDownRight:
      return _zombie.idle.downRight;
    case directionDown:
      return _zombie.idle.down;
    case directionDownLeft:
      return _zombie.idle.downLeft;
    case directionLeft:
      return _zombie.idle.left;
    case directionUpLeft:
      return _zombie.idle.upLeft;
  }
  throw Exception("Could not get character walking sprite rect");
}

Rect _getZombieWalkingRect(dynamic character) {
  switch (character[direction]) {
    case directionUp:
      return getFrameLoop(_zombie.walking.up, character);
    case directionUpRight:
      return getFrameLoop(_zombie.walking.upRight, character);
    case directionRight:
      return getFrameLoop(_zombie.walking.right, character);
    case directionDownRight:
      return getFrameLoop(_zombie.walking.downRight, character);
    case directionDown:
      return getFrameLoop(_zombie.walking.down, character);
    case directionDownLeft:
      return getFrameLoop(_zombie.walking.downLeft, character);
    case directionLeft:
      return getFrameLoop(_zombie.walking.left, character);
    case directionUpLeft:
      return getFrameLoop(_zombie.walking.upLeft, character);
  }
  throw Exception("Could not get character walking sprite rect");
}

Rect _getZombieDeadRect(dynamic character) {
  switch (character[direction]) {
    case directionUp:
      return _zombie.dead.up;
    case directionUpRight:
      return _zombie.dead.upRight;
    case directionRight:
      return _zombie.dead.right;
    case directionDownRight:
      return _zombie.dead.downRight;
    case directionDown:
      return _zombie.dead.down;
    case directionDownLeft:
      return _zombie.dead.left;
    case directionLeft:
      return _zombie.dead.left;
    case directionUpLeft:
      return _zombie.dead.upLeft;
  }
  throw Exception("Could not get character dead sprite rect");
}

Rect _getZombieStrikingRect(character) {
  switch (character[direction]) {
    case directionUp:
      return getFrameLoop(_zombie.striking.up, character);
    case directionUpRight:
      return getFrameLoop(_zombie.striking.upRight, character);
    case directionRight:
      return getFrameLoop(_zombie.striking.right, character);
    case directionDownRight:
      return getFrameLoop(_zombie.striking.downRight, character);
    case directionDown:
      return getFrameLoop(_zombie.striking.down, character);
    case directionDownLeft:
      return getFrameLoop(_zombie.striking.downLeft, character);
    case directionLeft:
      return getFrameLoop(_zombie.striking.left, character);
    case directionUpLeft:
      return getFrameLoop(_zombie.striking.upLeft, character);
  }
  throw Exception("could not get firing frame from direction");
}