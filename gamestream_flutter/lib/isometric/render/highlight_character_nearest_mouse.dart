

import 'package:gamestream_flutter/library.dart';

void highlightCharacterNearMouse() {
  final playerCharacter = ServerState.getPlayerCharacter();
  if (playerCharacter != null){
    var nearest = 25.0;
    var nearestIndex = -1;
    for (var i = 0; i < ServerState.totalCharacters; i++){
      final characterDistance = GameQueries.getDistanceFromMouse(ServerState.characters[i]);
      if (characterDistance > nearest) continue;
      if (ServerState.characters[i] == playerCharacter) continue;
      nearest = characterDistance;
      nearestIndex = i;
    }
    if (nearestIndex != -1){
      // todo add back
      // GameState.characters[nearestIndex].color = GameLighting.values[Shade.Very_Bright];
    }
  }
}