import 'package:gamestream_flutter/isometric/classes/character.dart';

import 'render_v3.dart';

void renderCharacterSlime(Character character) {
  if (character.hurt || character.dying) {
    return renderV3(
      value: character,
      srcX: 3088,
      srcY: (48 * (character.frame % 6)),
      srcWidth: 48,
      srcHeight: 48,
    );
  }

  renderV3(
    value: character,
    srcX: 2992,
    srcY: (48 * (character.frame % 6)),
    srcWidth: 48,
    srcHeight: 48,
  );
}
