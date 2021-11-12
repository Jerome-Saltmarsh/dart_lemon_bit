import 'package:bleed_client/send.dart';
import 'package:bleed_client/state/game.dart';

void updatePlayer() {
  if (game.playerId < 0) return;
  sendRequestUpdatePlayer();
}
