import 'dart:typed_data';

import 'package:bleed_client/classes/Character.dart';
import 'package:bleed_client/common/CharacterState.dart';
import 'package:bleed_client/common/WeaponType.dart';
import 'package:bleed_client/render/constants/manScale.dart';
import 'package:bleed_client/common/CharacterType.dart';

import 'mapDst.dart';

Float32List mapCharacterDst(Character character, CharacterType type) {

  if (type == CharacterType.Human || type == CharacterType.Witch){
    if (character.state == CharacterState.Striking){
      return mapDst(
          scale: manScale,
          x: character.x - manRenderStrikeSizeHalf,
          y: character.y - manRenderStrikeSizeHalf);
    }

    if (character.state == CharacterState.Firing && character.weapon == WeaponType.Bow){
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
