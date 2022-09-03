import 'package:bleed_common/character_type.dart';
import 'package:gamestream_flutter/isometric/audio/audio_singles.dart';

void onCharacterHurt(int type, double x, double y, double z, double angle) {
  switch (type) {
    case CharacterType.Zombie:
      audioSingleZombieHurt.playXYZ(x, y, z);
      break;
  }
}
