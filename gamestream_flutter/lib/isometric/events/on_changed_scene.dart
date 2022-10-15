
import 'package:gamestream_flutter/game_state.dart';

void onChangedScene(){
  for (final particle in GameState.particles){
    particle.duration = 0;
  }
  GameState.totalParticles = 0;
}