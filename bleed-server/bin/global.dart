
import 'games/moba.dart';

final _Global global = _Global();

class _Global {
  List<Moba> mobaGames = [];
}

Moba findPendingMobaGame() {
  for (Moba moba in global.mobaGames) {
    if (!moba.started) {
      return moba;
    }
  }
  final Moba moba = Moba();
  global.mobaGames.add(moba);
  return moba;
}


