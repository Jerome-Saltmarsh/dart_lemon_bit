

import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/game_state.dart';
import 'package:gamestream_flutter/isometric/queries/get_distance_from_mouse.dart';

void highlightCharacterNearMouse() {
  final playerCharacter = GameState.getPlayerCharacter();
  if (playerCharacter != null){
    var nearest = 25.0;
    var nearestIndex = -1;
    for (var i = 0; i < GameState.totalCharacters; i++){
      final characterDistance = getDistanceFromMouse(GameState.characters[i]);
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