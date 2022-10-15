

import 'package:gamestream_flutter/game_state.dart';
import 'package:gamestream_flutter/isometric/classes/character.dart';


var totalCharacters = 0;
final characters = <Character>[];

Character getCharacterInstance(){
  if (characters.length <= totalCharacters){
    characters.add(Character());
  }
  return characters[totalCharacters];
}

Character? getPlayerCharacter(){
  for (var i = 0; i < totalCharacters; i++){
    if (characters[i].x != GameState.player.x) continue;
    if (characters[i].y != GameState.player.y) continue;
    return characters[i];
  }
  return null;
}