

import 'package:bleed_client/connection.dart';
import 'package:bleed_client/instances/game.dart';
import 'package:bleed_client/state.dart';
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
  game.playerId = event.id;
  playerUUID = event.uuid;
  playerX = event.x;
  playerY = event.y;
  cameraCenter(playerX, playerY);
}

void _joinRandomGame() {
  send(ClientRequest.Game_Join_Random.index.toString());
}