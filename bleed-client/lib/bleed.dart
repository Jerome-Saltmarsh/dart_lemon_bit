

import 'package:bleed_client/connection.dart';
import 'package:bleed_client/instances/game.dart';
import 'package:bleed_client/utils.dart';

import 'enums/ClientRequest.dart';
import 'streams/onPlayerCreated.dart';

void initBleed(){
  onConnectedController.stream.listen(_onConnected);
  onPlayerCreated.stream.listen(_onPlayerCreated);
}

void _onConnected(_event){
  _joinRandomGame();
}

void _onPlayerCreated(OnPlayerCreated event){
  compiledGame.playerId = event.id;
  compiledGame.playerUUID = event.uuid;
  compiledGame.playerX = event.x;
  compiledGame.playerY = event.y;
  cameraCenter(compiledGame.playerX, compiledGame.playerY);
}

void _joinRandomGame() {
  send(ClientRequest.Game_Join_Random.index.toString());
}