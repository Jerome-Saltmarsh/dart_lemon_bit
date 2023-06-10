

import 'package:gamestream_flutter/library.dart';

void highlightCharacterNearMouse() {
  final playerCharacter = gamestream.isometric.server.getPlayerCharacter();
  if (playerCharacter != null){
    var nearest = 25.0;
    var nearestIndex = -1;
    for (var i = 0; i < gamestream.isometric.server.totalCharacters; i++){
      final characterDistance = gamestream.isometric.nodes.getDistanceFromMouse(gamestream.isometric.server.characters[i]);
      if (characterDistance > nearest) continue;
      if (gamestream.isometric.server.characters[i] == playerCharacter) continue;
      nearest = characterDistance;
      nearestIndex = i;
    }
    if (nearestIndex != -1){
      // todo add back
      // GameState.characters[nearestIndex].color = GameLighting.values[Shade.Very_Bright];
    }
  }
}