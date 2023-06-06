

import 'package:gamestream_flutter/library.dart';

void highlightCharacterNearMouse() {
  final playerCharacter = gamestream.isometricEngine.serverState.getPlayerCharacter();
  if (playerCharacter != null){
    var nearest = 25.0;
    var nearestIndex = -1;
    for (var i = 0; i < gamestream.isometricEngine.serverState.totalCharacters; i++){
      final characterDistance = gamestream.isometricEngine.nodes.getDistanceFromMouse(gamestream.isometricEngine.serverState.characters[i]);
      if (characterDistance > nearest) continue;
      if (gamestream.isometricEngine.serverState.characters[i] == playerCharacter) continue;
      nearest = characterDistance;
      nearestIndex = i;
    }
    if (nearestIndex != -1){
      // todo add back
      // GameState.characters[nearestIndex].color = GameLighting.values[Shade.Very_Bright];
    }
  }
}