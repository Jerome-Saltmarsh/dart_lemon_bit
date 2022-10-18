

import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/game.dart';
import 'package:gamestream_flutter/isometric/queries/get_distance_from_mouse.dart';

void applyCharacterColors(){
  for (var i = 0; i < Game.totalCharacters; i++){
    Game.characters[i].color = Game.getV3RenderColor(Game.characters[i]);
  }
}

void highlightCharacterNearMouse() {
  final playerCharacter = Game.getPlayerCharacter();
  if (playerCharacter != null){
    var nearest = 25.0;
    var nearestIndex = -1;
    for (var i = 0; i < Game.totalCharacters; i++){
      final characterDistance = getDistanceFromMouse(Game.characters[i]);
      if (characterDistance > nearest) continue;
      if (Game.characters[i] == playerCharacter) continue;
      nearest = characterDistance;
      nearestIndex = i;
    }
    if (nearestIndex != -1){
      Game.characters[nearestIndex].color = Game.colorShades[Shade.Very_Bright];
    }
  }
}