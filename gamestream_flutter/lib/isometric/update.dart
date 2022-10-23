

import 'package:gamestream_flutter/isometric/classes/character.dart';
import 'package:gamestream_flutter/isometric/grid_state_util.dart';


void applyCharacterToWind(Character character){
   if (character.running || character.performing) {
     if (gridNodeInBoundsVector3(character)) return;
     gridNodeIncrementWindVector3(character);
   }
}


