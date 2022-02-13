

import 'classes/Character.dart';
import 'classes/Game.dart';
import 'classes/Player.dart';
import 'functions.dart';

final handlers = _EventHandlers();

class _EventHandlers {
  void onKilledEarnOrb(Game game, Character src, Character target, int damage){
    print("onKilledEarnGem()");
    if (src is Player){
      playerEarnRandomOrb(src);
    }
  }
}

