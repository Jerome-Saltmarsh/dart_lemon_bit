import 'dart:math';
import 'dart:typed_data';

import 'package:bleed_client/common/CharacterState.dart';
import 'package:bleed_client/common/CharacterType.dart';
import 'package:bleed_client/common/WeaponType.dart';
import 'package:bleed_client/common/enums/Direction.dart';
import 'package:bleed_client/common/enums/Shade.dart';
import 'package:bleed_client/render/constants/animations.dart';
import 'package:bleed_client/render/constants/atlas.dart';
import 'package:bleed_client/render/mappers/mapArcherToSrc.dart';
import 'package:bleed_client/render/mappers/mapKnightToSrc.dart';
import 'package:bleed_client/render/mappers/mapSrcHuman.dart';
import 'package:bleed_client/render/mappers/mapSrcWitch.dart';
import 'package:bleed_client/render/mappers/mapSrcZombie.dart';

Float32List mapCharacterSrc({
  required CharacterType type,
  required CharacterState state,
  required WeaponType weapon,
  required Direction direction,
  required int frame,
  required Shade shade,
}) {
  switch (type) {
    case CharacterType.Human:
      return mapSrcHuman(
          weaponType: weapon,
          characterState: state,
          direction: direction,
          frame: frame
      );
    case CharacterType.Zombie:
      return mapSrcZombie(
          state: state, direction: direction, frame: frame, shade: shade
      );
    case CharacterType.Witch:
      return mapSrcWitch(state: state, direction: direction, frame: frame);
    case CharacterType.Archer:
      return mapSrcArcher(state: state, direction: direction, frame: frame);
    case CharacterType.Swordsman:
      return mapSrcKnight(state: state, direction: direction, frame: frame);
    default:
      throw Exception("Cannot map $type to src");
  }
}

