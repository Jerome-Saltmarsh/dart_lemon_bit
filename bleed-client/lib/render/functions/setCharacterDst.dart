import 'dart:typed_data';

import 'package:bleed_client/classes/Character.dart';
import 'package:bleed_client/render/constants/manScale.dart';

import 'mapDst.dart';

Float32List mapCharacterDst(Character character) {
  return mapDst(
      scale: manScale,
      x: character.x - manRenderSizeHalf,
      y: character.y - manRenderSizeHalf);
}
