

import 'package:lemon_math/randomItem.dart';

import 'classes/Character.dart';
import 'classes/Game.dart';
import 'classes/Player.dart';
import 'common/OrbType.dart';
import 'common/PlayerEvent.dart';

final handlers = _EventHandlers();

class _EventHandlers {
  void onKilledEarnOrb(Game game, Character src, Character target, int damage){
    print("onKilledEarnGem()");
    if (src is Player){
      final orbs = src.orbs;
      switch(randomItem(orbTypes)) {
        case OrbType.Topaz:
          orbs.topaz++;
          src.dispatch(PlayerEvent.Orb_Earned_Topaz);
          return;
        case OrbType.Ruby:
          orbs.ruby++;
          return;
        case OrbType.Emerald:
          orbs.emerald++;
          return;
      }
    }
  }
}

