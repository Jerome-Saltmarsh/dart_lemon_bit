import 'dart:ui';

import 'package:bleed_client/classes/Human.dart';
import 'package:bleed_client/render/drawImage.dart';
import 'package:bleed_client/mappers/mapHumanToImage.dart';
import 'package:bleed_client/mappers/mapHumanToRect.dart';

final double _size = 40;
final double _sizeHalf = _size * 0.5;

void renderHuman(Human human) {
  drawImageRect(
    mapHumanToImage(human),
    mapHumanToRect(human.weapon, human.state, human.direction, human.frame),
    Rect.fromLTWH(human.x - _sizeHalf, human.y - _sizeHalf, _size, _size),
  );
}
