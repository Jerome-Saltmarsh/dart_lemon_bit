import 'dart:ui';

import 'package:bleed_client/classes/Character.dart';
import 'package:bleed_client/state/settings.dart';

final double _sizeHalf = settings.manRenderSize * 0.5;

Rect mapCharacterToDstMan(Character character) {
  return Rect.fromLTWH(
      character.x - _sizeHalf,
      character.y - _sizeHalf,
      settings.manRenderSize,
      settings.manRenderSize
  );
}


