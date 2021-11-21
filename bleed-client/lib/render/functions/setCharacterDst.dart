import 'dart:typed_data';

import 'package:bleed_client/classes/Character.dart';
import 'package:bleed_client/render/constants/manScale.dart';

import 'setDst.dart';

void setCharacterDst(Character character, Float32List dst) {
  setDst(dst,
      scale: manScale,
      x: character.x - manRenderSizeHalf,
      y: character.y - manRenderSizeHalf);
}
