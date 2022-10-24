

import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/game_queries.dart';
import 'package:gamestream_flutter/game_state.dart';

void highlightCharacterNearMouse() {
  final playerCharacter = GameState.getPlayerCharacter();
  if (playerCharacter != null){
    var nearest = 25.0;
    var nearestIndex = -1;
    for (var i = 0; i < GameState.totalCharacters; i++){
      final characterDistance = GameQueries.getDistanceFromMouse(GameState.characters[i]);
      if (characterDistance > nearest) continue;
      if (GameState.characters[i] == playerCharacter) continue;
      nearest = characterDistance;
      nearestIndex = i;
    }
    if (nearestIndex != -1){
      GameState.characters[nearestIndex].color = GameState.colorShades[Shade.Very_Bright];
    }
  }
}