
import 'package:gamestream_flutter/library.dart';

void onChangedScene(){
  for (final particle in ClientState.particles){
    particle.duration = 0;
  }
  ClientState.totalParticles = 0;
  GameIO.recenterCursor();
}