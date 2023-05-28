

import 'package:gamestream_flutter/library.dart';

void highlightCharacterNearMouse() {
  final playerCharacter = gamestream.games.isometric.serverState.getPlayerCharacter();
  if (playerCharacter != null){
    var nearest = 25.0;
    var nearestIndex = -1;
    for (var i = 0; i < gamestream.games.isometric.serverState.totalCharacters; i++){
      final characterDistance = gamestream.games.isometric.nodes.getDistanceFromMouse(gamestream.games.isometric.serverState.characters[i]);
      if (characterDistance > nearest) continue;
      if (gamestream.games.isometric.serverState.characters[i] == playerCharacter) continue;
      nearest = characterDistance;
      nearestIndex = i;
    }
    if (nearestIndex != -1){
      // todo add back
      // GameState.characters[nearestIndex].color = GameLighting.values[Shade.Very_Bright];
    }
  }
}