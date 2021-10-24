import 'package:bleed_client/classes/Item.dart';
import 'package:bleed_client/classes/Particle.dart';
import 'package:bleed_client/classes/Sprite.dart';
import 'package:bleed_client/common/classes/Vector2.dart';
import 'package:bleed_client/common/ClientRequest.dart';
import 'package:bleed_client/common/Tile.dart';
import 'package:bleed_client/connection.dart';
import 'package:bleed_client/engine/game_widget.dart';
import 'package:bleed_client/enums.dart';
import 'package:bleed_client/events.dart';
import 'package:bleed_client/send.dart';
import 'package:bleed_client/settings.dart';
import 'package:bleed_client/utils.dart';

import 'instances/settings.dart';
import 'state.dart';

void initBleed() {
  onConnectedController.stream.listen(_onConnected);

  on((GameJoined gameJoined) async {
    cameraCenter(compiledGame.playerX, compiledGame.playerY);
    rebuildUI();
  });

  for(int i = 0; i < settings.maxParticles; i++){
    compiledGame.particles.add(Particle());
  }

  for (int i = 0; i < 1000; i++) {
    compiledGame.bullets.add(Vector2(0, 0));
    compiledGame.items.add(Item());
  }

  for (int i = 0; i < 2000; i++) {
    compiledGame.crates.add(Vector2(0, 0));
  }

  for (int i = 0; i < 1000; i++) {
    compiledGame.sprites.add(Sprite());
  }

  for (int i = 0; i < settings.maxBulletHoles; i++) {
    compiledGame.bulletHoles.add(Vector2(0, 0));
  }

  periodic(sendRequestUpdateScore, seconds: 3);
}

void connectToGCP() {
  connect(gpc);
}

void _onConnected(_event) {
  // send(ClientRequest.Version.index.toString());
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
