

import 'dart:ui';

import 'package:bleed_client/classes/Character.dart';

const double _frameWidth = 36;
const double _frameHeight = 35;
const double _frameWidthHalf = _frameWidth * 0.5;
const double _frameHeightHalf = _frameHeight * 0.5;

Rect mapHumanToDstRect(Character character){
  return Rect.fromLTWH(
      character.x - _frameWidthHalf,
      character.y - _frameHeightHalf,
      _frameWidth,
      _frameHeight
  );
}