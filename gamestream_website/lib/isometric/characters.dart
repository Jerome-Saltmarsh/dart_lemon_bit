

import 'package:gamestream_flutter/isometric/classes/character.dart';

var totalCharacters = 0;
final characters = <Character>[];

Character getCharacterInstance(){
  if (characters.length <= totalCharacters){
    characters.add(Character());
  }
  return characters[totalCharacters];
}