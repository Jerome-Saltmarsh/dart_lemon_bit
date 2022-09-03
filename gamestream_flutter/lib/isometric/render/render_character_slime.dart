import 'package:gamestream_flutter/isometric/classes/character.dart';

import 'render_v3.dart';

void renderCharacterSlime(Character character) => renderV3(
      value: character,
      srcX: 2992,
      srcY: (48 * (character.frame % 6)),
      srcWidth: 48,
      srcHeight: 48,
    );
