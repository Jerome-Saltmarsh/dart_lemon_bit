
import 'package:gamestream_flutter/isometric/particles.dart';

void onChangedScene(){
  for (final particle in particles){
    particle.duration = 0;
  }
  totalParticles = 0;
}