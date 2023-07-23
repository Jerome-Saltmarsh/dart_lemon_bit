
import 'package:gamestream_flutter/gamestream/isometric/classes/isometric_character.dart';

mixin IsometricCharacters {
  final characters = <IsometricCharacter>[];
  var totalCharacters = 0;

  IsometricCharacter getCharacterInstance(){
    if (characters.length <= totalCharacters){
      characters.add(IsometricCharacter());
    }
    return characters[totalCharacters];
  }
}