
import 'package:gamestream_flutter/isometric/classes/character.dart';
import 'package:gamestream_flutter/isometric/classes/particle.dart';
import 'package:gamestream_flutter/isometric/classes/projectile.dart';
import 'package:gamestream_flutter/isometric/particles.dart';
import 'package:gamestream_flutter/isometric/players.dart';
import 'package:gamestream_flutter/isometric/projectiles.dart';
import 'package:gamestream_flutter/isometric/zombies.dart';

void initializeIsometricGameState(){
  for (var i = 0; i < 150; i++) {
    players.add(Character());
  }
  for (var i = 0; i < 50; i++) {
    // interactableNpcs.add(Character());
  }
  for (var i = 0; i < 2000; i++) {
    zombies.add(Character());
  }
  for (var i = 0; i < 50; i++) {
    // bulletHoles.add(Vector2(0, 0));
  }
  for (var i = 0; i < 200; i++) {
    projectiles.add(Projectile());
  }

  for(var i = 0; i < 300; i++){
    particles.add(Particle());
  }
  // for (var i = 0; i < 500; i++) {
  //   collectables.add(Collectable());
  // }
}