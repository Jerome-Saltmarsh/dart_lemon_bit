
import 'package:gamestream_flutter/isometric/classes/character.dart';

mixin IsometricCharacters {
  final characters = <Character>[];
  var totalCharacters = 0;

  Character getCharacterInstance(){
    if (characters.length <= totalCharacters){
      characters.add(Character());
    }
    return characters[totalCharacters];
  }
}