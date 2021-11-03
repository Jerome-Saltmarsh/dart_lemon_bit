import 'package:bleed_client/classes/Item.dart';
import 'package:bleed_client/classes/Particle.dart';
import 'package:bleed_client/classes/Sprite.dart';
import 'package:bleed_client/common/ClientRequest.dart';
import 'package:bleed_client/common/Tile.dart';
import 'package:bleed_client/common/classes/Vector2.dart';
import 'package:bleed_client/engine/render/gameWidget.dart';
import 'package:bleed_client/enums.dart';
import 'package:bleed_client/events.dart';
import 'package:bleed_client/network/functions/send.dart';
import 'package:bleed_client/network/streams/eventStream.dart';
import 'package:bleed_client/network/streams/onConnected.dart';
import 'package:bleed_client/parse.dart';
import 'package:bleed_client/parser/state/event.dart';
import 'package:bleed_client/state.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/utils.dart';

import 'state/settings.dart';


void initBleed() {
  onConnectedController.stream.listen(_onConnected);
  eventStream.stream.listen(_onEventReceivedFromServer);

  on((GameJoined gameJoined) async {
    cameraCenter(game.playerX, game.playerY);
    rebuildUI();
  });

  for(int i = 0; i < settings.maxParticles; i++){
    game.particles.add(Particle());
  }

  for (int i = 0; i < 1000; i++) {
    game.bullets.add(Vector2(0, 0));
    game.items.add(Item());
  }

  for (int i = 0; i < 2000; i++) {
    game.crates.add(Vector2(0, 0));
  }

  for (int i = 0; i < 1000; i++) {
    game.sprites.add(Sprite());
  }

  for (int i = 0; i < settings.maxBulletHoles; i++) {
    game.bulletHoles.add(Vector2(0, 0));
  }

  // periodic(sendRequestUpdateScore, seconds: 3);
}

void _onEventReceivedFromServer(dynamic value){
  lag = framesSinceEvent;
  framesSinceEvent = 0;
  event = value;
  parseState();
  redrawCanvas();
}

void _onConnected(_event) {
  print("on connected");
  rebuildUI();
  Future.delayed(Duration(seconds: 1), rebuildUI);
  joinGameOpenWorld();
}

void joinGameCasual() {
  send(ClientRequest.Game_Join_Casual.index.toString());
}

void joinGameOpenWorld(){
  send(ClientRequest.Game_Join_Open_World.index.toString());
}

void onPlayerStateChanged(CharacterState previous, CharacterState next) {
  if (previous == CharacterState.Dead || next == CharacterState.Dead) {
    rebuildUI();
  }
}

void onPlayerTileChanged(Tile previous, Tile next) {
  if (next == Tile.PlayerSpawn) {
    rebuildUI();
    return;
  }

  if (previous == Tile.PlayerSpawn) {
    rebuildUI();
    return;
  }
}
