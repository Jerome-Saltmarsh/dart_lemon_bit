import 'package:bleed_common/character_type.dart';
import 'package:gamestream_flutter/isometric/audio/audio_singles.dart';

void onGameEventCharacterHurt(int type, double x, double y, double z, double angle) {
  audioSingleBloodyPunches3.playXYZ(x, y, z);

  switch (type) {
    case CharacterType.Zombie:
      audioSingleZombieHurt.playXYZ(x, y, z);
      break;
    case CharacterType.Rat:
      audioSingleRatSqueak.playXYZ(x, y, z);
      break;
    case CharacterType.Slime:
      audioSingleBloodyPunches3.playXYZ(x, y, z);
      break;
  }
}
