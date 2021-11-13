
import 'package:bleed_client/events.dart';
import 'package:bleed_client/state/game.dart';
import 'package:lemon_engine/game.dart';

import '../utils.dart';

Future onGameJoined(GameJoined gameJoined) async {
  cameraCenter(game.playerX, game.playerY);
  rebuildUI();
}