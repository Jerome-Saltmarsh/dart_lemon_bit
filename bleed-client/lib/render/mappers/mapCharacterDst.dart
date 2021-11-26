import 'dart:typed_data';

import 'package:bleed_client/classes/Character.dart';
import 'package:bleed_client/common/CharacterState.dart';
import 'package:bleed_client/render/constants/manScale.dart';
import 'package:bleed_client/render/enums/CharacterType.dart';

import 'mapDst.dart';

Float32List mapCharacterDst(Character character, CharacterType type) {

  if (type == CharacterType.Human){
    if (character.state == CharacterState.Striking){
      return mapDst(
          scale: manScale,
          x: character.x - manRenderStrikeSizeHalf,
          y: character.y - manRenderStrikeSizeHalf);
    }
  }

  return mapDst(
      scale: manScale,
      x: character.x - manRenderSizeHalf,
      y: character.y - manRenderSizeHalf);
}
