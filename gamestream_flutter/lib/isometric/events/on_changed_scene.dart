
import 'package:gamestream_flutter/game.dart';

void onChangedScene(){
  for (final particle in Game.particles){
    particle.duration = 0;
  }
  Game.totalParticles = 0;
}