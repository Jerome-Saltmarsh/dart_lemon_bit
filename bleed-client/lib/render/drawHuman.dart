import 'dart:ui';

import 'package:bleed_client/classes/Character.dart';
import 'package:bleed_client/engine/render/drawImageRect.dart';
import 'package:bleed_client/mappers/mapHumanToImage.dart';
import 'package:bleed_client/mappers/mapHumanToRect.dart';

final double _size = 40;
final double _sizeHalf = _size * 0.5;

void renderHuman(Character character) {
  drawImageRect(
    mapHumanToImage(character.state, character.weapon),
    mapHumanToRect(character.weapon, character.state, character.direction, character.frame),
    Rect.fromLTWH(character.x - _sizeHalf, character.y - _sizeHalf, _size, _size),
  );
}
