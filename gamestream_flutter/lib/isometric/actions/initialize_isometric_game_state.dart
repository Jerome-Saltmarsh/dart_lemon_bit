
import 'package:gamestream_flutter/isometric/classes/character.dart';
import 'package:gamestream_flutter/isometric/players.dart';

import '../audio.dart';

void initializeIsometricGameState(){
  audio.init();
  for (var i = 0; i < 150; i++) {
    players.add(Character());
  }
}