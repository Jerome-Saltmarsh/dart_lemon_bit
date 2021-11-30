import 'package:bleed_client/send.dart';
import 'package:bleed_client/state/game.dart';

void updatePlayer() {
  if (game.player.id < 0) return;
  sendRequestUpdatePlayer();
}
