
import 'package:bleed_client/events.dart';
import 'package:bleed_client/functions/cameraCenterPlayer.dart';
import 'package:lemon_engine/game.dart';

Future onGameJoined(GameJoined gameJoined) async {
  cameraCenterPlayer();
  rebuildUI();
}