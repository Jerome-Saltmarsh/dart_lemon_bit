import 'package:bleed_client/classes/Item.dart';
import 'package:bleed_client/common/ClientRequest.dart';
import 'package:bleed_client/common/Tile.dart';
import 'package:bleed_client/connection.dart';
import 'package:bleed_client/enums.dart';
import 'package:bleed_client/events.dart';
import 'package:bleed_client/game_engine/game_widget.dart';
import 'package:bleed_client/send.dart';
import 'package:bleed_client/settings.dart';
import 'package:bleed_client/utils.dart';

import 'state.dart';

void initBleed() {
  onConnectedController.stream.listen(_onConnected);

  on((GameJoined gameJoined) async {
    cameraCenter(compiledGame.playerX, compiledGame.playerY);
    redrawUI();
  });

  for (int i = 0; i < 1000; i++) {
    compiledGame.bullets.add(0);
    compiledGame.items.add(Item());
  }

  periodic(sendRequestUpdateScore, seconds: 3);
}

void connectToGCP() {
  connect(gpc);
}

void _onConnected(_event) {
  _joinRandomGame();
}

void _joinRandomGame() {
  send(ClientRequest.Game_Join_Casual.index.toString());
}

void onPlayerStateChanged(CharacterState previous, CharacterState next) {
  if (previous == CharacterState.Dead || next == CharacterState.Dead) {
    redrawUI();
  }
}

void onPlayerTileChanged(Tile previous, Tile next) {
  if (next == Tile.PlayerSpawn) {
    redrawUI();
    return;
  }

  if (previous == Tile.PlayerSpawn) {
    redrawUI();
    return;
  }
}
