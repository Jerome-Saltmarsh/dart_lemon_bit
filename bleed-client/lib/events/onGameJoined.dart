
import 'package:bleed_client/events.dart';
import 'package:bleed_client/functions/cameraCenterPlayer.dart';

Future onGameJoined(GameJoined gameJoined) async {
  cameraCenterPlayer();
}