

import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/isometric/characters.dart';
import 'package:gamestream_flutter/isometric/queries/get_distance_from_mouse.dart';
import 'package:gamestream_flutter/isometric/render/get_character_render_color.dart';

void applyCharacterColors(){
  for (var i = 0; i < totalCharacters; i++){
    characters[i].color = getNodeBelowColor(characters[i]);
  }
}

void highlightCharacterNearMouse() {
  final playerCharacter = getPlayerCharacter();
  if (playerCharacter != null){
    var nearest = 25.0;
    var nearestIndex = -1;
    for (var i = 0; i < totalCharacters; i++){
      final characterDistance = getDistanceFromMouse(characters[i]);
      if (characterDistance > nearest) continue;
      if (characters[i] == playerCharacter) continue;
      nearest = characterDistance;
      nearestIndex = i;
    }
    if (nearestIndex != -1){
      characters[nearestIndex].color = convertShadeToColor(Shade.Very_Bright);
    }
  }
}