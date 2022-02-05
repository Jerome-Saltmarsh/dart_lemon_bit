
import 'package:bleed_client/common/CharacterState.dart';
import 'package:bleed_client/common/CharacterType.dart';
import 'package:bleed_client/common/SlotType.dart';
import 'package:bleed_client/common/WeaponType.dart';
import 'package:bleed_client/common/enums/Direction.dart';
import 'package:bleed_client/render/mappers/mapArcherToSrc.dart';
import 'package:bleed_client/render/mappers/mapKnightToSrc.dart';
import 'package:bleed_client/render/mappers/mapSrcHuman.dart';
import 'package:bleed_client/render/mappers/mapSrcWitch.dart';
import 'package:bleed_client/render/mappers/mapSrcZombie.dart';

void mapCharacterSrc({
  required CharacterType type,
  required CharacterState state,
  required SlotType slotType,
  required Direction direction,
  required int frame,
  required int shade,
}) {
  switch (type) {
    case CharacterType.Human:
      return mapSrcHuman(
          slotType: slotType,
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

