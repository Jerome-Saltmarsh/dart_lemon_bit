
import 'package:bleed_client/common/ClientRequest.dart';
import 'package:bleed_client/connection.dart';
import 'package:bleed_client/events.dart';
import 'package:bleed_client/game_engine/game_widget.dart';
import 'package:bleed_client/settings.dart';
import 'package:bleed_client/utils.dart';

import 'instances/settings.dart';
import 'state.dart';

void initBleed(){
  onConnectedController.stream.listen(_onConnected);

  if(!settings.developMode) connectToGCP();

  on((GameJoined gameJoined) async {
    cameraCenter(compiledGame.playerX, compiledGame.playerY);
    redrawUI();
  });
}

void connectToGCP() {
  connect(gpc);
}

void _onConnected(_event){
  _joinRandomGame();
}

void _joinRandomGame() {
  send(ClientRequest.Game_Join_Casual.index.toString());
}