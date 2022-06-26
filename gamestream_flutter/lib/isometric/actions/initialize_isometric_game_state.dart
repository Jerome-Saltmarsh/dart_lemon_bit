
import 'package:gamestream_flutter/isometric/classes/character.dart';
import 'package:gamestream_flutter/isometric/classes/projectile.dart';
import 'package:gamestream_flutter/isometric/npcs.dart';
import 'package:gamestream_flutter/isometric/players.dart';
import 'package:gamestream_flutter/isometric/projectiles.dart';

import '../audio.dart';

void initializeIsometricGameState(){
  audio.init();
  for (var i = 0; i < 150; i++) {
    players.add(Character());
  }
  for (var i = 0; i < 200; i++) {
    projectiles.add(Projectile());
  }
  for (var i = 0; i < 200; i++) {
    npcs.add(Character());
  }
}